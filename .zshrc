# ============================================
# Zsh Configuration
# All-in-one configuration file
# ============================================

# ============================================
# Environment Variables
# ============================================

# Basic PATH setup
export PATH=$HOME/bin:/usr/local/bin:/opt/homebrew/bin:$HOME/.local/bin:$PATH

# Starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# Oh-My-Zsh
export ZSH="$HOME/.config/oh-my-zsh"

# Locale settings
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# ============================================
# Tool Initialization
# ============================================

# OrbStack
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# g (Go Version Manager)
[ -s "${HOME}/.g/env" ] && \. "${HOME}/.g/env"

# Go bin directory
export PATH="$HOME/go/bin:$PATH"

# Cargo (Rust) - only if installed
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Local bin - only if exists
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Conda
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup

# Additional PATH entries
export PATH="$PATH:/Users/leo/Library/Application Support/JetBrains/Toolbox/scripts"
export PATH="/Users/leo/.codeium/windsurf/bin:$PATH"

# ============================================
# Oh-My-Zsh Configuration
# ============================================

# Plugins
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
)

source $ZSH/oh-my-zsh.sh

# Starship init (after oh-my-zsh to override prompt)
eval "$(starship init zsh)"

# ============================================
# Aliases
# ============================================

alias dotfiles='git --git-dir $HOME/.dotfiles --work-tree $HOME'
alias avante='nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'
# 常用快捷命令
alias dot='dotfiles'  # 简写
alias dot-status='dotfiles status'
alias dot-push='dotfiles push'
alias dot-pull='dotfiles pull'

# ============================================
# Functions
# ============================================

# Set terminal title to current directory
precmd () {
    print -Pn "\e]0;%m:%~\a"
}

# Unalias 'g' if it exists (conflict with go version manager)
if [[ -n $(alias g 2>/dev/null) ]]; then
    unalias g
fi

# ============================================
# Private Configuration
# ============================================

# Load private configuration if it exists
[[ -f ~/.zshrc.private ]] && source ~/.zshrc.private
export PATH="$HOME/.local/bin:$PATH"

# Remove problematic rg alias from Claude Code
unalias rg 2>/dev/null || true

# Use local bin fd and rg
export PATH="$HOME/.local/bin:$PATH"
