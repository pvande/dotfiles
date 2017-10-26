# if !(installed goenv); then
#   info "Installing goenv from Homebrew..."
#   {
#     $BINDIR/brew install goenv
#     mkdir -p /usr/local/var/goenv/{shims,versions}
#   } &>$LOGFILE || abort "Could not install goenv!"
# fi
# good "goenv is present..."
#
# global-gitignore .go-version
#
# export postinstall_goenv="-"
