#!/bin/bash

abort() {
  echo $'\e[31m!!!' "$@" $'\e[m'
  exit 1
}

notice() {
  echo $'\e[32m###\e[m' "$@"
}

talk() {
  echo $'\e[36m...\e[m' "$@"
}

sudo_permissions="[ '$(stat -f '%Su:%p' /usr/local 2>&1)' != '$(whoami):40775' ]"
sudo_xcode_tools="[ ! -x $('/usr/bin/xcode-select' -print-path 2>/dev/null || echo '/dev/null')/usr/bin/git ]"

if $sudo_permissions || $sudo_xcode_tools; then
  notice "Super-user privileges are required for the following changes:"
  $sudo_permissions && notice "  Fixing permissions on /usr/local"
  $sudo_xcode_tools && notice "  Installing the Xcode Command Line Tools"
  sudo -k
  sudo -v

  if $sudo_permissions; then
    talk "Fixing permissions on /usr/local..."
    sudo mkdir -p /usr/local &&
    sudo chown -R $(whoami):staff /usr/local &&
    chmod -R 0775 /usr/local
  fi

  if $sudo_xcode_tools; then
    talk "Installing the Xcode Command Line Tools..."
    sudo touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    sudo /usr/sbin/softwareupdate -i "$(softwareupdate -l | grep -B 1 -E "Command Line (Developer|Tools)" | awk -F"*" '/^ +\\*/ {print $2}' | sed 's/^ *//' | tail -n1)" &>/dev/null
    sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    sudo '/usr/bin/xcode-select' --switch /Library/Developer/CommandLineTools &>/dev/null
  fi

  notice "Releasing super-user privileges."
  sudo -k
fi
