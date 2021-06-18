#!/bin/bash

#kill gsettings instance run by this $$ process
#shellcheck disable=2064
trap "kill \$(pgrep gsettings -P $$)" EXIT

function echo_lang {
  lang="$1"
  lang=${lang##[(\'xkb\', \'}
  lang=${lang:0:2}
  if [ "$lang" = "us" ]; then
    echo ""
  else
    echo "#[align=left bold fg=#ffffff bg=#ff0000 fill=#ff0000] ${lang^^} "
  fi
}

#Echo initial
echo_lang "$(gsettings get org.gnome.desktop.input-sources mru-sources)"

#Listen further changes
gsettings monitor org.gnome.desktop.input-sources mru-sources | while read -r lang; do
  echo_lang "${lang##mru-sources: }"
done
