#https://davidmyers.dev/blog/how-to-fix-tab-completion-for-complex-git-aliases
source /usr/share/bash-completion/completions/git
GIT_COMPLETION_SHOW_ALL=1
alias g="git"
__git_complete g git
