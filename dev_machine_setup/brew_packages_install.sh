#!/bin/sh

sh ./brew_install_upgrade.sh

apps=(
    bash
    bash-completion2
    rvm
    nvm
    mongodb
    git
    coreutils
    moreutils
    findutils
    gnu-sed --with-default-names
    grep --with-default-names
    homebrew/completions/brew-cask-completion
    homebrew/dupes/grep
    homebrew/dupes/openssh
    imagemagick --with-webp
    python
    the_silver_searcher
    tree
    wget
    yarn
    gpg
)

brew install "${apps[@]}"

# Remove outdated versions from the cellar
brew cleanup
