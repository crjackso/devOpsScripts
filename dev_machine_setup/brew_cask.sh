#!/bin/bash

sh ./brew_install_upgrade.sh

brew tap homebrew/cask-cask
brew tap homebrew/cask-versions

# Install packages
apps=(
    alfred
    1password
    dropbox
    google-drive-file-stream
    flux
    iterm2
    visual-studio-code
    google-chrome
    google-chrome-canary
    nordvpn
    spotify
    slack
    transmission
    vlc
    docker
)

brew cask install "${apps[@]}"
