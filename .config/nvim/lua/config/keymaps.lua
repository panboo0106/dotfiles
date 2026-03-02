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

-- ==================== 终端快捷键（<leader>t）====================
local map = vim.keymap.set

-- 水平分割打开终端
map("n", "<leader>th", function()
	vim.cmd("split")
	vim.cmd("terminal")
	vim.cmd("startinsert")
end, { desc = "Horizontal Split" })

-- 垂直分割打开终端
map("n", "<leader>tv", function()
	vim.cmd("vsplit")
	vim.cmd("terminal")
	vim.cmd("startinsert")
end, { desc = "Vertical Split" })

-- 新标签页终端
map("n", "<leader>tt", "<cmd>tabnew | terminal<cr>", { desc = "New Tab" })

-- 右侧终端：切换
map("n", "<leader>ta", function()
	Snacks.terminal.toggle(nil, {
		win = {
			position = "right",
			width = 40,
			border = "rounded",
		},
	})
end, { desc = "Toggle Right" })

-- 右侧终端：新建
map("n", "<leader>tn", function()
	Snacks.terminal.open(nil, {
		win = {
			position = "right",
			width = 40,
			border = "rounded",
		},
	})
end, { desc = "New Right" })

-- 终端模式下的窗口切换快捷键
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Left Window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Down Window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Up Window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Right Window" })

-- 快速退出终端模式
map("t", "<C-\\><C-n>", "<C-\\><C-n>", { desc = "Exit Terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal (Double Esc)" })

-- 自动打开右侧终端
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.defer_fn(function()
			Snacks.terminal.toggle(nil, {
				win = {
					position = "right",
					width = 40,
					border = "rounded",
				},
			})
		end, 100)
	end,
	desc = "Auto open terminal on startup",
})

-- ==================== Scratch 临时笔记（<leader>N）===================
map("n", "<leader>Nn", function()
	Snacks.scratch()
end, { desc = "New Scratch" })

map("n", "<leader>Ns", function()
	local scratch_dir = vim.fn.stdpath("data") .. "/scratch"
	vim.fn.mkdir(scratch_dir, "p")
	Snacks.scratch({ root = scratch_dir })
end, { desc = "Save to File" })

map("n", "<leader>Nd", function()
	local scratch_dir = vim.fn.stdpath("data") .. "/scratch"
	vim.fn.mkdir(scratch_dir, "p")
	local filename = os.date("%Y-%m-%d") .. ".md"
	Snacks.scratch({
		name = filename,
		root = scratch_dir,
	})
end, { desc = "Daily Note" })

-- ==================== Which-Key 图标注册 ====================
local wk = require("which-key")
wk.add({
	-- 终端组
	{ "<leader>t", group = "terminal", icon = { icon = "", color = "grey" } },
	{ "<leader>th", icon = { icon = "", color = "grey" } },
	{ "<leader>tv", icon = { icon = "", color = "grey" } },
	{ "<leader>tt", icon = { icon = "󰓩", color = "grey" } },
	{ "<leader>ta", icon = { icon = "󰆽", color = "grey" } },
	{ "<leader>tn", icon = { icon = "󰆓", color = "grey" } },
	-- Scratch 组
	{ "<leader>N", group = "Scratch", icon = { icon = "󰆓", color = "yellow" } },
	{ "<leader>Nn", icon = { icon = "󰝖", color = "yellow" } },
	{ "<leader>Ns", icon = { icon = "󰆓", color = "yellow" } },
	{ "<leader>Nd", icon = { icon = "󰃭", color = "yellow" } },
})
