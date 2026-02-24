# 鼠须管 + 雾凇拼音 - 完整安装指南

## 系统要求

- macOS 10.15 或更高版本
- Homebrew 已安装
- 网络连接（需要下载词库）

## 安装步骤

### 1. 安装鼠须管输入法

```bash
# 使用 Homebrew 安装
brew install --cask squirrel

# 安装完成后，注销并重新登录系统
# 或者重启电脑
```

### 2. 完全删除旧配置（如需要重新安装）

```bash
# 关闭鼠须管
killall Squirrel 2>/dev/null

# 删除所有 Rime 配置
rm -rf ~/Library/Rime
```

### 3. 安装雾凇拼音

```bash
# 进入 Rime 配置目录
cd ~/Library/Rime

# 使用 plum 安装雾凇拼音（推荐）
curl -fsSL https://raw.githubusercontent.com/rime/plum/master/rime-install | \
  bash -s -- iDvel/rime-ice:others/recipes/full

# 如果网络问题，可以使用 git clone
# git clone --depth 1 https://github.com/iDvel/rime-ice.git
```

### 4. 应用自定义配置（可选）

#### 基础配置 (`default.custom.yaml`)

创建文件 `~/Library/Rime/default.custom.yaml`：

```yaml
patch:
  schema_list:
    - schema: rime_ice

  menu:
    page_size: 7

  switcher:
    caption: 「方案选单」
    hotkeys:
      - F4
      - Control+grave

  simplifier:
    opencc_config: s2t.json
    option_name: traditionalization
    tips: all
```

#### 外观配置 (`squirrel.custom.yaml`)

创建文件 `~/Library/Rime/squirrel.custom.yaml`：

```yaml
patch:
  style:
    font_face: "LXGW WenKai, JetBrains Mono, PingFang SC"
    font_point: 18
    color_scheme: macos_dark

  preset_color_schemes:
    macos_dark:
      name: "macOS 深色"
      back_color: 0x2D2D2D
      border_color: 0x3D3D3D
      text_color: 0xFFFFFF
      hilited_back_color: 0x007AFF
      hilited_candidate_text_color: 0xFFFFFF
      hilited_candidate_back_color: 0x007AFF
      candidate_text_color: 0xFFFFFF
      comment_text_color: 0x999999
      label_color: 0x999999
      hilited_label_color: 0xFFFFFF

  app_options:
    com.apple.Terminal:
      ascii_mode: true
    com.googlecode.iterm2:
      ascii_mode: true
    com.microsoft.VSCode:
      ascii_mode: true
    com.jetbrains.intellij:
      ascii_mode: true
```

### 5. 部署配置

```bash
/Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --reload
```

### 6. 验证安装

```bash
# 检查是否成功部署
ls ~/Library/Rime/build/*.bin 2>/dev/null | head -5

# 检查词库
ls ~/Library/Rime/rime_ice* 2>/dev/null
```

## 常见问题

### Backspace 在终端中删除整个输入串

这是 Rime 与终端模拟器的已知兼容性问题。解决方案：

1. **使用默认配置** - 不添加任何 `key_binder` 自定义
2. **在 GUI 应用中使用** - 备忘录、浏览器等 Backspace 正常
3. **终端中使用英文模式** - 需要精确编辑时切换

### 切换简繁体

- 快捷键：`Ctrl+Shift+4`
- 或按 `F4` 打开方案选单切换

### 更新词库

```bash
cd ~/Library/Rime/rime-ice
git pull
/Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --reload
```

## 快捷键参考

| 快捷键 | 功能 |
|--------|------|
| `F4` 或 `` Ctrl+` `` | 方案选单 |
| `Ctrl+Shift+4` | 切换简繁 |
| `Ctrl+Shift+3` | 切换中英标点 |
| `-` / `=` | 候选词翻页 |
| `Backspace` | 逐个删除拼音 |

## 相关链接

- [雾凇拼音 GitHub](https://github.com/iDvel/rime-ice)
- [鼠须管 GitHub](https://github.com/rime/squirrel)
- [Rime 输入法](https://rime.im/)
