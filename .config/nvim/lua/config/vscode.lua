-- ~/.config/nvim/lua/config/vscode.lua
-- LazyVim 在 VSCode 中的配置

-- ============================================
-- 基础设置
-- ============================================
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- 基础选项设置
local options = {
  clipboard = "unnamedplus",
  ignorecase = true,
  smartcase = true,
  hlsearch = false,
  incsearch = true,
  scrolloff = 8,
  sidescrolloff = 8,
  updatetime = 50,
  timeoutlen = 300,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- ============================================
-- VSCode 特定的辅助函数
-- ============================================
local vscode = require("vscode")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ============================================
-- 核心快捷键映射
-- ============================================

-- 文件操作
map("n", "<leader>ff", function()
  vscode.call("workbench.action.quickOpen")
end, { desc = "Find files" })
map("n", "<leader>fg", function()
  vscode.call("workbench.action.findInFiles")
end, { desc = "Grep files" })
map("n", "<leader>fr", function()
  vscode.call("workbench.action.openRecent")
end, { desc = "Recent files" })
map("n", "<leader>fb", function()
  vscode.call("workbench.action.showAllEditors")
end, { desc = "Buffers" })
map("n", "<leader>fe", function()
  vscode.call("workbench.view.explorer")
end, { desc = "Explorer" })
map("n", "<leader>fn", function()
  vscode.call("workbench.action.files.newUntitledFile")
end, { desc = "New file" })

-- 搜索和替换
map("n", "<leader>sg", function()
  vscode.call("workbench.action.findInFiles")
end, { desc = "Grep" })
map("n", "<leader>ss", function()
  vscode.call("workbench.action.gotoSymbol")
end, { desc = "Symbols" })
map("n", "<leader>sS", function()
  vscode.call("workbench.action.showAllSymbols")
end, { desc = "All symbols" })
map("n", "<leader>sr", function()
  vscode.call("editor.action.rename")
end, { desc = "Rename" })
map("n", "<leader>sh", function()
  vscode.call("workbench.action.replaceInFiles")
end, { desc = "Replace in files" })

-- LSP 功能
map("n", "gd", function()
  vscode.call("editor.action.revealDefinition")
end, { desc = "Go to definition" })
map("n", "gD", function()
  vscode.call("editor.action.revealDeclaration")
end, { desc = "Go to declaration" })
map("n", "gi", function()
  vscode.call("editor.action.goToImplementation")
end, { desc = "Go to implementation" })
map("n", "gr", function()
  vscode.call("editor.action.goToReferences")
end, { desc = "Go to references" })
map("n", "gy", function()
  vscode.call("editor.action.goToTypeDefinition")
end, { desc = "Go to type definition" })
map("n", "K", function()
  vscode.call("editor.action.showHover")
end, { desc = "Hover" })

map("n", "<leader>la", function()
  vscode.call("editor.action.quickFix")
end, { desc = "Code action" })
map("n", "<leader>lf", function()
  vscode.call("editor.action.formatDocument")
end, { desc = "Format" })
map("n", "<leader>lr", function()
  vscode.call("editor.action.rename")
end, { desc = "Rename" })
map("n", "<leader>ld", function()
  vscode.call("workbench.actions.view.problems")
end, { desc = "Diagnostics" })
map("n", "<leader>ls", function()
  vscode.call("workbench.action.gotoSymbol")
end, { desc = "Document symbols" })

-- 代码操作
map("n", "<leader>ca", function()
  vscode.call("editor.action.quickFix")
end, { desc = "Code action" })
map("v", "<leader>ca", function()
  vscode.call("editor.action.quickFix")
end, { desc = "Code action" })
map("n", "<leader>cf", function()
  vscode.call("editor.action.formatDocument")
end, { desc = "Format" })
map("v", "<leader>cf", function()
  vscode.call("editor.action.formatSelection")
end, { desc = "Format selection" })
map("n", "<leader>cr", function()
  vscode.call("editor.action.rename")
end, { desc = "Rename" })
map("n", "<leader>cc", function()
  vscode.call("editor.action.commentLine")
end, { desc = "Comment" })
map("v", "<leader>cc", function()
  vscode.call("editor.action.commentLine")
end, { desc = "Comment" })

-- Git 操作
map("n", "<leader>gg", function()
  vscode.call("workbench.view.scm")
end, { desc = "Git status" })
map("n", "<leader>gb", function()
  vscode.call("git.checkout")
end, { desc = "Git branches" })
map("n", "<leader>gc", function()
  vscode.call("git.commit")
end, { desc = "Git commit" })
map("n", "<leader>gd", function()
  vscode.call("git.openChange")
end, { desc = "Git diff" })
map("n", "<leader>gp", function()
  vscode.call("git.push")
end, { desc = "Git push" })
map("n", "<leader>gl", function()
  vscode.call("git.pull")
end, { desc = "Git pull" })
map("n", "<leader>gs", function()
  vscode.call("git.stage")
end, { desc = "Git stage" })
map("n", "<leader>gu", function()
  vscode.call("git.unstage")
end, { desc = "Git unstage" })

-- 窗口管理
map("n", "<leader>wv", function()
  vscode.call("workbench.action.splitEditor")
end, { desc = "Split vertical" })
map("n", "<leader>ws", function()
  vscode.call("workbench.action.splitEditorDown")
end, { desc = "Split horizontal" })
map("n", "<leader>wc", function()
  vscode.call("workbench.action.closeActiveEditor")
end, { desc = "Close window" })
map("n", "<leader>wo", function()
  vscode.call("workbench.action.closeOtherEditors")
end, { desc = "Close others" })
map("n", "<leader>wh", function()
  vscode.call("workbench.action.focusLeftGroup")
end, { desc = "Focus left" })
map("n", "<leader>wj", function()
  vscode.call("workbench.action.focusBelowGroup")
end, { desc = "Focus below" })
map("n", "<leader>wk", function()
  vscode.call("workbench.action.focusAboveGroup")
end, { desc = "Focus above" })
map("n", "<leader>wl", function()
  vscode.call("workbench.action.focusRightGroup")
end, { desc = "Focus right" })
map("n", "<leader>w=", function()
  vscode.call("workbench.action.evenEditorWidths")
end, { desc = "Equal width" })

-- Buffer 操作
map("n", "<leader>bd", function()
  vscode.call("workbench.action.closeActiveEditor")
end, { desc = "Delete buffer" })
map("n", "<leader>bn", function()
  vscode.call("workbench.action.nextEditor")
end, { desc = "Next buffer" })
map("n", "<leader>bp", function()
  vscode.call("workbench.action.previousEditor")
end, { desc = "Previous buffer" })
map("n", "<leader>bb", function()
  vscode.call("workbench.action.showAllEditors")
end, { desc = "Buffer list" })
map("n", "<leader>bo", function()
  vscode.call("workbench.action.closeOtherEditors")
end, { desc = "Close others" })

-- 切换功能
map("n", "<leader>uw", function()
  vscode.call("editor.action.toggleWordWrap")
end, { desc = "Toggle word wrap" })
map("n", "<leader>un", function()
  vscode.call("workbench.action.toggleSidebarVisibility")
end, { desc = "Toggle sidebar" })
map("n", "<leader>uz", function()
  vscode.call("workbench.action.toggleZenMode")
end, { desc = "Toggle zen mode" })
map("n", "<leader>uf", function()
  vscode.call("workbench.action.toggleFullScreen")
end, { desc = "Toggle fullscreen" })

-- 诊断导航
map("n", "]d", function()
  vscode.call("editor.action.marker.next")
end, { desc = "Next diagnostic" })
map("n", "[d", function()
  vscode.call("editor.action.marker.prev")
end, { desc = "Previous diagnostic" })
map("n", "]e", function()
  vscode.call("editor.action.marker.nextInFiles")
end, { desc = "Next error" })
map("n", "[e", function()
  vscode.call("editor.action.marker.prevInFiles")
end, { desc = "Previous error" })

-- 快速面板
map("n", "<leader>qq", function()
  vscode.call("workbench.action.togglePanel")
end, { desc = "Toggle panel" })
map("n", "<leader>ql", function()
  vscode.call("workbench.panel.markers.view.focus")
end, { desc = "Focus problems" })

-- Tab 操作
map("n", "<leader><tab>n", function()
  vscode.call("workbench.action.nextEditorInGroup")
end, { desc = "Next tab" })
map("n", "<leader><tab>p", function()
  vscode.call("workbench.action.previousEditorInGroup")
end, { desc = "Previous tab" })
map("n", "<leader><tab>d", function()
  vscode.call("workbench.action.closeActiveEditor")
end, { desc = "Close tab" })

-- 终端操作
map("n", "<leader>tt", function()
  vscode.call("workbench.action.terminal.toggleTerminal")
end, { desc = "Toggle terminal" })
map("n", "<leader>tn", function()
  vscode.call("workbench.action.terminal.new")
end, { desc = "New terminal" })
map("n", "<leader>ts", function()
  vscode.call("workbench.action.terminal.split")
end, { desc = "Split terminal" })

-- 快速保存和退出
map("n", "<leader>w", function()
  vscode.call("workbench.action.files.save")
end, { desc = "Save file" })
map("n", "<leader>q", function()
  vscode.call("workbench.action.closeActiveEditor")
end, { desc = "Quit" })
map("n", "<leader>Q", function()
  vscode.call("workbench.action.closeAllEditors")
end, { desc = "Quit all" })

-- 折叠操作（使用 VSCode 命令）
map("n", "za", function()
  vscode.call("editor.toggleFold")
end, { desc = "Toggle fold" })
map("n", "zc", function()
  vscode.call("editor.fold")
end, { desc = "Close fold" })
map("n", "zo", function()
  vscode.call("editor.unfold")
end, { desc = "Open fold" })
map("n", "zM", function()
  vscode.call("editor.foldAll")
end, { desc = "Close all folds" })
map("n", "zR", function()
  vscode.call("editor.unfoldAll")
end, { desc = "Open all folds" })

-- 改进的移动命令
map("n", "H", "^", { desc = "Start of line" })
map("n", "L", ",", { desc = "End of line" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
map("n", "n", "nzzzv", { desc = "Next search" })
map("n", "N", "Nzzzv", { desc = "Previous search" })

-- 更好的缩进
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- 移动行
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- 清除搜索高亮
map("n", "<Esc>", ":nohl<CR>", { desc = "Clear search highlight" })

-- ============================================
-- LazyVim 插件配置（在 VSCode 中可用的）
-- ============================================

return {
  -- Mini.surround（环绕操作）
  {
    "echasnovski/mini.surround",
    vscode = true,
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    },
  },

  -- Which-key（显示快捷键提示）
  {
    "folke/which-key.nvim",
    vscode = true,
    event = "VeryLazy",
    opts = {
      defaults = {
        ["<leader>f"] = { name = "+file" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>l"] = { name = "+lsp" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>w"] = { name = "+window" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>q"] = { name = "+quit/session" },
        ["<leader>t"] = { name = "+terminal" },
        ["<leader><tab>"] = { name = "+tabs" },
      },
    },
  },

  -- Comment.nvim（注释操作）
  {
    "numToStr/Comment.nvim",
    vscode = true,
    opts = {},
    keys = {
      { "gcc", mode = "n", desc = "Comment line" },
      { "gc", mode = { "n", "v" }, desc = "Comment" },
      { "gb", mode = { "n", "v" }, desc = "Comment block" },
    },
  },

  -- nvim-treesitter-textobjects（文本对象）
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    vscode = true,
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]a"] = "@parameter.inner",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[a"] = "@parameter.inner",
            },
          },
        },
      })
    end,
  },
}

-- ============================================
-- LazyVim 配置文件结构（供参考）
-- ============================================
-- 在你的 ~/.config/nvim/init.lua 中添加：
--[[
if vim.g.vscode then
  -- 加载 VSCode 专用配置
  require("config.vscode")
else
  -- 加载正常的 LazyVim 配置
  require("config.lazy")
end
--]]
