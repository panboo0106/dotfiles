-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
--
--
-- local function augroup(name)
--   return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
-- end
-- -- wrap and check for spell in text filetypes
-- vim.api.nvim_create_autocmd("FileType", {
--   group = augroup("wrap_spell"),
--   pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
--   callback = function()
--     vim.opt_local.wrap = true
--     vim.opt_local.spell = false
--   end,
-- })
--
-- 覆盖 LazyVim 默认的 wrap_spell autocmd，禁用拼写检查
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.spell = false
  end,
})
