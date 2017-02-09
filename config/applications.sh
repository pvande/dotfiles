function installed-version() {
  local app="/Applications/$1.app"
  [ -r "$app" ] && xattr -p "dev.bootstrap.cache:$2" "$app" 2>/dev/null || echo '-'
}

function download-app() {
  local name="$1"
  local url="$2"
  local target="$3"
  local etag="If-None-Match: $4"
  local date="If-Modified-Since: $5"

  # TODO: Log if non-403 response *before* downloading file.
  curl -fsSLv "$url" --header "$etag" --header "$date" -o "$target" 2>&1
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
  local name="${1//: *}"
  local url="${1//*: }"

  local download=$(mktemp)
  unlink $download

  local etag=$(installed-version "$name" etag)
  local date=$(installed-version "$name" date)
  local xsum=$(installed-version "$name" xsum)

  local headers=$(download-app "$name" "$url" "$download" "$etag" "$date")

  if [ -s $download ] && [ $(md5 -q $download) != $xsum ]; then
    etag="$(echo "$headers" | grep -i 'etag:' | awk '{ print $3 }' | sed 's/"//g')"
    date="$(echo "$headers" | grep -i 'last-modified' | sed 's/< Last-Modified: //')"
    xsum="$(md5 -q $download)"

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
      chmod g+w "/Applications/$name.app" &&
      ([ -z "$etag" ] || xattr -w 'dev.bootstrap.cache:etag' "$etag" "/Applications/$name.app") &&
      ([ -z "$date" ] || xattr -w 'dev.bootstrap.cache:date' "$date" "/Applications/$name.app") &&
      ([ -z "$xsum" ] || xattr -w 'dev.bootstrap.cache:xsum' "$xsum" "/Applications/$name.app")
    } &>$LOGFILE || abort "Could not install $name!"
  fi
  good "$name is up-to-date..."
}

mappings="
  'Google Chrome': 'https://dl.google.com/chrome/mac/stable/GoogleChrome.dmg'
  'Atom': 'https://atom.io/download/mac'
  'Github Desktop': 'https://central.github.com/mac/latest'
  'Spectacle': 'https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.2.zip'
  'WMail': 'https://github.com/Thomas101/wmail/releases/download/v2.0.0/WMail_2_0_0_osx.dmg'
  'TogglDesktop': 'https://github.com/toggl/toggldesktop/releases/download/v7.4.7/TogglDesktop-7_4_7.dmg'
  'Slack': 'https://slack.com/ssb/download-osx'
"

export -f info warn abort good
export -f install-app installed-version download-app is-dmg is-zip is-tarball mount-app
echo "$mappings" | xargs -L1 -I @ -P16 bash -c "install-app '@'"
unset -f install-app installed-version download-app is-dmg is-zip is-tarball mount-app
