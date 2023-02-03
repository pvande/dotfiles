mkdir -p $XDG_CONFIG_HOME/git
touch $XDG_CONFIG_HOME/git/{attributes,config,ignore}

git config --global user.name 'Pieter van de Bruggen'
git config --global user.email pvande@gmail.com
good "Git is properly configured..."
