# ============================================
# Zsh Configuration
# All-in-one configuration file
# ============================================

# ============================================
# Environment Variables
# Interactive-session values only (prompt, oh-my-zsh, proxy toggle).
# PATH & locale needed by ALL zsh processes live in ~/.zshenv.
# ============================================

# Starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# Oh-My-Zsh
export ZSH="$HOME/.config/oh-my-zsh"

# Proxy (Sinbox mixed port 7890), auto-set on shell startup.
# 临时关闭当前会话的代理:
#   unset https_proxy http_proxy all_proxy
export https_proxy=http://127.0.0.1:7890
export http_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890

# ============================================
# Tool Initialization
# ============================================

# OrbStack init lives in ~/.zprofile
# Toolchains: node/go via mise, python via uv (default install in
# ~/.local/bin, shadows Homebrew's copies, which only feed
# ansible/yamllint/gts). Run `mise use -g node@24` (etc.) to pin a toolchain
# under mise.

# PATH setup (base, ~/go/bin, ~/.local/bin/env) and cargo env live in
# ~/.zshenv so non-interactive shells see them too.

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
alias cat='bat -p'
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
  # Commit only explicitly staged changes. A clean index can still need a push.
  local diff_status=0
  dotfiles diff --cached --quiet || diff_status=$?
  case "$diff_status" in
    0) ;;
    1) dotfiles commit -m "sync: $(date +%Y-%m-%d)" || return $? ;;
    *) return "$diff_status" ;;
  esac
  dotfiles push
}

dot-list() {
  dotfiles ls-files
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
