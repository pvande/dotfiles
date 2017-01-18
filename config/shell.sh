if [ ! -d ~/.profile.d ] || [ ! -r ~/.profile ]; then
  info "Configuring shells..."
  {
    ln -s $DOTFILES_HOME/profile.sh $HOME/.profile &&
    ln -s $DOTFILES_HOME/profile.d $HOME/.profile.d
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
    ln -s $DOTFILES_HOME/profile.sh $HOME/.zprofile &&
    ln -s $DOTFILES_HOME/zsh.profile.d $HOME/.zsh.profile.d
  } &>$LOGFILE || abort "Error adding zsh config!"
fi

good "Shells are configured..."
