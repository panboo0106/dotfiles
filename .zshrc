# ============================================
# Zsh Configuration
# All-in-one configuration file
# ============================================

# ============================================
# Environment Variables
# ============================================

# Basic PATH setup (~/.local/bin ahead of homebrew so uv's default python3,
# fd, rg win; mise activate at the bottom still wins for node/go)
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:/opt/homebrew/bin:$PATH

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

# OrbStack init lives in ~/.zprofile
# Node/Go versions are managed by mise (activated at the bottom of this file)

# Go bin directory (GOPATH bin, valid regardless of Go manager)
export PATH="$HOME/go/bin:$PATH"

# Cargo env is sourced in ~/.zshenv

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

# ============================================
# Private Configuration
# ============================================

# Load private configuration if it exists
# [[ -f ~/.zshrc.private ]] && source ~/.zshrc.private

# Remove problematic rg alias from Claude Code
unalias rg 2>/dev/null || true

# Ghostty theme toggle (F5)
toggle_ghostty_theme() { ~/.config/ghostty/toggle-theme.sh }
zle -N toggle_ghostty_theme
bindkey '^[[15~' toggle_ghostty_theme

# mise (polyglot version manager - node/python/go per-project pins)
# Must stay last: later PATH prepends (e.g. ~/.local/bin, which contains a
# uv-installed global python) would otherwise shadow mise's resolved paths.
eval "$(mise activate zsh)"
