#!/bin/bash
# macOS defaults — idempotent, safe to re-run

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false

# Keyboard
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Trackpad
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Menu bar — tighten status item spacing (per-host; takes effect on re-login)
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 12

# Screenshots
defaults write com.apple.screencapture location -string "$HOME/Downloads"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Keep windows on quit so apps (iTerm2 especially) can restore their contents
# — System Settings > Desktop & Dock > "Close windows when quitting" = off
# (https://iterm2.com/why_no_content.html)
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true

# iTerm2 — never block logout/restart with "close sessions?" dialogs
# (the per-profile "Prompt before closing" is set to Never in the GUI; iTerm2
# rewrites its plist on quit, so quit it before re-running this)
defaults write com.googlecode.iterm2 PromptOnQuit -bool false
defaults write com.googlecode.iterm2 OnlyWhenMoreTabs -bool false

# Restart affected apps
for app in Finder Dock SystemUIServer; do
  killall "$app" &>/dev/null || true
done

echo "macOS defaults applied."
