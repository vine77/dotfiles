#!/usr/bin/env bash
# Claude Code status line. Claude Code pipes session JSON on stdin; Starship
# can't read that, so jq maps the fields we show onto CLAUDE_* env vars and
# statusline.toml renders them with env_var modules. Directory and git come
# from Starship's own modules after cd-ing into the session's working dir.
set -euo pipefail

# Context % thresholds. Quality slips well before auto-compact, so warn early.
CTX_WARN=50
CTX_HIGH=75

# Exactly one CLAUDE_CTX_{OK,WARN,HIGH} is exported: each variant owns the
# powerline separators around its own color, so one must always render.
# Optional fields end in `// null`: an empty value would drop the whole object.
eval "$(jq -r --argjson warn "$CTX_WARN" --argjson high "$CTX_HIGH" '
  def until_reset:
    (.resets_at // empty | floor) - (now | floor)
    | select(. > 0)
    | if . >= 86400 then "\(. / 86400 | floor)d\(. % 86400 / 3600 | floor)h"
      else "\(. / 3600 | floor)h\(. % 3600 / 60 | floor)m" end;
  def limit($label):
    select(. != null)
    | "\($label) \(.used_percentage | round)%"
      + ([until_reset] | if length > 0 then " (\(.[0]))" else "" end);

  (.context_window.used_percentage) as $ctx
  | {
      CLAUDE_CWD: (.workspace.current_dir // .cwd),
      CLAUDE_MODEL: (
        [.model.display_name, .effort.level, (if .fast_mode then "󱐋" else empty end)]
        | map(select(. != null and . != "")) | join(" ")
      ),
      CLAUDE_PR: (
        (.pr // empty)
        | "#\(.number)"
          + ({approved: " ✓", changes_requested: " ✗", draft: " draft"}[.review_state] // "")
      ) // null,
      CLAUDE_LIMITS: (
        [(.rate_limits.five_hour | limit("5h")), (.rate_limits.seven_day | limit("7d"))]
        | join("  ") | select(. != "")
      ) // null
    }
  + if $ctx == null then {CLAUDE_CTX_OK: "--%"}
    elif $ctx >= $high then {CLAUDE_CTX_HIGH: "\($ctx | round)%"}
    elif $ctx >= $warn then {CLAUDE_CTX_WARN: "\($ctx | round)%"}
    else {CLAUDE_CTX_OK: "\($ctx | round)%"} end
  | with_entries(select(.value != null and .value != ""))
  | to_entries[] | "export \(.key)=\(.value | @sh)"
')"

[[ -n "${CLAUDE_CWD:-}" && -d "$CLAUDE_CWD" ]] && cd "$CLAUDE_CWD"

# STARSHIP_SHELL=sh: plain ANSI, without zsh's %{ %} prompt escapes
STARSHIP_CONFIG="$HOME/.claude/statusline.toml" STARSHIP_SHELL=sh \
  exec starship prompt ${COLUMNS:+--terminal-width "$COLUMNS"}
