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
vim.g.build_cmd = "make"
-- 动态获取 Node 和 Go 路径，追加到 PATH
local _nvm_default = vim.fn.expand("~/.nvm/versions/node/default/bin")
local node_bin = os.getenv("NVM_BIN")
  or (vim.fn.exepath("node") ~= "" and vim.fn.exepath("node"):match("(.+)/node$") or nil)
  or (vim.fn.isdirectory(_nvm_default) == 1 and _nvm_default or nil)
local go_bin = vim.fn.expand("$HOME/.g/go/bin")
local extra_paths = {}
if node_bin and node_bin ~= "" then
  table.insert(extra_paths, node_bin)
end
if vim.fn.isdirectory(go_bin) == 1 then
  table.insert(extra_paths, go_bin)
end
if #extra_paths > 0 then
  vim.env.PATH = table.concat(extra_paths, ":") .. ":" .. vim.env.PATH
end
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
