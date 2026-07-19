-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- LazyVim core's `wrap_spell` autocmd force-enables `spell` for prose filetypes, overriding the
-- global `vim.opt.spell = false` in options.lua. Keep the wrap behavior, drop the spell override.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("lazyvim_wrap_spell", { clear = false }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.spell = false
  end,
})
