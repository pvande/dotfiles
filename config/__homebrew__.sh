# Install the applications listed in the Brewfile.
if ! brew bundle check --file="${DOTFILES_HOME}/Brewfile" &>/dev/null; then
  info "Applying Brewfile..."
  brew bundle --file="${DOTFILES_HOME}/Brewfile" &>$LOGFILE || abort "Error applying Brewfile!"
fi
good "Brewfile is up-to-date..."

export postinstall_git="-"
export postinstall_mas="-"
export postinstall_gettext="-"
