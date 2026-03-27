return {
  {
    "hedyhli/outline.nvim",
    keys = { { "<leader>cs", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
    cmd = "Outline",
    opts = function()
      local defaults = require("outline.config").defaults
      local opts = {
        symbols = {
          icons = {},
          filter = vim.deepcopy(LazyVim.config.kind_filter),
        },
        keymaps = {
          up_and_jump = "<up>",
          down_and_jump = "<down>",
        },
      }

      for kind, symbol in pairs(defaults.symbols.icons) do
        opts.symbols.icons[kind] = {
          icon = LazyVim.config.icons.kinds[kind] or symbol.icon,
          hl = symbol.hl,
        }
      end
      return opts
    end,
  },
  {
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      opts.left = opts.left or {}
      table.insert(opts.left, {
        title = "Outline",
        ft = "Outline",
        pinned = true,
        open = "Outline",
      })
    end,
  },
  {
    "allaman/kustomize.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    ft = "yaml",
    opts = {},
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
      watch_gitdir = {
        follow_files = true,
      },
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = true,
        virt_text_priority = 100,
        use_focus = true,
      },
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")
        map("n", "]H", function()
          gs.nav_hunk("last")
        end, "Last Hunk")
        map("n", "[H", function()
          gs.nav_hunk("first")
        end, "First Hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>ghB", function()
          gs.blame()
        end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function()
          gs.diffthis("~")
        end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        -- 添加快速切换到 diffview 的快捷键
        map("n", "<leader>ghv", "<cmd>DiffviewOpen<cr>", "Open Diffview")
      end,
    },
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    keys = {
      -- Diffview 快捷键（使用 <leader>gd 前缀，避免与 gitsigns 冲突）
      { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Open diffview" },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
      { "<leader>gdr", "<cmd>DiffviewRefresh<cr>", desc = "Refresh diffview" },
      { "<leader>gdf", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle diffview files" },
      { "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current)" },
      { "<leader>gdH", "<cmd>DiffviewFileHistory<cr>", desc = "File history (all)" },

      -- 快速比较快捷键
      { "<leader>gdm", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diff with main" },
      { "<leader>gds", "<cmd>DiffviewOpen --staged<cr>", desc = "Diff staged" },
      { "<leader>gdl", "<cmd>DiffviewFileHistory --follow %<cr>", desc = "File log (follow)" },

      -- 合并冲突解决
      { "<leader>gco", "<cmd>DiffviewOpen --merge<cr>", desc = "Open merge view" },
    },
    opts = {
      -- Diffview 配置选项
      diff_binaries = false,
      enhanced_diff_hl = true, -- 增强的 diff 高亮
      git_cmd = { "git" },
      use_icons = true,

      -- 图标配置（与 LazyVim 风格一致）
      icons = {
        folder_closed = "",
        folder_open = "",
      },

      -- 标记配置（与 gitsigns 风格保持一致）
      signs = {
        fold_closed = "",
        fold_open = "",
        done = "✓",
      },

      -- 视图配置
      view = {
        default = {
          layout = "diff2_horizontal",
          winbar_info = false,
        },
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          winbar_info = false,
        },
      },

      -- 文件面板配置
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
          win_opts = {},
        },
      },

      -- 文件历史面板
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              diff_merges = "combined",
            },
            multi_file = {
              diff_merges = "first-parent",
            },
          },
        },
        win_config = {
          position = "bottom",
          height = 16,
          win_opts = {},
        },
      },

      -- 提交日志视图
      commit_log_panel = {
        win_config = {
          win_opts = {},
        },
      },

      -- 默认参数
      default_args = {
        DiffviewOpen = {},
        DiffviewFileHistory = {},
      },

      -- 钩子函数
      hooks = {
        diff_buf_read = function(bufnr)
          -- 在 diff buffer 中禁用诊断显示
          vim.diagnostic.enable(false, { bufnr = bufnr })

          -- 对 Go 文件特殊处理（解决 tab 显示问题）
          if vim.bo[bufnr].filetype == "go" then
            vim.opt_local.list = false
          end
        end,

        view_opened = function(view)
          -- 视图打开时的处理
        end,

        view_closed = function(view)
          -- 视图关闭时的处理
        end,

        view_entered = function(view)
          -- 进入视图时自动聚焦到文件面板
          if view.panel then
            vim.cmd("DiffviewFocusFiles")
          end
        end,
      },

      -- 快捷键映射（Diffview 内部使用）
      keymaps = {
        disable_defaults = false,
        view = {
          -- 与 LazyVim 快捷键风格一致
          ["<tab>"] = "<cmd>DiffviewToggleFiles<cr>",
          ["gf"] = "<cmd>DiffviewGotoFile<cr>",
          ["<C-w>gf"] = "<cmd>DiffviewGotoFile split<cr>",
          ["[x"] = "<cmd>DiffviewPrevConflict<cr>",
          ["]x"] = "<cmd>DiffviewNextConflict<cr>",
          ["<leader>co"] = "<cmd>DiffviewConflictChooseOurs<cr>",
          ["<leader>ct"] = "<cmd>DiffviewConflictChooseTheirs<cr>",
          ["<leader>cb"] = "<cmd>DiffviewConflictChooseBoth<cr>",
          ["<leader>ca"] = "<cmd>DiffviewConflictChooseAll<cr>",
          ["dx"] = "<cmd>DiffviewConflictDelete<cr>",
        },
        diff3 = {
          -- 三方合并视图快捷键
          { { "n", "x" }, "2do", "<cmd>DiffviewDiffGet('ours')<cr>", { desc = "Get ours" } },
          { { "n", "x" }, "3do", "<cmd>DiffviewDiffGet('theirs')<cr>", { desc = "Get theirs" } },
        },
        diff4 = {
          -- 四方合并视图快捷键
          { { "n", "x" }, "1do", "<cmd>DiffviewDiffGet('base')<cr>", { desc = "Get base" } },
          { { "n", "x" }, "2do", "<cmd>DiffviewDiffGet('ours')<cr>", { desc = "Get ours" } },
          { { "n", "x" }, "3do", "<cmd>DiffviewDiffGet('theirs')<cr>", { desc = "Get theirs" } },
        },
        file_panel = {
          ["j"] = "<cmd>DiffviewNextEntry<cr>",
          ["<down>"] = "<cmd>DiffviewNextEntry<cr>",
          ["k"] = "<cmd>DiffviewPrevEntry<cr>",
          ["<up>"] = "<cmd>DiffviewPrevEntry<cr>",
          ["<cr>"] = "<cmd>DiffviewSelectEntry<cr>",
          ["o"] = "<cmd>DiffviewSelectEntry<cr>",
          ["<2-LeftMouse>"] = "<cmd>DiffviewSelectEntry<cr>",
          ["-"] = "<cmd>DiffviewToggleStage<cr>",
          ["S"] = "<cmd>DiffviewStageAll<cr>",
          ["U"] = "<cmd>DiffviewUnstageAll<cr>",
          ["X"] = "<cmd>DiffviewRestoreEntry<cr>",
          ["L"] = "<cmd>DiffviewOpenCommitLog<cr>",
          ["<c-b>"] = "<cmd>DiffviewScrollDown<cr>",
          ["<c-f>"] = "<cmd>DiffviewScrollUp<cr>",
          ["<tab>"] = "<cmd>DiffviewToggleFiles<cr>",
          ["gf"] = "<cmd>DiffviewGotoFile<cr>",
          ["<C-w>gf"] = "<cmd>DiffviewGotoFile split<cr>",
          ["i"] = "<cmd>DiffviewFocusFiles<cr>",
          ["R"] = "<cmd>DiffviewRefresh<cr>",
        },
        file_history_panel = {
          ["g!"] = "<cmd>DiffviewOptions<cr>",
          ["<C-A-d>"] = "<cmd>DiffviewOpenDiff<cr>",
          ["y"] = "<cmd>DiffviewCopyHash<cr>",
          ["L"] = "<cmd>DiffviewOpenCommitLog<cr>",
          ["zR"] = "<cmd>DiffviewExpandAllFolds<cr>",
          ["zM"] = "<cmd>DiffviewCollapseAllFolds<cr>",
          ["j"] = "<cmd>DiffviewNextEntry<cr>",
          ["<down>"] = "<cmd>DiffviewNextEntry<cr>",
          ["k"] = "<cmd>DiffviewPrevEntry<cr>",
          ["<up>"] = "<cmd>DiffviewPrevEntry<cr>",
          ["<cr>"] = "<cmd>DiffviewSelectEntry<cr>",
          ["o"] = "<cmd>DiffviewSelectEntry<cr>",
          ["<2-LeftMouse>"] = "<cmd>DiffviewSelectEntry<cr>",
          ["<tab>"] = "<cmd>DiffviewToggleFiles<cr>",
          ["gf"] = "<cmd>DiffviewGotoFile<cr>",
          ["<C-w>gf"] = "<cmd>DiffviewGotoFile split<cr>",
          ["<C-w><C-f>"] = "<cmd>DiffviewGotoFile tabnew<cr>",
        },
        option_panel = {
          ["<tab>"] = "<cmd>DiffviewSelectEntry<cr>",
          ["q"] = "<cmd>DiffviewClose<cr>",
        },
      },
    },
    config = function(_, opts)
      require("diffview").setup(opts)

      -- 额外的配置或自动命令
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "DiffviewFiles", "DiffviewFileHistory" },
        callback = function()
          -- 在 Diffview 窗口中的特殊设置
          vim.opt_local.cursorline = true
          vim.opt_local.signcolumn = "yes"
        end,
      })

      -- 为 Go 文件创建特殊处理
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        callback = function()
          -- 创建一个专门的命令来查看 Go 文件的 diff
          vim.api.nvim_buf_create_user_command(0, "DiffviewGoOpen", function()
            vim.opt_local.list = false
            vim.cmd("DiffviewOpen")
          end, {})
        end,
      })
    end,
  },

  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    cmd = { "Neogit" },
    keys = {
      { "<leader>gn",  "<cmd>Neogit<cr>",        desc = "Neogit" },
      { "<leader>gnc", "<cmd>Neogit commit<cr>",  desc = "Neogit Commit" },
      { "<leader>gnb", "<cmd>Neogit branch<cr>",  desc = "Neogit Branch" },
      { "<leader>gnl", "<cmd>Neogit log<cr>",     desc = "Neogit Log" },
      { "<leader>gp",  "<cmd>Neogit pull<cr>",    desc = "Neogit Pull" },
    },
    opts = {
      integrations = { diffview = true },
    },
  },

  {
    "akinsho/git-conflict.nvim",
    event = "LazyFile",
    opts = {
      default_mappings = true,
      disable_diagnostics = true,
    },
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      local harpoon = require("harpoon")
      return {
        { "<leader>ha",  function() harpoon:list():add() end,                          desc = "Harpoon Add" },
        { "<leader>hh",  function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon Menu" },
        { "<leader>h1",  function() harpoon:list():select(1) end,                     desc = "Harpoon 1" },
        { "<leader>h2",  function() harpoon:list():select(2) end,                     desc = "Harpoon 2" },
        { "<leader>h3",  function() harpoon:list():select(3) end,                     desc = "Harpoon 3" },
        { "<leader>h4",  function() harpoon:list():select(4) end,                     desc = "Harpoon 4" },
      }
    end,
    opts = {},
  },

  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      preview = { auto_preview = true },
    },
  },

  {
    "mg979/vim-visual-multi",
    event = "LazyFile",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"]         = "<C-n>",
        ["Find Subword Under"] = "<C-n>",
      }
    end,
  },

  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "LazyFile",
    opts = {
      provider_selector = function(bufnr, filetype, buftype)
        -- 使用 lsp 作为 main，indent 作为 fallback（比 treesitter 更稳定）
        return { "lsp", "indent" }
      end,
    },
    init = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    keys = {
      { "zR", function() require("ufo").openAllFolds() end,  desc = "Open All Folds" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "Close All Folds" },
      { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "Open Folds (except kinds)" },
      { "zm", function() require("ufo").closeFoldsWith() end, desc = "Close Folds" },
      {
        "K",
        function()
          local winid = require("ufo").peekFoldedLinesUnderCursor()
          if not winid then
            vim.lsp.buf.hover()
          end
        end,
        desc = "Hover / Peek Fold",
      },
    },
  },
}
