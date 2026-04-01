# Dotfiles - 开发环境配置

个人 macOS 开发环境配置仓库（bare git 仓库管理）。

## 环境概览

- **Shell**: Zsh + Oh My Zsh + Starship
- **编辑器**: Neovim (LazyVim), Zed, VSCode
- **终端**: Kitty (主终端), WezTerm, Alacritty
- **输入法**: 鼠须管 (Squirrel) + 雾凇拼音
- **现代 CLI**: bat, eza, delta, gh, lazygit
- **语言**: Node.js (nvm), Go (g), Python (uv), Rust

---

## 新机器恢复流程

### 第 0 步：配置 SSH Key

```bash
# 生成 SSH key 并添加到 GitHub，否则无法克隆 bare 仓库
ssh-keygen -t ed25519 -C "leo.minorui@gmail.com"
cat ~/.ssh/id_ed25519.pub  # 复制到 GitHub Settings > SSH Keys
```

### 第 1 步：安装 Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 第 2 步：克隆 Bare 仓库（恢复所有配置文件）

```bash
git clone --bare git@github.com:panboo0106/dotfiles.git $HOME/.dotfiles

# 临时函数
dotfiles() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }

# checkout 前备份或删除可能冲突的文件（如 ~/.zshrc）
mkdir -p ~/.dotfiles-backup
dotfiles checkout 2>&1 | grep -E "\s+\." | awk {'print $1'} | xargs -I{} mv {} ~/.dotfiles-backup/{}

# checkout 配置文件
dotfiles checkout

# 隐藏 untracked 文件提示
dotfiles config --local status.showUntrackedFiles no
```

### 第 3 步：安装 Brew 软件包

```bash
# 核心工具
brew install git starship wget gnupg

# 现代 CLI
brew install bat eza git-delta

# 编辑器 & Git TUI
brew install neovim lazygit gh

# 开发语言依赖
brew install lua luajit luarocks

# 搜索 & 实用工具
brew install ripgrep imagemagick z3

# Python 包管理
brew install uv

# 代理 & 网络
brew install sing-box nmap mole

# 数据库迁移
brew install golang-migrate

# 其他（opencode 需要先 tap）
brew tap anomalyco/tap
brew install opencode llmfit
```

```bash
# Cask 应用
brew install --cask squirrel-app
brew install --cask orbstack          # Docker / Linux VM
brew install --cask kitty             # 主终端
brew install --cask wezterm           # 备用终端
brew install --cask alacritty         # 备用终端
brew install --cask raycast           # 启动器
brew install --cask hiddenbar         # 菜单栏管理
brew install --cask loop              # 窗口管理
brew install --cask lunar             # 显示器亮度
brew install --cask stats             # 系统监控
brew install --cask motrix            # 下载管理器
brew install --cask codex             # AI 工具
brew install --cask deepchat          # AI 对话
brew install --cask drawio            # 绘图工具

# 编程字体（Nerd Font 为终端图标必需）
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-jetbrains-mono
brew install --cask font-fira-code
brew install --cask font-lxgw-wenkai
brew install --cask font-maple-mono-nf-cn
```

### 第 4 步：安装 Oh My Zsh

Oh My Zsh 配置在非标准路径 `~/.config/oh-my-zsh`：

```bash
ZSH=$HOME/.config/oh-my-zsh sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 安装自定义插件
ZSH_CUSTOM=$HOME/.config/oh-my-zsh/custom

git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions
git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
```

### 第 5 步：安装 NVM + Node.js

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# 重新加载 shell 后
nvm install 22    # 主力版本（设为默认）
nvm use 22
nvm alias default 22
nvm install 25    # 可选最新版
```

### 第 6 步：安装 Go 版本管理器 g

```bash
curl -sSL https://raw.githubusercontent.com/voidint/g/master/install.sh | bash

# 重新加载 shell 后（国内镜像已在 .g/env 中配置）
g install 1.24
```

### 第 7 步：安装 Python（uv）

```bash
# uv 已在第 3 步通过 brew 安装
uv python install 3.14
```

### 第 8 步：安装 npm 全局包

```bash
npm install -g @anthropic-ai/claude-code
npm install -g @mermaid-js/mermaid-cli
```

### 第 9 步：安装 Go 工具

```bash
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
```

> `fd` 和 `rg` 在 `~/.local/bin/` 是 Claude Code 自动管理的，无需手动安装。

### 第 10 步：安装雾凇拼音

```bash
cd ~/Library/Rime

