-- ~/.config/nvim/init.lua
-- LazyVim 配置，支持 VS Code Neovim

-- ==================== VS Code 检测和配置 ====================
if vim.g.vscode then
  -- 设置 VS Code 模式标志
  vim.g.vscode_mode = true

  -- 修复 macOS 剪贴板路径
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = "/usr/bin/pbcopy",
      ["*"] = "/usr/bin/pbcopy",
    },
    paste = {
      ["+"] = "/usr/bin/pbpaste",
      ["*"] = "/usr/bin/pbpaste",
    },
    cache_enabled = 0,
  }

  -- 加载 VS Code 专用配置
  local vscode_config = vim.fn.stdpath("config") .. "/lua/config/vscode.lua"
  if vim.loop.fs_stat(vscode_config) then
    require("config.vscode")
  else
    vim.notify("VS Code config not found at: " .. vscode_config, vim.log.levels.WARN)
  end

  -- VS Code 模式下不加载 LazyVim
  return
end

-- ==================== 标准 Neovim 配置 ====================
-- Bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
