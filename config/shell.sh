if [ ! -d ~/.profile.d ]; then
  info "Configuring shells..."
  {
    ln -s $DOTFILES_HOME/shell-rc.d $HOME/.profile.d
  } &>$LOGFILE || abort "Error adding shell config!"
fi

if [ ! -d ~/.bash.profile.d ]; then
  info "Configuring bash..."
  {
    ln -s $DOTFILES_HOME/bash.profile.d $HOME/.bash.profile.d
  } &>$LOGFILE || abort "Error adding bash config!"
fi

if [ ! -d ~/.zsh.profile.d ] || [ ! -r ~/.zprofile ]; then
  info "Configuring zsh..."
  {
    ln -s $DOTFILES_HOME/shell-rc.sh $HOME/.zshrc &&
    ln -s $DOTFILES_HOME/zsh.profile.d $HOME/.zsh.profile.d
  } &>$LOGFILE || abort "Error adding zsh config!"
fi

good "Shells are configured..."
