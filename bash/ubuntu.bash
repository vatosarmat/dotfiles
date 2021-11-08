alias apt_lsppa="apt policy"
alias upa='update-alternatives'
alias supa='sudo update-alternatives'

#List package executables
function dpkg__lsexe {
  test -n "$1" || {
    echo "No package name" >&2
    return 1
  }
  dpkg -L "$1" | while read -r filePath; do test -x "$filePath" -a -f "$filePath" && echo "$filePath"; done
}

#List package files
function dpkg__lsf {
  test -n "$1" || {
    echo "No package name" >&2
    return 1
  }
  w="${2:-48}"
  p=""
  for f in $(dpkg -L "$1" | sort); do
    if [[ "$f" != "$p"* ]] && [[ "$p" != "/." ]]; then
      printf "%-${w}s    %s\n" "$p" "$(file -bi "$p")"
    fi
    p=$f
  done
  printf "%-${w}s   %s\n" "$p" "$(file -bi "$p")"
}

function apt__search {
  test -n "$1" || {
    echo "No name to search" >&2
    return 1
  }
  apt search -n "\b$1\b"
}

function apt__lsppa {
  find /etc/apt/ -name \*.list | while IFS=$'\n' read -r file; do
    # echo "$RED$file$SGR0"
    # Extract from between 'dev ' and 'start_of_comment or end of line'
    grep --color=never -Po "(?<=^deb\s).*?(?=#|$)" "$file" | while read -r entry; do
      host=$(echo "$entry" | cut -d/ -f3)
      user=$(echo "$entry" | cut -d/ -f4)
      ppa=$(echo "$entry" | cut -d/ -f5)
      # printf "%-32s%-48s%-48s\n" "$host" "$ppa" "$user"
      if [[ "ppa.launchpad.net" = "$host" ]]; then
        echo "ppa:$user/$ppa"
      else
        echo "$entry"
      fi
    done
  done
}
