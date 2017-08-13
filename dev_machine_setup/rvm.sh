#!/bin/sh

# check if gpg is installed...if not, then install it
if brew ls --versions gpg > /dev/null; then
  echo "\033[32mHomeBrew has detected the package 'gpg' is installed.  Skipping installation..."
  echo -e "\033[0m"
else
  echo "\033[32mHomeBrew will install gpg"
  echo -e "\033[0m"
  brew install gpg
fi

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

echo "\033[32mInstalling rvm"
echo "\033[0m"
\curl -L https://get.rvm.io | bash -s stable
