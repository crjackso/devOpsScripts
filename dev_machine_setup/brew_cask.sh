#!/bin/bash

sh ./brew_install_upgrade.sh

# Install Caskroom
brew tap caskroom/cask
brew install brew-cask
brew tap caskroom/versions

# Install packages
apps=(
    alfred
    1password
    dropbox
    google-drive
    flux
    iterm2
    atom
    visual-studio-code
    google-chrome
    google-chrome-canary
    malwarebytes-anti-malware
    nordvpn
    glimmerblocker
    macdown
    spotify
    slack
    transmission
    vlc
    docker
)

brew cask install "${apps[@]}"
