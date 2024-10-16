-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- windows resize cmd
vim.keymap.set("n", "<S-Up>", ":resize +2<CR>")
vim.keymap.set("n", "<S-Down>", ":resize -2<CR>")
vim.keymap.set("n", "<S-Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<S-Right>", ":vertical resize +2<CR>")
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true })

local wk = require("which-key")
wk.add({
  { "<leader>a", group = "AI" },
})
vim.keymap.set("n", "<leader>ac", function()
  if vim.g.codeium_enabled == true then
    vim.g.codeium_enabled = false
    print("Codeium disabled")
  else
    vim.g.codeium_enabled = true
    print("Codeium enabled")
  end
end, { noremap = true, silent = true, desc = "Toggle Codeium" })
