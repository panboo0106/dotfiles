return {
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
        ["go"] = { glyph = "", hl = "MiniIconsAzure" },
      },
    },
  },
  --   {
  --     "nvimdev/dashboard-nvim",
  --     event = "VimEnter",
  --     config = function()
  --       require("dashboard").setup({})
  --     end,
  --     opts = function(_, opts)
  --       local logo = [[
  -- ███╗   ███╗██╗   ██╗    ██████╗  █████╗ ███╗   ██╗██████╗  █████╗
  -- ████╗ ████║╚██╗ ██╔╝    ██╔══██╗██╔══██╗████╗  ██║██╔══██╗██╔══██╗
  -- ██╔████╔██║ ╚████╔╝     ██████╔╝███████║██╔██╗ ██║██║  ██║███████║
  -- ██║╚██╔╝██║  ╚██╔╝      ██╔═══╝ ██╔══██║██║╚██╗██║██║  ██║██╔══██║
  -- ██║ ╚═╝ ██║   ██║       ██║     ██║  ██║██║ ╚████║██████╔╝██║  ██║
  -- ╚═╝     ╚═╝   ╚═╝       ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝
  --
  -- ]]
  --
  --       logo = string.rep("\n", 8) .. logo .. "\n\n"
  --       opts.config.header = vim.split(logo, "\n")
  --     end,
  --   },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Enhanced Lualine configuration with bubbles style
      opts.options = {
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "dashboard", "packer", "neo-tree", "Trouble" },
          winbar = {},
        },
        globalstatus = true, -- Single statusline across all windows
      }

      -- Conditional function to show Codeium status
      opts.sections = {
        lualine_a = {
          {
            "mode",
            icons_enabled = true,
            icon = "",
            color = { gui = "bold" },
          },
        },
        lualine_b = {
          {
            "branch",
            icon = "",
            color = { fg = "#8be9fd" },
          },
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
            diff_color = {
              added = { fg = "#50fa7b" },
              modified = { fg = "#ffb86c" },
              removed = { fg = "#ff5555" },
            },
          },
        },
        lualine_c = {
          {
            "filename",
            file_status = true,
            path = 1,
            symbols = {
              modified = " ●",
              readonly = " ",
              unnamed = "[No Name]",
            },
          },
          {
            "diagnostics",
            sources = { "nvim_lsp", "nvim_diagnostic" },
            sections = { "error", "warn", "info", "hint" },
            symbols = {
              error = " ",
              warn = " ",
              info = " ",
              hint = "💡",
            },
            diagnostics_color = {
              error = { fg = "#ff5555" },
              warn = { fg = "#ffb86c" },
              info = { fg = "#8be9fd" },
              hint = { fg = "#50fa7b" },
            },
          },
        },
        lualine_x = {
          {
            "encoding",
            fmt = string.upper,
            color = { fg = "#bd93f9" },
          },
          {
            "fileformat",
            symbols = { unix = "LF", dos = "CRLF", mac = "CR" },
            color = { fg = "#ff79c6" },
          },
          {
            "filetype",
            icon_only = true,
            colored = true,
          },
        },
        lualine_y = {
          {
            "progress",
            icon = "",
            color = { fg = "#f1fa8c" },
          },
          {
            "location",
            icon = "",
            color = { fg = "#8be9fd" },
          },
        },
        lualine_z = {
          {
            function()
              return os.date("%R")
            end,
            icon = "",
            color = { fg = "#50fa7b", gui = "bold" },
          },
        },
      }
      return opts
    end,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "Exafunction/codeium.vim", -- Optional: Ensure Codeium is installed
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      views = {
        notify = {
          render = "simple",
          replace = true,
        },
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
  -- stylua: ignore
  keys = {
    { "<leader>sn", "", desc = "+noice"},
    { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
    { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
    { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
    { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
    { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
    { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
    { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
    { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
  },
    config = function(_, opts)
      -- HACK: noice shows messages from before it was enabled,
      -- but this is not ideal when Lazy is installing plugins,
      -- so clear the messages in this case.
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      require("noice").setup(opts)
    end,
  },
}
