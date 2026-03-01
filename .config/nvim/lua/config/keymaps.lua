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
vim.keymap.set("n", "<leader>Th", function()
  vim.cmd("split")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Terminal (horizontal split)" })

-- 垂直分割打开终端
vim.keymap.set("n", "<leader>Tv", function()
  vim.cmd("vsplit")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Terminal (vertical split)" })

local map = vim.keymap.set

-- 终端相关快捷键
map("n", "<leader>Tt", "<cmd>tabnew | terminal<cr>", { desc = "新标签页终端" })

-- 终端模式下的快捷键
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "向左切换窗口" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "向下切换窗口" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "向上切换窗口" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "向右切换窗口" })

-- 快速退出终端模式
map("t", "<C-\\><C-n>", "<C-\\><C-n>", { desc = "退出终端模式" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "退出终端模式(双Esc)" })

-- scratch 临时笔记（使用 <leader>N 避免与 <leader>n 冲突）
-- 注册 which-key 分组图标
local wk = require("which-key")
wk.add({
	{ "<leader>N", group = "Scratch", icon = { icon = "󰆓", color = "yellow" } },
})

-- 纯内存模式（不保存到文件，关闭后消失）
map("n", "<leader>Nn", function()
	Snacks.scratch()
end, { desc = "Memory Only" })

-- 保存到文件模式（自动保存到 ~/.local/share/nvim/scratch）
map("n", "<leader>Ns", function()
	local scratch_dir = vim.fn.stdpath("data") .. "/scratch"
	vim.fn.mkdir(scratch_dir, "p")
	Snacks.scratch({ root = scratch_dir })
end, { desc = "Save to File" })

-- 打开今日笔记（按日期命名，自动保存）
map("n", "<leader>Nd", function()
	local scratch_dir = vim.fn.stdpath("data") .. "/scratch"
	vim.fn.mkdir(scratch_dir, "p")
	local filename = os.date("%Y-%m-%d") .. ".md"
	Snacks.scratch({
		name = filename,
		root = scratch_dir,
	})
end, { desc = "Daily Note" })
