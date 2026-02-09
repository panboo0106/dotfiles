-- ~/.config/nvim/lua/config/vscode.lua
-- VS Code Neovim 专用配置

-- ==================== 基础设置 ====================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 禁用不需要的内置插件
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_logipat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_spellfile_plugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1

-- ==================== Vim 选项设置 ====================
local opt = vim.opt

-- 搜索设置
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- 缩进设置
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- 剪贴板（使用系统剪贴板）
opt.clipboard = "unnamedplus"

-- 其他设置
opt.number = true
opt.relativenumber = false
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.timeoutlen = 300

-- ==================== VSCode API 辅助函数 ====================
local vscode = require("vscode-neovim")

-- 安全调用 VSCode 命令
local function call_vscode(command, opts)
  opts = opts or {}
  vscode.call(command, opts)
end

-- 带参数调用 VSCode 命令
local function action(command, opts)
  return function()
    call_vscode(command, opts)
  end
end

-- ==================== 基础按键映射 ====================
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- jk 退出 Insert 模式
keymap("i", "jk", "<Esc>", opts)

-- 更好的移动（保持光标居中）
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- 保持视觉模式的选择
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- 移动选中的行
keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

-- 保持粘贴寄存器内容
keymap("x", "<leader>p", '"_dP', opts)

-- 删除到黑洞寄存器
keymap("n", "<leader>d", '"_d', opts)
keymap("v", "<leader>d", '"_d', opts)

-- 清除搜索高亮
keymap("n", "<Esc>", "<cmd>noh<CR><Esc>", opts)
keymap("n", "<leader>nh", "<cmd>noh<CR>", { noremap = true, silent = true, desc = "Clear search highlight" })

-- 保存文件
keymap("n", "<C-s>", action("workbench.action.files.save"), { desc = "Save file" })
keymap(
  "i",
  "<C-s>",
  "<Esc><cmd>lua require('vscode-neovim').call('workbench.action.files.save')<CR>",
  { desc = "Save file" }
)

-- ==================== Leader 键绑定（配合 WhichKey） ====================

-- 文件操作 (Leader + f)
keymap("n", "<leader>ff", action("workbench.action.quickOpen"), { desc = "Find file" })
keymap("n", "<leader>fr", action("workbench.action.openRecent"), { desc = "Recent files" })
keymap("n", "<leader>fn", action("workbench.action.files.newUntitledFile"), { desc = "New file" })
keymap("n", "<leader>fs", action("workbench.action.files.save"), { desc = "Save file" })
keymap("n", "<leader>fS", action("workbench.action.files.saveAll"), { desc = "Save all" })
keymap("n", "<leader>fe", action("workbench.view.explorer"), { desc = "Explorer" })
keymap("n", "<leader>fg", action("workbench.action.findInFiles"), { desc = "Find in files" })

-- 搜索 (Leader + s)
keymap("n", "<leader>sg", action("workbench.action.findInFiles"), { desc = "Grep" })
keymap("n", "<leader>ss", action("workbench.action.gotoSymbol"), { desc = "Go to symbol" })
keymap("n", "<leader>sS", action("workbench.action.showAllSymbols"), { desc = "Workspace symbols" })
keymap("n", "<leader>sr", action("workbench.action.replaceInFiles"), { desc = "Replace in files" })

-- 代码操作 (Leader + c)
keymap("n", "<leader>ca", action("editor.action.quickFix"), { desc = "Code action" })
keymap("n", "<leader>cr", action("editor.action.rename"), { desc = "Rename" })
keymap("n", "<leader>cf", action("editor.action.formatDocument"), { desc = "Format document" })
keymap("v", "<leader>cf", action("editor.action.formatSelection"), { desc = "Format selection" })
keymap("n", "<leader>cd", action("editor.action.showHover"), { desc = "Show definition" })
keymap("n", "<leader>co", action("editor.action.organizeImports"), { desc = "Organize imports" })

-- 注释
keymap("n", "gcc", action("editor.action.commentLine"), { desc = "Toggle comment line" })
keymap("v", "gc", action("editor.action.commentLine"), { desc = "Toggle comment" })

