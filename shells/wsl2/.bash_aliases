# ~/.bash_aliases: separated custom aliases & functions

## ------------------ ##
## Aliases            ##
## ------------------ ##

# jump to windows home directory
alias go-home='cd /mnt/c/Users/david'

alias goto-projects='cd ~/sandbox/projects'
alias list-services='systemctl list-units -at service'

alias reload='source ~/.profile'

# neat alais to open current dir in windows explorer
alias explorer='explorer.exe $(wslpath -w $(pwd))'

# k8s
alias kc=kubectl
#alias kustomize='kubectl kustomize'

## ------------------ ##
## Functions          ##
## ------------------ ##

# cht.sh
cht() {
    curl "cheat.sh/$*"
}

# uv venv helper
venv() {
    if [ -d ".venv" ]; then
        source .venv/bin/activate
    else
        uv venv .venv
    fi
    source .venv/bin/activate
}

llmd() {
  # see https://github.com/simonw/llm/issues/12 for more solutions to paging the output of llm
  # and especially https://github.com/simonw/llm/issues/1112#issuecomment-3433913273
  llm "$@" | glow
}

# from https://github.com/simonw/llm/issues/1112#issuecomment-3433913273
llmd-stream() {
    uv tool run \
     --with git+https://github.com/AdrianVollmer/llm-richify.git \
     --with git+https://github.com/simonw/llm-openai-via-codex.git \
     --from git+https://github.com/AdrianVollmer/llm.git@feature/ui-plugins \
     llm -m openai-codex/gpt-5.5 "$@"
}

llm-logs() {
    llm logs -n 3
}
