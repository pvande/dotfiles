for sh in /usr/local/etc/bash_completion.d/*; do
  [ -r "${sh}" ] && source "${sh}"
done