-- Buffer 操作 (Leader + b)
keymap("n", "<leader>bb", action("workbench.action.showAllEditors"), { desc = "Show all buffers" })
keymap("n", "<leader>bd", action("workbench.action.closeActiveEditor"), { desc = "Close buffer" })
keymap("n", "<leader>bn", action("workbench.action.nextEditor"), { desc = "Next buffer" })
keymap("n", "<leader>bp", action("workbench.action.previousEditor"), { desc = "Previous buffer" })
keymap("n", "<leader>bo", action("workbench.action.closeOtherEditors"), { desc = "Close other buffers" })

-- 快速切换 Buffer
keymap("n", "H", action("workbench.action.previousEditor"), { desc = "Previous buffer" })
keymap("n", "L", action("workbench.action.nextEditor"), { desc = "Next buffer" })

-- 窗口操作 (Leader + w)
keymap("n", "<leader>wv", action("workbench.action.splitEditor"), { desc = "Split vertically" })
keymap("n", "<leader>ws", action("workbench.action.splitEditorDown"), { desc = "Split horizontally" })
keymap("n", "<leader>wc", action("workbench.action.closeActiveEditor"), { desc = "Close window" })
keymap("n", "<leader>wo", action("workbench.action.closeOtherEditors"), { desc = "Close other windows" })
keymap("n", "<leader>ww", action("workbench.action.files.save"), { desc = "Save file" })
keymap("n", "<leader>w=", action("workbench.action.evenEditorWidths"), { desc = "Even widths" })

-- 窗口导航（使用 Ctrl）
keymap("n", "<C-h>", action("workbench.action.navigateLeft"), { desc = "Go to left window" })
keymap("n", "<C-j>", action("workbench.action.navigateDown"), { desc = "Go to lower window" })
keymap("n", "<C-k>", action("workbench.action.navigateUp"), { desc = "Go to upper window" })
keymap("n", "<C-l>", action("workbench.action.navigateRight"), { desc = "Go to right window" })

-- Git 操作 (Leader + g)
keymap("n", "<leader>gg", action("workbench.view.scm"), { desc = "Source control" })
keymap("n", "<leader>gb", action("git.checkout"), { desc = "Checkout branch" })
keymap("n", "<leader>gc", action("git.commit"), { desc = "Commit" })
keymap("n", "<leader>gp", action("git.push"), { desc = "Push" })
keymap("n", "<leader>gP", action("git.pull"), { desc = "Pull" })
keymap("n", "<leader>gs", action("git.stage"), { desc = "Stage" })
keymap("n", "<leader>gu", action("git.unstage"), { desc = "Unstage" })
keymap("n", "<leader>gd", action("git.openChange"), { desc = "View changes" })

-- 终端 (Leader + t)
keymap("n", "<leader>tt", action("workbench.action.terminal.toggleTerminal"), { desc = "Toggle terminal" })
keymap("n", "<leader>tn", action("workbench.action.terminal.new"), { desc = "New terminal" })
keymap("n", "<leader>ts", action("workbench.action.terminal.split"), { desc = "Split terminal" })
keymap("n", "<leader>tk", action("workbench.action.terminal.kill"), { desc = "Kill terminal" })

-- 快速终端切换
keymap("n", "<C-`>", action("workbench.action.terminal.toggleTerminal"), { desc = "Toggle terminal" })

-- UI 切换 (Leader + u)
keymap("n", "<leader>uw", action("editor.action.toggleWordWrap"), { desc = "Toggle word wrap" })
keymap("n", "<leader>ue", action("workbench.action.toggleSidebarVisibility"), { desc = "Toggle explorer" })
keymap("n", "<leader>uz", action("workbench.action.toggleZenMode"), { desc = "Toggle zen mode" })
keymap("n", "<leader>uf", action("workbench.action.toggleFullScreen"), { desc = "Toggle fullscreen" })

-- 侧边栏切换
keymap("n", "<C-b>", action("workbench.action.toggleSidebarVisibility"), { desc = "Toggle sidebar" })
keymap("n", "<C-n>", action("workbench.view.explorer"), { desc = "Explorer" })

