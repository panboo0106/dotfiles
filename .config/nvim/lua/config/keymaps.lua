-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- windows resize cmd
vim.keymap.set("n", "<S-Up>", ":resize +2<CR>")
vim.keymap.set("n", "<S-Down>", ":resize -2<CR>")
vim.keymap.set("n", "<S-Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<S-Right>", ":vertical resize +2<CR>")
--  esc replace
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true })
vim.keymap.set("t", "jj", "<C-\\><C-n>", { noremap = true, silent = true })

-- 水平分割打开终端
vim.keymap.set("n", "<leader>th", function()
  vim.cmd("split")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Terminal (horizontal split)" })

-- 垂直分割打开终端
vim.keymap.set("n", "<leader>tv", function()
  vim.cmd("vsplit")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Terminal (vertical split)" })
