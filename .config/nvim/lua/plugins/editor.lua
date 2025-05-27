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
