-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

vim.opt.encoding = "utf-8"
vim.opt.shell = "zsh"
vim.opt.shiftwidth = 2

vim.env.PATH = "~/.nvm/versions/node/v18.17.1/bin:" .. vim.env.PATH
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
  },
})
