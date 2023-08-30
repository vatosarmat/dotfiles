#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.bash
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS

# Key bindings
# ------------
__fzf_select__() {
  local cmd opts
  cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse ${FZF_DEFAULT_OPTS-} ${FZF_CTRL_T_OPTS-} -m"
  eval "$cmd" |
    FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) "$@" |
    while read -r item; do
      printf '%q ' "$item" # escape special chars
    done
}

__fzf_history_source__() {
  #fc -lnr -2147483648 - list all commands from history list, omit numbers, reverse order, -count
  #builtin history - get the last command from history list(here it is only to get its number)
  #last_hist - string of form '2187  cmd args', but it is used in int context, so casted to int
  #perl - -n - while(<>) loop, -e - program, -l0 - line terminator 0
  local perl_script

  # empty delimiter - read all input into variable perl_script
  read -r -d '' perl_script << 'PERL'
# there is no use strict; so variables declarations are not required
# BEGIN block runs before 'perl -n' loop
BEGIN { 
  $/ = "\0\n";
  open(TF, '<', $ENV{"HOME"}."/.bash_history_trash");
  while(<TF>) {
    chomp;
    # printf STDERR ("trash: %s\n", $_);
    $trash_table{$_} = 1;
  }

  # read-skip initial \t
  getc; 
  # input lines separator, to be stripped because of -l0 argument
  $/ = "\n\t"; 
  # index
  $HISTCMD = $ENV{last_hist} + 1 
} 

chomp;
# clear initial space or * in input line
s/^[ *]//;

if(!$trash_table{$_}) {
  # $_ - input string, $. - its number
  # if inputs string not yet seen, print it with its number, separated by \t
  print $HISTCMD - $. . "\t$_" if !$seen{$_}++
}
PERL
  builtin fc -lnr -2147483648 |
    # last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -e "$perl_script"
    last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e "$perl_script"
}

if [[ $- =~ i ]]; then

  __fzfcmd() {
    [[ -n "${TMUX_PANE-}" ]] && { [[ "${FZF_TMUX:-0}" != 0 ]] || [[ -n "${FZF_TMUX_OPTS-}" ]]; } &&
      echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
  }

  fzf-file-widget() {
    local selected="$(__fzf_select__ "$@")"
    READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
    READLINE_POINT=$((READLINE_POINT + ${#selected}))
  }

  __fzf_cd__() {
    local cmd opts dir
    cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
    opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-} +m"
    dir=$(eval "$cmd" | FZF_DEFAULT_OPTS="$opts" $(__fzfcmd)) && printf 'builtin cd -- %q' "$dir"
  }

  __fzf_history__() {
    local output opts
    opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} +m --read0"

    # --scheme=history
    # -n2..,.. -
    # fzf --query READLINE_LINE called with trich DEFAULT_OPTS and history lines as input
    output=$(
      __fzf_history_source__ |
        FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) --query "$READLINE_LINE"
    ) || return
    # cut off prefix with entry number delimited by tab
    READLINE_LINE=${output#*$'\t'}
    if [[ -z "$READLINE_POINT" ]]; then
      echo "$READLINE_LINE"
    else
      READLINE_POINT=0x7fffffff
    fi
  }

  # Required to refresh the prompt after fzf
  bind -m emacs-standard '"\er": redraw-current-line'

  bind -m vi-command '"\C-z": emacs-editing-mode'
  bind -m vi-insert '"\C-z": emacs-editing-mode'
  bind -m emacs-standard '"\C-z": vi-editing-mode'

  if ((BASH_VERSINFO[0] < 4)); then
    # CTRL-T - Paste the selected file path into the command line
    bind -m emacs-standard '"\C-t": " \C-b\C-k \C-u`__fzf_select__`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
    bind -m vi-command '"\C-t": "\C-z\C-t\C-z"'
    bind -m vi-insert '"\C-t": "\C-z\C-t\C-z"'

    # CTRL-R - Paste the selected command from history into the command line
    bind -m emacs-standard '"\C-r": "\C-e \C-u\C-y\ey\C-u"$(__fzf_history__)"\e\C-e\er"'
    bind -m vi-command '"\C-r": "\C-z\C-r\C-z"'
    bind -m vi-insert '"\C-r": "\C-z\C-r\C-z"'
  else
    # CTRL-T - Paste the selected file path into the command line
    bind -m emacs-standard -x '"\C-t": fzf-file-widget'
    bind -m vi-command -x '"\C-t": fzf-file-widget'
    bind -m vi-insert -x '"\C-t": fzf-file-widget'

    # CTRL-R - Paste the selected command from history into the command line
    bind -m emacs-standard -x '"\C-r": __fzf_history__'
    bind -m vi-command -x '"\C-r": __fzf_history__'
    bind -m vi-insert -x '"\C-r": __fzf_history__'
  fi

  # ALT-C - cd into the selected directory
  bind -m emacs-standard '"\ec": " \C-b\C-k \C-u`__fzf_cd__`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d"'
  bind -m vi-command '"\ec": "\C-z\ec\C-z"'
  bind -m vi-insert '"\ec": "\C-z\ec\C-z"'

fi
