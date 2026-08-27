
export PATH=/opt/homebrew/bin:$PATH
#export DOCKER_HOST=unix:///var/run/docker.sock

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.bash 2>/dev/null || :
. "$HOME/.cargo/env"

. "$HOME/.local/bin/env"

# Added by Antigravity
export PATH="/Users/leo/.antigravity/antigravity/bin:$PATH"

# Source .bashrc for interactive shell settings
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
