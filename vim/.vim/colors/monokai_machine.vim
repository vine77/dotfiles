" monokai_machine.vim — Monokai Machine for Vim
" Palette lifted from the Monokai Machine theme JSON shipped in
" monokai.theme-monokai-pro-vscode.

hi clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'monokai_machine'
set background=dark

" base1 #273136  base2 #2d3739  base3 #3a4449  base4 #545f62
" base5 #6b7678  base6 #8b9798  base7 #b8c4c3  base8 #f2fffc
" red #ff6d7e  orange #ffb270  yellow #ffed72  green #a2e57b
" blue #7cd5f1  purple #baa0f8

let s:p = {
  \ 'bg':     ['#273136', 235],
  \ 'bgdark': ['#1d2528', 234],
  \ 'bgalt':  ['#2d3739', 236],
  \ 'bgsel':  ['#3d474b', 238],
  \ 'bgline': ['#313a3f', 237],
  \ 'ui':     ['#3a4449', 238],
  \ 'dim':    ['#545f62', 240],
  \ 'gray':   ['#6b7678', 243],
  \ 'gray2':  ['#8b9798', 245],
  \ 'gray3':  ['#b8c4c3', 250],
  \ 'fg':     ['#f2fffc', 255],
  \ 'red':    ['#ff6d7e', 204],
  \ 'orange': ['#ffb270', 215],
  \ 'yellow': ['#ffed72', 228],
  \ 'green':  ['#a2e57b', 150],
  \ 'blue':   ['#7cd5f1', 117],
  \ 'purple': ['#baa0f8', 141],
  \ 'diffa':  ['#33433d', 22],
  \ 'diffd':  ['#3d373d', 52],
  \ 'diffc':  ['#3d443c', 58],
  \ 'difft':  ['#525742', 94],
  \ 'none':   ['NONE',  'NONE'],
  \ }

function! s:hl(group, fg, bg, attr) abort
  let l:f = s:p[a:fg]
  let l:b = s:p[a:bg]
  let l:a = empty(a:attr) ? 'NONE' : a:attr
  exe 'hi' a:group
    \ 'guifg=' . l:f[0] 'guibg=' . l:b[0] 'gui=' . l:a 'guisp=NONE'
    \ 'ctermfg=' . l:f[1] 'ctermbg=' . l:b[1] 'cterm=' . l:a
endfunction
command! -nargs=+ Hi call s:hl(<f-args>)

" ---- editor chrome ----
Hi Normal        fg     bg     NONE
Hi NormalNC      fg     bg     NONE
Hi CursorLine    none   bgline NONE
Hi CursorColumn  none   bgline NONE
Hi ColorColumn   none   bgalt  NONE
Hi LineNr        dim    bg     NONE
Hi CursorLineNr  gray3  bgline NONE
Hi SignColumn    gray   bg     NONE
Hi FoldColumn    dim    bg     NONE
Hi Folded        gray   bgalt  italic
Hi VertSplit     ui     bg     NONE
Hi WinSeparator  ui     bg     NONE
Hi Visual        none   bgsel  NONE
Hi VisualNOS     none   bgsel  NONE
Hi MatchParen    yellow ui     bold
Hi Conceal       gray   none   NONE
Hi NonText       dim    none   NONE
Hi SpecialKey    dim    none   NONE
Hi Whitespace    dim    none   NONE
Hi EndOfBuffer   bg     none   NONE
Hi Cursor        bg     fg     NONE
Hi lCursor       bg     fg     NONE
Hi TermCursor    bg     fg     NONE

" Search is intentionally louder than the VS Code find highlight,
" which is a 15% white wash that reads as nothing in a terminal.
Hi Search        bg     yellow NONE
Hi IncSearch     bg     orange NONE
Hi CurSearch     bg     orange NONE

