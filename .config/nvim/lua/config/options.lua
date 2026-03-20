-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.opt.relativenumber = false
vim.opt.timeoutlen = 300
vim.opt.shell = "zsh"
vim.opt.spell = false
-- 设置 Ruff 全局配置文件路径
vim.env.RUFF_CONFIG = vim.fn.stdpath("config") .. "/ruff.toml"
vim.g.lazyvim_python_lsp = "ruff"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.build_cmd = "make"
-- 动态获取 Node 和 Go 路径
local node_bin = os.getenv("NVM_BIN") -- NVM 会设置这个环境变量
  or vim.fn.exepath("node"):match("(.+)/node$") -- 或者从当前 PATH 中查找
  or vim.fn.expand("~/.nvm/versions/node/default/bin") -- 回退到默认
vim.env.PATH = node_bin .. ":" .. vim.fn.expand("$HOME/.g/go/bin") .. ":" .. vim.env.PATH
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
  },
  extension = {
    sh = "sh",
  },
})
vim.opt.showtabline = 0
-- 启用保存时自动格式化
vim.g.autoformat = true