-- 问题/诊断 (Leader + x)
keymap("n", "<leader>xx", action("workbench.actions.view.problems"), { desc = "Show problems" })
keymap("n", "<leader>xq", action("workbench.action.closePanel"), { desc = "Close panel" })

-- 快速退出
keymap("n", "<leader>q", action("workbench.action.closeActiveEditor"), { desc = "Close editor" })
keymap("n", "<leader>Q", action("workbench.action.closeAllEditors"), { desc = "Close all editors" })

-- ==================== LSP 相关按键 ====================

-- 跳转
keymap("n", "gd", action("editor.action.revealDefinition"), { desc = "Go to definition" })
keymap("n", "gD", action("editor.action.peekDefinition"), { desc = "Peek definition" })
keymap("n", "gi", action("editor.action.goToImplementation"), { desc = "Go to implementation" })
keymap("n", "gr", action("editor.action.goToReferences"), { desc = "Go to references" })
keymap("n", "gy", action("editor.action.goToTypeDefinition"), { desc = "Go to type definition" })

-- 文档
keymap("n", "K", action("editor.action.showHover"), { desc = "Show hover" })
keymap("n", "gh", action("editor.action.showHover"), { desc = "Show hover" })

-- 诊断导航
keymap("n", "]d", action("editor.action.marker.nextInFiles"), { desc = "Next diagnostic" })
keymap("n", "[d", action("editor.action.marker.prevInFiles"), { desc = "Previous diagnostic" })
keymap("n", "]e", function()
  call_vscode("editor.action.marker.next", { args = { severity = "Error" } })
end, { desc = "Next error" })
keymap("n", "[e", function()
  call_vscode("editor.action.marker.prev", { args = { severity = "Error" } })
end, { desc = "Previous error" })

-- 快速修复
keymap("n", "<C-.>", action("editor.action.quickFix"), { desc = "Quick fix" })

-- 重命名
keymap("n", "<F2>", action("editor.action.rename"), { desc = "Rename" })

-- 格式化
keymap("n", "<S-A-f>", action("editor.action.formatDocument"), { desc = "Format document" })
keymap("v", "<S-A-f>", action("editor.action.formatSelection"), { desc = "Format selection" })

-- ==================== 折叠操作 ====================
keymap("n", "za", action("editor.toggleFold"), { desc = "Toggle fold" })
keymap("n", "zc", action("editor.fold"), { desc = "Close fold" })
keymap("n", "zo", action("editor.unfold"), { desc = "Open fold" })
keymap("n", "zM", action("editor.foldAll"), { desc = "Close all folds" })
keymap("n", "zR", action("editor.unfoldAll"), { desc = "Open all folds" })

-- ==================== 面板和视图 ====================
keymap("n", "<C-S-f>", action("workbench.action.findInFiles"), { desc = "Find in files" })
keymap("n", "<C-S-o>", action("workbench.action.gotoSymbol"), { desc = "Go to symbol" })
keymap("n", "<C-S-m>", action("workbench.actions.view.problems"), { desc = "Show problems" })
keymap("n", "<C-S-g>", action("workbench.view.scm"), { desc = "Source control" })

-- ==================== 特殊功能 ====================

-- 多光标（使用 VS Code 原生功能）
keymap("n", "<C-d>", action("editor.action.addSelectionToNextFindMatch"), { desc = "Add selection to next match" })

-- 快速打开
keymap("n", "<C-p>", action("workbench.action.quickOpen"), { desc = "Quick open" })

-- 命令面板
keymap("n", "<leader><leader>", action("workbench.action.showCommands"), { desc = "Command palette" })

-- ==================== 自动命令 ====================

-- 语言特定设置
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "yaml", "html", "css", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- ==================== 通知用户配置已加载 ====================
vim.notify("VS Code Neovim configuration loaded", vim.log.levels.INFO)

print("✓ VS Code Neovim configuration loaded successfully")
print("Leader key: <Space>")
print("Use <Space> to see available commands via WhichKey")