curl -fsSL https://raw.githubusercontent.com/rime/plum/master/rime-install | \
  bash -s -- iDvel/rime-ice:others/recipes/full

# 部署
/Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --reload
```

验证：
```bash
ls ~/Library/Rime/build/*.bin 2>/dev/null | head -5
```

### 第 11 步：启动 sing-box（代理工具）

bare 仓库已包含 `~/.config/sing-box/io.sing-box.plist`，加载 LaunchAgent：

```bash
# brew 安装 sing-box 时会自动注册 plist，若需手动加载：
brew services start sing-box
# 或
launchctl load ~/Library/LaunchAgents/io.sing-box.plist
```

---

## Dotfiles 日常管理

```bash
# 查看状态
dot status

# 追踪新文件
dot-add ~/.config/some/config.toml

# 提交
dot-commit "add some config"

# 一键同步（add -u + commit + push）
dot-sync
```

以上函数已定义在 `~/.zshrc` 中，`dot` 是 `dotfiles` 的别名。

---

## 现代 CLI 工具

| 传统命令 | 现代替代 | 主要优势 |
|---------|---------|---------|
| `cat` | `bat` | 语法高亮、行号、Git 集成 |
| `ls` | `eza` | 彩色输出、Git 状态、图标、树形视图 |
| `git diff` | `delta` | 并排对比、语法高亮、行号高亮 |

### Shell Alias（`~/.zshrc`）

```bash
alias cat='bat'
alias ls='eza'
alias ll='eza -l'
alias la='eza -la'
alias lt='eza --tree --level=2'
alias lta='eza --tree --level=2 -a'
```

### Delta 配置（`~/.gitconfig`）

```ini
[core]
    pager = delta
    editor = nvim

[delta]
    navigate = true
    side-by-side = true
    line-numbers = true
    syntax-theme = Dracula

[merge]
    conflictstyle = zdiff3
```

---

## 输入法使用说明

- **输入法**: 鼠须管 + 雾凇拼音
- **输出**: 简体中文（默认）
- **配置文件**: `~/Library/Rime/rime_ice.custom.yaml`（由 bare 仓库追踪）

### 快捷键

| 快捷键 | 功能 |
|--------|------|
| `F4` 或 `` Ctrl+` `` | 方案选单 |
| `Ctrl+Shift+4` | 切换简繁 |
| `-` / `=` | 候选词翻页 |
| `Backspace` | 逐个删除拼音 |

### 自定义主题（可选）

创建 `~/Library/Rime/squirrel.custom.yaml`：

```yaml
patch:
  style:
    font_face: "JetBrains Mono, LXGW WenKai"
    font_point: 18
    color_scheme: macos_dark
```

```bash
/Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --reload
```

### 更新雾凇拼音

```bash
cd ~/Library/Rime/rime-ice
git pull
/Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --reload
```

---

## Neovim Mermaid 预览

在 Kitty 终端内嵌渲染小图，大图在浏览器预览。

### 依赖

```bash
npm install -g @mermaid-js/mermaid-cli
brew install imagemagick
# 需要系统已安装 Google Chrome
```

### 配置文件

- `~/.config/nvim/lua/plugins/mermaid.lua` — 插件配置
- `~/.config/nvim/puppeteer.config.json` — 指向系统 Chrome 路径

### 快捷键

| 快捷键 | 功能 |
|--------|------|
| 打开/保存 `.mmd` | 小图（≤12节点）自动渲染到 Kitty |
| `<leader>kr` | 强制 Kitty 渲染（忽略大小限制） |
| `<leader>km` | 智能预览（按节点数自动判断） |
| `<leader>kmo` | 浏览器预览 |
| `<leader>kmc` | 关闭浏览器 |
| `<leader>ks` | 导出 SVG 文件 |

---

## 相关链接

- [雾凇拼音 GitHub](https://github.com/iDvel/rime-ice)
- [鼠须管 GitHub](https://github.com/rime/squirrel)
- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)
- [Starship](https://starship.rs)
- [g - Go Version Manager](https://github.com/voidint/g)
- [nvm](https://github.com/nvm-sh/nvm)
- [uv](https://github.com/astral-sh/uv)

## License

MIT
