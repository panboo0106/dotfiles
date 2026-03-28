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

# Additional PATH entries

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

# Autosuggestions color - compatible with both dark and light themes
# Uses gray (color 8) with underline for visibility in any theme
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=242,underline"

source $ZSH/oh-my-zsh.sh

# Starship init (after oh-my-zsh to override prompt)
eval "$(starship init zsh)"

# ============================================
# Modern CLI Tools (bat, eza)
# ============================================

# bat as cat replacement
alias cat='bat'
compdef bat=cat

# eza as ls replacement
alias ls='eza'
alias ll='eza -l'
alias la='eza -la'
alias lt='eza --tree --level=2'
alias lta='eza --tree --level=2 -a'
compdef eza=ls

# ============================================
# Dotfiles (Bare Repository)
# ============================================

# dotfiles 函数
dotfiles() {
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

alias dot='dotfiles'
alias avante='nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'

# 快速操作函数
dot-add() {
  dotfiles add "$@" && dotfiles status
}

dot-commit() {
  dotfiles commit -m "${1:-update dotfiles}"
}

dot-sync() {
  dotfiles add -u && dotfiles commit -m "sync: $(date +%Y-%m-%d)" && dotfiles push
}

dot-list() {
  git --git-dir=$HOME/.dotfiles --work-tree=$HOME ls-files
}

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
# [[ -f ~/.zshrc.private ]] && source ~/.zshrc.private
export PATH="$HOME/.local/bin:$PATH"

# Remove problematic rg alias from Claude Code
unalias rg 2>/dev/null || true

# Use local bin fd and rg
export PATH="$HOME/.local/bin:$PATH"