Hi StatusLine    fg     ui     NONE
Hi StatusLineNC  gray   bgdark NONE
Hi TabLine       gray2  bgdark NONE
Hi TabLineSel    yellow bg     NONE
Hi TabLineFill   none   bgdark NONE
Hi WildMenu      bg     yellow NONE
Hi Pmenu         gray3  ui     NONE
Hi PmenuSel      yellow dim    NONE
Hi PmenuSbar     none   ui     NONE
Hi PmenuThumb    none   gray   NONE
Hi Directory     blue   none   NONE
Hi Title         yellow none   bold
Hi Question      green  none   NONE
Hi MoreMsg       green  none   NONE
Hi ModeMsg       fg     none   bold
Hi ErrorMsg      red    none   NONE
Hi WarningMsg    orange none   NONE
Hi QuickFixLine  yellow bgline NONE

" ---- syntax ----
Hi Comment       gray   none   italic
Hi Constant      purple none   NONE
Hi String        yellow none   NONE
Hi Character     yellow none   NONE
Hi Number        purple none   NONE
Hi Float         purple none   NONE
Hi Boolean       purple none   NONE

Hi Identifier    fg     none   NONE
Hi Function      green  none   NONE

Hi Statement     red    none   NONE
Hi Conditional   red    none   NONE
Hi Repeat        red    none   NONE
Hi Label         red    none   NONE
Hi Operator      red    none   NONE
Hi Keyword       red    none   NONE
Hi Exception     red    none   NONE

Hi PreProc       red    none   NONE
Hi Include       red    none   NONE
Hi Define        red    none   NONE
Hi Macro         green  none   NONE
Hi PreCondit     red    none   NONE

Hi Type          blue   none   italic
Hi StorageClass  red    none   italic
Hi Structure     blue   none   italic
Hi Typedef       blue   none   italic

Hi Special       purple none   NONE
Hi SpecialChar   purple none   NONE
Hi Tag           red    none   NONE
Hi Delimiter     gray2  none   NONE
Hi SpecialComment gray  none   italic
Hi Debug         orange none   NONE

Hi Underlined    green  none   underline
Hi Ignore        gray   none   NONE
Hi Error         red    none   underline
Hi Todo          purple none   bold

" ---- diagnostics / spell ----
Hi SpellBad      red    none   undercurl
Hi SpellCap      orange none   undercurl
Hi SpellRare     purple none   undercurl
Hi SpellLocal    blue   none   undercurl

" ---- diffs ----
Hi DiffAdd       none   diffa  NONE
Hi DiffDelete    none   diffd  NONE
Hi DiffChange    none   diffc  NONE
Hi DiffText      none   difft  NONE
Hi diffAdded     green  none   NONE
Hi diffRemoved   red    none   NONE
Hi diffChanged   orange none   NONE
Hi diffFile      yellow none   NONE
Hi diffLine      blue   none   NONE
Hi diffIndexLine purple none   NONE

" ---- language touch-ups matching the TextMate scopes ----
hi! link vimVar          Identifier
hi! link vimCommentTitle Todo
hi! link jsonKeyword     Normal
hi! link yamlBlockMappingKey Statement
hi! link htmlTag         Delimiter
hi! link htmlEndTag      Delimiter
hi! link htmlTagName     Tag
hi! link htmlArg         Type
hi! link cssClassName    Function
hi! link cssIdentifier   Debug
hi! link markdownHeadingDelimiter Title
hi! link markdownCode    Debug
hi! link markdownUrl     Underlined
hi! link shOption        Type
hi! link typescriptParens Delimiter

delcommand Hi

if has('terminal') || has('nvim')
  let g:terminal_ansi_colors = [
    \ '#273136', '#ff6d7e', '#a2e57b', '#ffed72',
    \ '#7cd5f1', '#baa0f8', '#7cd5f1', '#b8c4c3',
    \ '#545f62', '#ff6d7e', '#a2e57b', '#ffed72',
    \ '#7cd5f1', '#baa0f8', '#7cd5f1', '#f2fffc' ]
endif
