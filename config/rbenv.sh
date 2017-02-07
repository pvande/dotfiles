if !(installed rbenv); then
  info "Installing rbenv from Homebrew..."
  {
    $BINDIR/brew install rbenv &&
    $BINDIR/brew install rbenv-gemset &&
    $BINDIR/brew install ruby-build
  } &>$LOGFILE || abort "Could not install rbenv!"
fi
good "rbenv is present..."

global-gitignore .ruby-version
global-gitignore .rbenv-gemsets

export postinstall_autoconf="-"
export postinstall_openssl="-"
export postinstall_rbenv="-"
