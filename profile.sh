# Source the contents of the .profile.d directory
if [ -r ~/.profile.d ]; then
  for sh in ~/.profile.d/*.sh ; do
    [ -r "${sh}" ] && source "${sh}"
  done
fi
unset sh

# Source the contents of any shell-specific .profile.d directory
if [ -r ~/.${0##*[/-]}.profile.d ]; then
  for sh in ~/.${0##*[/-]}.profile.d/*.sh ; do
    [ -r "${sh}" ] && source "${sh}"
  done
fi
unset sh
