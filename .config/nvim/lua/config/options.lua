-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
local opt = vim.opt
opt.encoding = "utf-8"
opt.shell = "zsh"
opt.shiftwidth = 2
opt.relativenumber = false
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff_lsp"

vim.env.PATH = "~/.nvm/versions/node/v18.17.1/bin:/Users/leo/.g/go/bin:" .. vim.env.PATH
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
  },
})
