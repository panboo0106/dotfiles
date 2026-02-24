# Dotfiles - 开发环境配置

个人 macOS 开发环境配置仓库。

## 环境概览

- **Shell**: Zsh + Oh My Zsh + Starship
- **编辑器**: Neovim (LazyVim), Zed, VSCode
- **终端**: Kitty (主终端), WezTerm, Alacritty
- **输入法**: 鼠须管 (Squirrel) + 雾凇拼音

## 快速安装

### 1. 基础工具

```bash
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装核心工具
brew install git vim fzf ripgrep fd starship
brew install --cask squirrel
```

### 2. 安装雾凇拼音

```bash
cd ~/Library/Rime

# 安装雾凇拼音
curl -fsSL https://raw.githubusercontent.com/rime/plum/master/rime-install | \
  bash -s -- iDvel/rime-ice:others/recipes/full

# 部署
/Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --reload
```

### 3. 验证安装

```bash
# 检查是否成功
ls ~/Library/Rime/build/*.bin 2>/dev/null | head -5
```

## 输入法使用说明

### 当前状态

- **输入法**: 鼠须管 + 雾凇拼音
- **输出**: 简体中文（默认）
- **主题**: 使用雾凇拼音默认主题
- **状态**: ✅ Backspace 正常，简体中文输出

### 快捷键

| 快捷键 | 功能 |
|--------|------|
| `F4` 或 `` Ctrl+` `` | 方案选单 |
| `Ctrl+Shift+4` | 切换简繁 |
| `-` / `=` | 候选词翻页 |
| `Backspace` | 逐个删除拼音 |

### 简繁切换

- 默认输出 **简体中文**
- 按 `Ctrl+Shift+4` 切换到繁体
- 再次按 `Ctrl+Shift+4` 切换回简体

### 自定义主题（可选）

如需修改外观，创建 `~/Library/Rime/squirrel.custom.yaml`：

```yaml
patch:
  style:
    font_face: "JetBrains Mono, LXGW WenKai"
    font_point: 18
    color_scheme: macos_dark
```

然后重新部署：
```bash
/Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --reload
```

## 更新维护

```bash
# 更新雾凇拼音
cd ~/Library/Rime/rime-ice
git pull

# 重新部署
/Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --reload
```

## 相关链接

- [雾凇拼音 GitHub](https://github.com/iDvel/rime-ice)
- [鼠须管 GitHub](https://github.com/rime/squirrel)
- [Rime 输入法](https://rime.im/)

## License

MIT
