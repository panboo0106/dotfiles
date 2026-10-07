# Dotfiles - 开发环境配置

个人 macOS 开发环境配置仓库（bare git 仓库管理）。

## 环境概览

- **Shell**: Zsh + Oh My Zsh + Starship（`~/.zshenv` 放 cargo env，`~/.zprofile` 放 OrbStack init，`~/.zshrc` 是主体）
- **编辑器**: Neovim (LazyVim), Zed, VSCode
- **终端**: Kitty (主终端), WezTerm, Alacritty
- **输入法**: 鼠须管 (Squirrel) + 雾凇拼音
- **现代 CLI**: bat, eza, delta, gh, lazygit
- **语言**: Node.js / Go (mise), Python (uv), Rust (cargo)
- **版本管理**: mise 管 Node/Go 的全局默认与项目版本（读 `.tool-versions`/`mise.toml`，`cd` 进项目自动切换）；Python 由 uv 管理，两者不冲突

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
git clone --bare git@github.com:panboo0106/dotfiles.git "$HOME/.dotfiles"

# 临时函数
dotfiles() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }

# bare clone 需要配置远端跟踪分支，供 fetch、状态比较和 push 使用
dotfiles config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
dotfiles fetch origin
dotfiles branch --set-upstream-to=origin/main main
dotfiles remote set-head origin -a

# 隐藏家目录中未跟踪文件的提示
dotfiles config --local status.showUntrackedFiles no

# 在家目录检出；如果提示文件冲突，先按下文逐个备份
cd "$HOME"
dotfiles checkout
```

如果 checkout 报告冲突，先检查列出的文件。不要解析错误输出来自动移动文件，也不要使用强制检出。
下面以 `.config/kitty/kitty.conf` 和带空格的 lazygit 配置路径为例。只执行与实际冲突对应的 `mkdir` 和 `mv` 行：

```bash
# 每次生成独立备份目录，保留原目录层级
dot_backup=$(mktemp -d "$HOME/.dotfiles-backup.XXXXXX")
mkdir -p "$dot_backup/.config/kitty"
mv -i "$HOME/.config/kitty/kitty.conf" "$dot_backup/.config/kitty/kitty.conf"
mkdir -p "$dot_backup/Library/Application Support/lazygit"
mv -i "$HOME/Library/Application Support/lazygit/config.yml" "$dot_backup/Library/Application Support/lazygit/config.yml"
printf '备份位置：%s\n' "$dot_backup"

# 全部冲突处理完后重试；保留备份，直到确认恢复成功
dotfiles checkout
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

### 第 5 步：恢复 mise 管理的 Node.js / Go

仓库已包含 `~/.config/mise/config.toml`，当前选择 Node 24、Go 1.27。
这些是版本范围，不固定补丁版本；具体配置以该文件为准。

```bash
brew install mise

# 第 2 步已恢复全局配置；从家目录安装，避免读入其他项目的版本设置
cd "$HOME"
mise install
mise current
```

[`mise install`](https://mise.jdx.dev/cli/install.html) 按已有配置安装工具，不需要再次执行 `mise use -g` 写入版本。
仓库的 `~/.zshrc` 末尾已有 `eval "$(mise activate zsh)"`，不要重复追加。
修改 PATH 时，保留这条初始化在其他 PATH 设置之后。安装完成后打开新终端。

进入其他项目时，按项目的 `mise.toml` 或 `.tool-versions` 执行 `mise install`。
Python 默认由 uv 管理。本恢复流程不在 mise 全局配置中添加 Python，也不启用 `.python-version` 自动读取；
需要 mise 管 Python 的项目应单独配置。

### 第 6 步：安装 Python（uv）

```bash
# uv 已在第 3 步通过 brew 安装
uv python install 3.14
```

### 第 7 步：安装 npm 全局包

```bash
npm install -g @anthropic-ai/claude-code
npm install -g @mermaid-js/mermaid-cli
```

### 第 8 步：安装 Go 工具

```bash
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
```

> `fd` 和 `rg` 在 `~/.local/bin/` 是 Claude Code 自动管理的，无需手动安装。

### 第 9 步：安装雾凇拼音

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

### 第 10 步：启动 sing-box（代理工具）

仓库包含 `~/.config/sing-box/homebrew.mxcl.sing-box.plist`，供核对 Homebrew 服务参数。代理运行配置不在仓库中；先单独恢复 `/opt/homebrew/etc/sing-box/config.json`，再启动服务：

```bash
# 由 Homebrew 管理服务注册与启动
brew services start sing-box
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

# 检查差异，再明确选择要同步的内容
dot diff
dot add -p ~/.zshrc
dot diff --cached

# 仅提交已暂存内容并推送；没有已暂存改动时仍尝试推送
dot-sync
```

以上函数已定义在 `~/.zshrc` 中，`dot` 是 `dotfiles` 的别名。
`dot-sync` 不会自动暂存文件。提交失败时不会推送，推送失败时返回失败状态。
`dot-add` 会暂存指定文件的全部改动；需要选择部分改动时使用 `dot add -p`。

### 配置文件归属

| 内容 | 维护位置 | 原则 |
|------|----------|------|
| Shell | `.zshenv`、`.zprofile`、`.zshrc` | 分别维护环境变量、登录初始化和交互配置 |
| 运行时版本 | `.config/mise/config.toml` | 维护 Node/Go 全局版本范围；安装文件与缓存不入库 |
| Git 与终端 | `.gitconfig`、`.config/delta/`、各终端配置目录 | 只纳入手工维护的配置 |
| Neovim | `.config/nvim/` | 保留现有配置与锁文件；历史计划不在日常整理中删除 |
| lazygit | `.config/lazygit/config.yml`、`Library/Application Support/lazygit/config.yml` | 目前保留两个配置入口；修改前核对实际使用的位置 |
| 鼠须管 | `Library/Rime/*.custom.yaml` | 只维护自定义补丁，排除词库安装产物与用户数据库 |
| 私有配置 | `.zshrc.private.template` | 只跟踪模板；`.zshrc.private` 保持忽略，按需手动配置加载 |

`.worktrees/`、`.agent-work/` 和 `.dotfiles-backup*/` 不纳入版本管理。
隐藏未跟踪文件只影响状态显示。添加文件时仍应使用明确路径，避免对整个家目录执行 `dot add .`。

### 仓库检查与保守维护

```bash
dot count-objects -vH
dot fsck --full

# 远端默认分支改变后，更新本地远端信息
dot fetch origin
dot remote set-head origin -a
```

不可达对象可能是恢复历史，不能只因不可达就删除。需要压缩时，先在仓库副本中测量；
`git repack -a -d --keep-unreachable` 可重新打包并保留不可达对象。
操作前后应核对对象清单、引用、reflog 和索引。不要使用 `prune` 或过期 reflog 来完成日常压缩。

### 检查 Shell 语法

在仓库根目录运行：

```bash
zsh -n .zshrc
zsh -n .zprofile
```

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
- [uv](https://github.com/astral-sh/uv)
- [mise](https://mise.jdx.dev)

## License

MIT
