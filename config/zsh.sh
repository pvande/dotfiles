if !(installed zsh); then
  info "Installing zsh from Homebrew..."
  {
    $BINDIR/brew install zsh
  } &>$LOGFILE || abort "Could not install zsh!"
fi
good "zsh is present..."

export postinstall_zsh=""
current_shell=$(dscl . -read /Users/$USER UserShell | awk '{ print $2 }')
if [ $current_shell == "/usr/local/bin/zsh" ]; then
  postinstall_zsh+="-"
else
  postinstall_zsh+="To set zsh as your default login shell,\n"
  postinstall_zsh+="run \`chsh -s /usr/local/bin/zsh\`"
fi
