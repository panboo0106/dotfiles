-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.opt.relativenumber = false
vim.opt.timeoutlen = 300
vim.opt.shell = "zsh"
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.build_cmd = "make"
vim.env.PATH = "~/.nvm/versions/node/v18.17.1/bin:/Users/leo/.g/go/bin:" .. vim.env.PATH
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
  },
})
vim.opt.showtabline = 0
vim.treesitter.language.register("markdown", "Avante")
vim.filetype.add({
  extension = {
    sh = "sh",
  },
})
local leet_arg = "leetcode.nvim"
return leet_arg
