fonts="$HOME/Library/Fonts"

if !(ls $fonts/Meslo.otf &>/dev/null); then
  info "Installing Meslo for Powerline..."
  repo="https://github.com/powerline/fonts/raw/master"

  ### Hints ###
  # {L,M,S} - Line spacing?
  #   A line spacing of 0.9 works best with M...
  # {DZ,} - Dotted Zero vs Slashed Zero

  # font="Meslo LG L DZ Regular for Powerline.otf"
  # font="Meslo LG L Regular for Powerline.otf"
  # font="Meslo LG M DZ Regular for Powerline.otf"
  font="Meslo LG M Regular for Powerline.otf"
  # font="Meslo LG S DZ Regular for Powerline.otf"
  # font="Meslo LG S Regular for Powerline.otf"

  curl -fsSL "$repo/Meslo/${font// /%20}" > "${fonts}/Meslo.otf"
fi
good "Powerline fonts installed..."
