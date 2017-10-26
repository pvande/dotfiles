# if !(installed leiningen); then
#   info "Installing leiningen from Homebrew..."
#   {
#     $BINDIR/brew install leiningen
#   } &>$LOGFILE || abort "Could not install leiningen!"
# fi
# good "leiningen is present..."
#
# export postinstall_leiningen="-"
