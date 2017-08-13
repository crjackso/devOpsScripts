#!/bin/sh

brew install git

# Globally ignore certain files (ie: .DS_Store)
echo .DS_Store > ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
