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
}
