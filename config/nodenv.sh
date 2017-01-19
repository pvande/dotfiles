if !(installed nodenv); then
  info "Installing nodenv from Homebrew..."
  {
    $BINDIR/brew install nodenv
  } &>$LOGFILE || abort "Could not install nodenv!"
fi
good "nodenv is present..."

export postinstall_nodenv="-"
