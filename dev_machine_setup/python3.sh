which -s brew
if [[ $? != 0 ]] ; then
    echo "Homebrew not found - Installing now..."
    sh ./brew_setup.sh
else
    brew update
    brew upgrade
fi

brew install python3
