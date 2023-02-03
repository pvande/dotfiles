if [ ! -L ~/.profile.d ]; then
  info "Configuring shells..."
  {
    ln -s $DOTFILES_HOME/profile.d $HOME/.profile.d
  } &>$LOGFILE || abort "Error adding shell config!"
fi

if [ ! -L ~/.zsh.profile.d ] || [ ! -L ~/.zshrc ]; then
  info "Configuring zsh..."
  {
    ([ -L ~/.zsh.profile.d ] || ln -s $DOTFILES_HOME/zsh.profile.d $HOME/.zsh.profile.d) &&
    ([ -L ~/.zshrc ] || ln -s $DOTFILES_HOME/shell-rc.sh $HOME/.zshrc)
  } &>$LOGFILE || abort "Error adding zsh config!"
fi

good "Shells are configured..."
