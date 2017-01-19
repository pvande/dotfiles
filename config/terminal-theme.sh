dir="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
source $dir/.powerline.sh

startup=$(defaults read com.apple.Terminal "Startup Window Settings")
default=$(defaults read com.apple.Terminal "Default Window Settings")
if [ "$startup" != "Pro" ] || [ "$default" != "Pro" ]; then
  info "Updating Terminal defaults..."

  script='
  tell application "Terminal"
  set pro to first settings set where name is "Pro"
  set font name of pro to "Meslo LG M Regular for Powerline"
  set font size of pro to 20
  set font antialiasing of pro to true
  set background color of pro to "black"
  set default settings to pro
  set startup settings to pro
  repeat with w in windows
    repeat with t in tabs of w
      set current settings of t to pro
    end repeat
  end repeat
  end tell
  '

  echo "$script" | osascript 2>/dev/null
fi
good "Terminal is properly configured..."
