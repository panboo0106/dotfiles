return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      filesystem = {
        filtered_items = {
          visible = true, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = true,
          hide_gitignored = false,
          hide_hidden = true, -- only works on Windows for hidden files/directories
          hide_by_name = {
            "node_modules",
          },
          hide_by_pattern = { -- uses glob style patterns
            "*.meta",
            "*/src/*/tsconfig.json",
          },
          always_show = { -- remains visible even if other settings would normally hide it
            ".gitignore",
          },
          never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
            ".DS_Store",
            "thumbs.db",
            ".git",
          },
          never_show_by_pattern = { -- uses glob style patterns
            ".null-ls_*",
          },
        },
      },
      window = {
        -- 展开所有目录
        ["zR"] = "expand_all_nodes",
        -- 展开当前节点下的所有子目录
        ["zr"] = "expand_all_subnodes",
        -- 折叠所有目录
        ["zM"] = "close_all_nodes",
        -- 折叠当前节点下的所有子目录
        ["zm"] = "close_all_subnodes",
        mappings = {
          -- upload (sync files)␍
          ru = {
            function(state)
              vim.cmd("TransferUpload " .. state.tree:get_node().path)
            end,
            desc = "upload file or directory",
            nowait = true,
          },
          -- download (sync files)␍
          rd = {
            function(state)
              vim.cmd("TransferDownload" .. state.tree:get_node().path)
            end,
            desc = "download file or directory",
            nowait = true,
          },
          -- diff directory with remote␍
          rf = {
            function(state)
              local node = state.tree:get_node()
              local context_dir = node.path
              if node.type ~= "directory" then
                -- if not a directory␍
                -- one level up␍
                context_dir = context_dir:gsub("/[^/]*$", "")
              end
              vim.cmd("TransferDirDiff " .. context_dir)
              vim.cmd("Neotree close")
            end,
            desc = "diff with remote",
          },
        },
      },
    },
  },
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
      local edgy_idx = LazyVim.plugin.extra_idx("ui.edgy")
      local symbols_idx = LazyVim.plugin.extra_idx("editor.outline")

      if edgy_idx and edgy_idx > symbols_idx then
        LazyVim.warn(
          "The `edgy.nvim` extra must be **imported** before the `outline.nvim` extra to work properly.",
          { title = "LazyVim" }
        )
      end

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
    requires = "nvim-lua/plenary.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    ft = "yaml",
    opts = {},
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
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
          vim.diagnostic.disable(bufnr)

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
  -- {
  --   "nvim-telescope/telescope.nvim",
  --   cmd = "Telescope",
  --   version = false, -- telescope did only one release, so use HEAD for now
  --   dependencies = {
  --     {
  --       "nvim-telescope/telescope-fzf-native.nvim",
  --     },
  --   },
  --   keys = {
  --     {
  --       "<leader>,",
  --       "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
  --       desc = "Switch Buffer",
  --     },
  --     { "<leader>/", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
  --     { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
  --     { "<leader><space>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
  --     -- find
  --     {
  --       "<leader>fb",
  --       "<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>",
  --       desc = "Buffers",
  --     },
  --     { "<leader>fc", LazyVim.pick.config_files(), desc = "Find Config File" },
  --     { "<leader>ff", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
  --     { "<leader>fF", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
  --     { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
  --     { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
  --     { "<leader>fR", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
  --     -- git
  --     { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
  --     { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
  --     -- search
  --     { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
  --     { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
  --     { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
  --     { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
  --     { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
  --     { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
  --     { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
  --     { "<leader>sg", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
  --     { "<leader>sG", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
  --     { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
  --     { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
  --     { "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
  --     { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
  --     { "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
  --     { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
  --     { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
  --     { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
  --     { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
  --     { "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
  --     { "<leader>sw", LazyVim.pick("grep_string", { word_match = "-w" }), desc = "Word (Root Dir)" },
  --     { "<leader>sW", LazyVim.pick("grep_string", { root = false, word_match = "-w" }), desc = "Word (cwd)" },
  --     { "<leader>sw", LazyVim.pick("grep_string"), mode = "v", desc = "Selection (Root Dir)" },
  --     { "<leader>sW", LazyVim.pick("grep_string", { root = false }), mode = "v", desc = "Selection (cwd)" },
  --     { "<leader>uC", LazyVim.pick("colorscheme", { enable_preview = true }), desc = "Colorscheme with Preview" },
  --     {
  --       "<leader>ss",
  --       function()
  --         require("telescope.builtin").lsp_document_symbols({
  --           symbols = LazyVim.config.get_kind_filter(),
  --         })
  --       end,
  --       desc = "Goto Symbol",
  --     },
  --     {
  --       "<leader>sS",
  --       function()
  --         require("telescope.builtin").lsp_dynamic_workspace_symbols({
  --           symbols = LazyVim.config.get_kind_filter(),
  --         })
  --       end,
  --       desc = "Goto Symbol (Workspace)",
  --     },
  --   },
  --   opts = function()
  --     local actions = require("telescope.actions")
  --
  --     local open_with_trouble = function(...)
  --       return require("trouble.sources.telescope").open(...)
  --     end
  --     local find_files_no_ignore = function()
  --       local action_state = require("telescope.actions.state")
  --       local line = action_state.get_current_line()
  --       LazyVim.pick("find_files", { no_ignore = true, default_text = line })()
  --     end
  --     local find_files_with_hidden = function()
  --       local action_state = require("telescope.actions.state")
  --       local line = action_state.get_current_line()
  --       LazyVim.pick("find_files", { hidden = true, default_text = line })()
  --     end
  --
  --     local function find_command()
  --       if 1 == vim.fn.executable("rg") then
  --         return { "rg", "--files", "--color", "never", "-g", "!.git" }
  --       elseif 1 == vim.fn.executable("fd") then
  --         return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
  --       elseif 1 == vim.fn.executable("fdfind") then
  --         return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
  --       elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
  --         return { "find", ".", "-type", "f" }
  --       elseif 1 == vim.fn.executable("where") then
  --         return { "where", "/r", ".", "*" }
  --       end
  --     end
  --
  --     return {
  --       defaults = {
  --         prompt_prefix = " ",
  --         selection_caret = " ",
  --         -- open files in the first window that is an actual file.
  --         -- use the current window if no other window is available.
  --         get_selection_window = function()
  --           local wins = vim.api.nvim_list_wins()
  --           table.insert(wins, 1, vim.api.nvim_get_current_win())
  --           for _, win in ipairs(wins) do
  --             local buf = vim.api.nvim_win_get_buf(win)
  --             if vim.bo[buf].buftype == "" then
  --               return win
  --             end
  --           end
  --           return 0
  --         end,
  --         mappings = {
  --           i = {
  --             ["<c-t>"] = open_with_trouble,
  --             ["<a-t>"] = open_with_trouble,
  --             ["<a-i>"] = find_files_no_ignore,
  --             ["<a-h>"] = find_files_with_hidden,
  --             ["<C-Down>"] = actions.cycle_history_next,
  --             ["<C-Up>"] = actions.cycle_history_prev,
  --             ["<C-f>"] = actions.preview_scrolling_down,
  --             ["<C-b>"] = actions.preview_scrolling_up,
  --           },
  --           n = {
  --             ["q"] = actions.close,
  --           },
  --         },
  --       },
  --       pickers = {
  --         find_files = {
  --           find_command = find_command,
  --           hidden = true,
  --         },
  --       },
  --     }
  --   end,
  -- },
  -- {
  --   "nvim-telescope/telescope-fzf-native.nvim",
  --   build = (vim.g.build_cmd ~= "cmake") and "make"
  --     or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  --   enabled = vim.g.build_cmd ~= nil,
  --   config = function(plugin)
  --     LazyVim.on_load("telescope.nvim", function()
  --       local ok, err = pcall(require("telescope").load_extension, "fzf")
  --       if not ok then
  --         local lib = plugin.dir .. "/build/libfzf." .. (LazyVim.is_win() and "dll" or "so")
  --         if not vim.uv.fs_stat(lib) then
  --           LazyVim.warn("`telescope-fzf-native.nvim` not built. Rebuilding...")
  --           require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
  --             LazyVim.info("Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim.")
  --           end)
  --         else
  --           LazyVim.error("Failed to load `telescope-fzf-native.nvim`:\n" .. err)
  --         end
  --       end
  --     end)
  --   end,
  -- },
}
