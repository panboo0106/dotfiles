-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.opt.relativenumber = false
vim.opt.timeoutlen = 300
vim.opt.shell = "zsh"
-- 设置 Ruff 全局配置文件路径
vim.env.RUFF_CONFIG = vim.fn.stdpath("config") .. "/ruff.toml"
vim.g.lazyvim_python_lsp = "ruff"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.build_cmd = "make"
vim.env.PATH = "~/.nvm/versions/node/v18.17.1/bin:/Users/leo/.g/go/bin:" .. vim.env.PATH
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
  },
})
vim.opt.showtabline = 0
-- 启用保存时自动格式化
vim.g.autoformat = true
vim.treesitter.language.register("markdown", "Avante")
vim.filetype.add({
  extension = {
    sh = "sh",
  },
})
local leet_arg = "leetcode.nvim"
return leet_arg
