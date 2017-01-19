function cache-hint() {
  local url="$1"
  local headers="$(curl -fsSLI "$url" 2>/dev/null)"
  local hint=$(echo "$headers" | grep -i 'etag:' | awk '{ print $2 }' | sed 's/"//g')
  [ -z "$hint" ] && hint=$(echo "$headers" | grep -i 'last-modified')
  echo "$hint"
}

function installed-version() {
  local app="/Applications/$1.app"
  [ -r "$app" ] && xattr -p 'dev.bootstrap:checksum' "$app" 2>/dev/null || echo '-'
}

function download-app() {
  local name="$1"
  local url="$2"
  local target="$3"

  info "Downloading $name from $url..."
  curl -fsSL "$url" > "$target" 2>&1
}

function is-dmg() {
  hdiutil imageinfo -format "$1" &>/dev/null
}

function is-zip() {
  file $1 | grep -q 'Zip archive data'
}

function is-tarball() {
  file $1 | grep -q '\(gzip\|bzip2\) archive data'
}

function mount-app() {
  local download="$1"
  local mount="$2"

  if is-dmg $download; then
    hdiutil attach -readwrite -shadow -nobrowse -mountpoint $mount $download
  elif is-zip $download; then
    unzip $download -d $mount
  elif is-tarball $download; then
    tar -xzC $mount -f $download
  else
    echo "Unknown file type: $(file $download)"
    false
  fi
}

function install-app() {
  local name="$1"
  local url="$2"

  local download=$(mktemp)
  unlink $download

  local installed=$(installed-version "$name")
  local hint=$(cache-hint "$url")

  if [ "$installed" != '-' ] && [ -z "$hint" ]; then
    download-app "$name" "$url" "$download"
    hint=$(md5 -q $download)
  fi

  if [ "$installed" == '-' ] || [ "$installed" != "$hint" ]; then
    [ -e $download ] || download-app "$name" "$url" "$download"

    local mount=$(mktemp -d)
    LOGFILE="${TMPDIR}/install-app-${name// /-}.log"
    {
      mount-app $download $mount &&
      [ -e "$mount/$name.app" ] || {
        echo "$name.app not found -- did you mean:"
        ls "$mount/*.app"
        false
      } &&

      ditto --noqtn "$mount/$name.app" "/Applications/$name.app" &&
      xattr -w 'dev.bootstrap:checksum' "$hint" "/Applications/$name.app"
    } &>$LOGFILE || abort "Could not install $name!"
  fi
  good "$name is up-to-date..."
}

install-app 'Google Chrome' 'https://dl.google.com/chrome/mac/stable/GoogleChrome.dmg'
install-app 'Atom' 'https://atom.io/download/mac'
install-app 'Github Desktop' 'https://central.github.com/mac/latest'
install-app 'SizeUp' 'http://www.irradiatedsoftware.com/download/SizeUp.zip'
install-app 'Spectacle' 'https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.2.zip'
install-app 'WMail' 'https://github.com/Thomas101/wmail/releases/download/v2.0.0/WMail_2_0_0_osx.dmg'
