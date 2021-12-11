alias vimi='vim -i .shada'
alias vimd="cd ~/dotfiles ; vim -i .shada bashrc.bash"
alias vim_update="nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"

function v {
  local project_markers="README README.md README.markdown EADME.rst package.json CMakeLists.txt Cargo.toml"
  for f in $project_markers; do
    if [[ -f "$f" ]]; then
      nvim -i '.shada' "$f"
      return
    fi
  done
  echo "No project marker found: $project_markers"
}

function lsp_log {
  local cmd=''
  # declare -ar pass=()
  declare -a skip_fixed=('"textDocument/documentHighlight"' '"$/progress"' '"$/status/report"')
  declare -ar skip_br=('"decoded"	{  id = [[:digit:]]\+,  jsonrpc = "2.0",  result = {}}')

  local is_reset is_follow is_diagnostic
  local OPTIND OPTARG OPTERR opt
  while getopts "rfd" opt; do
    case $opt in
      [r])
        is_reset=1
        ;;
      [f])
        is_follow=1
        ;;
      [d])
        is_diagnostic=1
        ;;
      *) ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ "$is_reset" ]]; then
    rm "$HOME/.cache/nvim/lsp.log"
    return
  fi

  if [[ "$is_follow" ]]; then
    cmd="tail -f"
  else
    cmd="cat"
  fi

  if [[ ! "$is_diagnostic" ]]; then
    skip_fixed+=('"textDocument/publishDiagnostics"')
  fi

  declare -a skip_fixed_args=()
  for b in "${skip_fixed[@]}"; do
    skip_fixed_args+=('-e' "$b")
  done

  declare -a skip_br_args=()
  for b in "${skip_br[@]}"; do
    skip_br_args+=('-e' "$b")
  done

  $cmd "$HOME/.cache/nvim/lsp.log" |
    grep --line-buffered -Fv "${skip_fixed_args[@]}" |
    grep --line-buffered -Gv "${skip_br_args[@]}" |
    sed --unbuffered -E -f "$HOME/.config/nvim/misc/lsp_log.sed" |
    bat --color=always --pager=never --style=plain -l lua
  # grep -F -e '"rpc.send.payload"' -e '"decoded"'
}
