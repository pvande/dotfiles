#!/bin/bash

abort() {
  echo $'\e[31m!!!\e[m' "$@" $'\e[m'
  exit 1
}

announce() {
  echo $'\e[34m***\e[m' "$@" $'\e[m'
}

warn() {
  echo $'\e[31m###\e[m' "$@" $'\e[m'
}

info() {
  echo $'\e[36m...\e[m' "$@" $'\e[m'
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

if [ ! -x /usr/local/bin/brew ]; then
  info "Installing Homebrew..."
  mkdir -p /usr/local/{Cellar,Homebrew,Frameworks,bin,etc,include,lib,opt,sbin,share{,/zsh{,/site-functions}},var}
  mkdir -p ~/Library/Caches/Homebrew
  {
    cd /usr/local/Homebrew &&
    echo "Downloading and unpacking Homebrew..." > $TMPDIR/homebrew-install.log &&
    /bin/bash -o pipefail -c '/usr/bin/curl -fsSL https://github.com/Homebrew/brew/tarball/master | /usr/bin/tar xz -m --strip 1' &&
    ln -sf /usr/local/Homebrew/bin/brew /usr/local/bin/brew &&
    mkdir -p /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core &&
    cd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core &&
    echo "Downloading and unpacking Homebrew Core..." >> $TMPDIR/homebrew-install.log &&
    /bin/bash -o pipefail -c '/usr/bin/curl -fsSL https://github.com/Homebrew/homebrew-core/tarball/master | /usr/bin/tar xz -m --strip 1' &&
    echo 'Running `brew update --force`...' >> $TMPDIR/homebrew-install.log &&
    brew update --force 2>&1 | cat >> $TMPDIR/homebrew-install.log
  } || abort "Could not install Homebrew!  See $TMPDIR/homebrew-install.log for details."
else
  info "Updating Homebrew..."
  {
    /usr/local/bin/brew update 2>&1 | cat >> $TMPDIR/homebrew-update.log
  } || abort "Could not update Homebrew!  See $TMPDIR/homebrew-update.log for details."
fi

announce "All set!"
