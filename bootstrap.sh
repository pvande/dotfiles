#!/bin/bash

HOMEBREW_HOME="/usr/local/Homebrew"
HOMEBREW_CORE_HOME="${HOMEBREW_HOME}/Library/Taps/homebrew/homebrew-core"
HOMEBREW_TARBALL="https://github.com/Homebrew/brew/tarball/master"
HOMEBREW_CORE_TARBALL="https://github.com/Homebrew/homebrew-core/tarball/master"
PROJECTS_HOME="~/Projects"
DOTFILES_REPO="https://github.com/pvande/dotfiles"

abort() {
  echo '‼️ ' "$@"
  exit 1
}

announce() {
  echo '📢 ' "$@"
}

warn() {
  echo '⛔️ ' "$@"
}

info() {
  echo '💡 ' "$@"
}

good() {
  echo '✅ ' "$@"
}

announce "Bootstrapping $(hostname -s)"

sudo_permissions="[ '$(stat -f '%Su:%p' /usr/local 2>&1)' != '$(whoami):40775' ]"
sudo_xcode_tools="[ ! -x $('/usr/bin/xcode-select' -print-path 2>/dev/null || echo '/dev/null')/usr/bin/git ]"

if $sudo_permissions || $sudo_xcode_tools; then
  warn "Super-user privileges are required for the following changes:"
  $sudo_permissions && warn "  Fixing permissions on /usr/local"
  $sudo_xcode_tools && warn "  Installing the Xcode Command Line Tools"
  sudo -k
  sudo -v

  if $sudo_permissions; then
    info "Fixing permissions on /usr/local..."
    sudo mkdir -p /usr/local &&
    sudo chown -R $(whoami):staff /usr/local &&
    chmod -R 0775 /usr/local
  fi

  if $sudo_xcode_tools; then
    info "Installing the Xcode Command Line Tools..."
    sudo touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    sudo /usr/sbin/softwareupdate -i "$(softwareupdate -l | grep -B 1 -E "Command Line (Developer|Tools)" | awk -F"*" '/^ +\\*/ {print $2}' | sed 's/^ *//' | tail -n1)" &>/dev/null
    sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    sudo '/usr/bin/xcode-select' --switch /Library/Developer/CommandLineTools &>/dev/null
  fi

  warn "Releasing super-user privileges."
  sudo -k
fi
good "Permissions on /usr/local are correct..."
good "Xcode Command Line Tools are present..."

LOGFILE="${TMPDIR}/homebrew.log"
if [ ! -x /usr/local/bin/brew ]; then
  info "Installing Homebrew..."
  mkdir -p /usr/local/{Cellar,Homebrew,Frameworks,bin,etc,include,lib,opt,sbin,share{,/zsh{,/site-functions}},var}
  mkdir -p ~/Library/Caches/Homebrew
  {
    echo "Downloading and unpacking Homebrew..." > $LOGFILE &&
    cd $HOMEBREW_HOME &&
    /bin/bash -o pipefail -c "/usr/bin/curl -fsSL $HOMEBREW_TARBALL | /usr/bin/tar xz -m --strip 1" &&
    ln -sf ${HOMEBREW_HOME}/bin/brew /usr/local/bin/brew &&

    echo "Downloading and unpacking Homebrew Core..." >> $LOGFILE &&
    mkdir -p $HOMEBREW_CORE_HOME &&
    cd $HOMEBREW_CORE_HOME &&
    /bin/bash -o pipefail -c "/usr/bin/curl -fsSL $HOMEBREW_CORE_TARBALL | /usr/bin/tar xz -m --strip 1" &&

    echo 'Running `brew update --force`...' >> $LOGFILE &&
    brew update --force 2>&1 | cat >> $LOGFILE
  } || abort "Could not install Homebrew!  See $LOGFILE for details."
else
  {
    /usr/local/bin/brew update 2>&1 | cat >> $LOGFILE
  } || abort "Could not update Homebrew!  See $LOGFILE for details."
fi
good "Homebrew is up-to-date..."

PATH="/usr/local/bin:$PATH"

LOGFILE="${TMPDIR}/git.log"
if !(/usr/local/bin/brew ls git &>/dev/null); then
  info "Installing Git from Homebrew..."
  {
    /usr/local/bin/brew install git &>$LOGFILE
  } || abort "Could not install Git!  See $LOGFILE for details."
fi
good "Git is present..."

LOGFILE="${TMPDIR}/dotfiles.log"
if [ ! -d $PROJECTS_HOME/dotfiles ]; then
  info "Cloning $DOTFILES_REPO to ~/Projects/dotfiles..."
  {
    git clone $DOTFILES_REPO $PROJECTS_HOME/dotfiles &>$LOGFILE
  } || abort "Could not clone $DOTFILES_REPO!  See $LOGFILE for details."
elif !(cd ~/Projects/dotfiles && git fetch -q && git status | grep -q 'up-to-date'); then
  info "Updating ~/Projects/dotfiles..."
  {
    cd ~/Projects/dotfiles &&
    git merge origin/master &>$LOGFILE
  } || abort "Could not update $DOTFILES_REPO!  See $LOGFILE for details."
fi
good "~/Projects/dotfiles is up-to-date..."

announce "All set!"
