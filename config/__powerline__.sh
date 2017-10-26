fonts="$HOME/Library/Fonts"

if !(ls $fonts/Meslo.ttf &>/dev/null); then
  info "Installing Meslo for Powerline..."
  repo="https://github.com/powerline/fonts/raw/master"

  ### Hints ###
  # {L,M,S} - Line spacing?
  #   A line spacing of 0.9 works best with M...

  # font="Meslo LG L Regular for Powerline.ttf"
  font="Meslo LG M Regular for Powerline.ttf"
  # font="Meslo LG S Regular for Powerline.ttf"

  curl -fsSL "$repo/Meslo%20Slashed/${font// /%20}" > "${fonts}/Meslo.ttf"
fi
good "Powerline fonts installed..."
