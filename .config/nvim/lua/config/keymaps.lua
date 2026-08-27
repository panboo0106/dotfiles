-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- windows resize cmd
vim.keymap.set("n", "<S-Up>", ":resize +2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Down>", ":resize -2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Left>", ":vertical resize -2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Right>", ":vertical resize +2<CR>", { noremap = true, silent = true })
--  esc replace
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true })
-- 终端模式刻意不映射 jj：:h terminal-input —— 除 <C-\> 外所有键都发给子程序。映射 jj 会让
-- 每个 j 先被 hold 一个 timeoutlen 才出字，真打出 jj 还会被吞掉（在 Claude Code 等 TUI 里打字必踩）。
-- 退出终端模式统一用内置 <C-\><C-n>。

-- ==================== 终端快捷键（<leader>t）====================
local map = vim.keymap.set

-- 水平分割打开终端（每次新建独立实例，用 <C-d> 或 :bd 关闭）
map("n", "<leader>th", function()
  vim.cmd("split")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Horizontal Split" })

-- 垂直分割打开终端（每次新建独立实例，用 <C-d> 或 :bd 关闭）
map("n", "<leader>tv", function()
  vim.cmd("vsplit")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Vertical Split" })

-- 新标签页终端
map("n", "<leader>tt", function()
  vim.cmd("tabnew")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "New Tab Terminal" })

-- 当前窗口开终端（当普通 buffer 用，<S-h>/<S-l> 或 <leader>, 自由切走再切回）
-- 刻意不用 Snacks.terminal：snacks 窗口默认 fixbuf=true（"don't allow other buffers
-- to be opened in this window"），切 buffer 会被 BufWinEnter 钩子弹回终端并把目标
-- buffer 甩进别的窗口。内置 :terminal 每次就是一个全新的独立 buffer，无此限制。
map("n", "<leader>tc", function()
  -- 在 snacks 托管窗口（explorer、<C-/> 终端等）里直接 :terminal 会被同一个 fixbuf
  -- 钩子劫持：enew 出的空 buffer 被换走，jobstart 落到已修改的 buffer 上报
  -- "requires unmodified buffer"。先退到普通编辑窗口再开。
  if vim.w[vim.api.nvim_get_current_win()].snacks_win then
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if not vim.w[w].snacks_win and vim.api.nvim_win_get_config(w).zindex == nil then
        vim.api.nvim_set_current_win(w)
        break
      end
    end
  end
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Current Window Terminal" })

-- 右侧终端：切换
map("n", "<leader>ta", function()
  Snacks.terminal.toggle(nil, {
    -- 终端实例身份由 cmd+cwd+env+count 派生（`id` 不是合法字段，会被忽略）。
    -- 三个具名终端用不同 count 区分，否则 right/float 因四要素全同而 toggle 到同一实例。
    count = 1,
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

-- 退出终端模式：只用内置 <C-\><C-n>，刻意不映射 <Esc><Esc>。Claude Code / lazygit 这类 TUI
-- 把 Esc 当核心操作（中断请求、回退上一条消息），一旦映射，单按 Esc 会被 hold 到 timeoutlen
-- 超时才透传下去，双击又整个被吃掉，两头都不对。

-- 覆盖 LazyVim 默认 <C-/> 终端：relative=win，仅在代码区下方分割，不遮挡左树
local _toggle_bottom_terminal = function()
  Snacks.terminal.toggle(nil, {
    count = 3,
    cwd = LazyVim.root(),
    win = {
      relative = "win",
      position = "bottom",
      height = 0.4,
      border = "rounded",
    },
  })
end
map({ "n", "t" }, "<c-/>", _toggle_bottom_terminal, { desc = "Terminal (Root Dir)" })
map({ "n", "t" }, "<c-_>", _toggle_bottom_terminal, { desc = "which_key_ignore" })

-- 浮动终端（额外）
map({ "n", "t" }, "<leader>tf", function()
  Snacks.terminal.toggle(nil, {
    count = 2,
    win = {
      position = "float",
      border = "rounded",
      width = 0.8,
      height = 0.8,
    },
  })
end, { desc = "Float Terminal" })

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
vim.schedule(function()
  local wk = require("which-key")
  wk.add({
    -- 终端组
    { "<leader>t", group = "terminal", icon = { icon = "", color = "grey" } },
    { "<leader>th", icon = { icon = "", color = "grey" } },
    { "<leader>tv", icon = { icon = "", color = "grey" } },
    { "<leader>tt", icon = { icon = "󰓩", color = "grey" } },
    { "<leader>tc", icon = { icon = "󰆍", color = "grey" } },
    { "<leader>ta", icon = { icon = "󰆽", color = "grey" } },
    { "<leader>tn", icon = { icon = "󰆓", color = "grey" } },
    { "<leader>tf", icon = { icon = "󰹑", color = "grey" } },
    -- Scratch 组
    { "<leader>N", group = "Scratch", icon = { icon = "󰆓", color = "yellow" } },
    { "<leader>Nn", icon = { icon = "󰝖", color = "yellow" } },
    { "<leader>Ns", icon = { icon = "󰆓", color = "yellow" } },
    { "<leader>Nd", icon = { icon = "󰃭", color = "yellow" } },
  })
end)
