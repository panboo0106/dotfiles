-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- windows resize cmd
vim.keymap.set("n", "<S-Up>", ":resize +2<CR>")
vim.keymap.set("n", "<S-Down>", ":resize -2<CR>")
vim.keymap.set("n", "<S-Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<S-Right>", ":vertical resize +2<CR>")
