-- init.lua 开头添加
if vim.g.vscode then
  vim.g.vscode_mode = true

  -- 修复 pbcopy 路径
  vim.g.clipboard = {
    copy = {
      ["+"] = "/usr/bin/pbcopy",
      ["*"] = "/usr/bin/pbcopy",
    },
    paste = {
      ["+"] = "/usr/bin/pbpaste",
      ["*"] = "/usr/bin/pbpaste",
    },
  }
  require("config.vscode")
end
-- bootstrap lazy.nvim, LazyVim and your plugins--
require("config.lazy")
