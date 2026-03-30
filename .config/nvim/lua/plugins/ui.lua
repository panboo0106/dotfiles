return {
  {
    "nvim-mini/mini.icons",
    lazy = false,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
        ["go"] = { glyph = "", hl = "MiniIconsAzure" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    enabled = true,
    lazy = false,
    priority = 1000,
    dependencies = { "folke/snacks.nvim" },
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        vim.o.statusline = " "
      else
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      -- 禁用 trouble symbols 在 lualine 中显示（避免 Markdown 标题出现在状态栏）
      vim.g.trouble_lualine = false

      -- PERF: we don't need this lualine require madness 🤷
      local lualine_require = require("lualine_require")
      lualine_require.require = require

      local icons = LazyVim.config.icons

      vim.o.laststatus = vim.g.lualine_laststatus

      local opts = {
        options = {
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          theme = "auto",
          globalstatus = vim.o.laststatus == 3,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          },
        },
        sections = {
          lualine_a = {
            {
              "mode",
              icons_enabled = true,
              icon = "󰊠",
              color = { gui = "bold" },
              separator = { left = "", right = "" },
            },
          },
          lualine_b = { "branch" },

          lualine_c = {
            LazyVim.lualine.root_dir(),
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", symbols = { modified = " ●", readonly = " " } },
            -- Python venv 指示（仅在 Python 文件中显示）
            {
              function()
                local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_DEFAULT_ENV
                if venv then
                  return "󰌠 " .. vim.fn.fnamemodify(venv, ":t")
                end
                return ""
              end,
              cond = function()
                return vim.bo.filetype == "python"
              end,
              color = { fg = "#ffbc03" },
            },
          },
          lualine_x = {
            function()
              if package.loaded["snacks"] then
                local status = Snacks.profiler.status()
                return type(status) == "string" and status or ""
              end
              return ""
            end,
          -- stylua: ignore
          {
            function() return require("noice").api.status.command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
            color = function() return package.loaded["snacks"] and { fg = Snacks.util.color("Statement") } or {} end,
          },
          -- stylua: ignore
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
            color = function() return package.loaded["snacks"] and { fg = Snacks.util.color("Constant") } or {} end,
          },
          -- stylua: ignore
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = function() return package.loaded["snacks"] and { fg = Snacks.util.color("Debug") } or {} end,
          },
          -- stylua: ignore
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function() return package.loaded["snacks"] and { fg = Snacks.util.color("Special") } or {} end,
          },
            -- LSP 客户端：1个显示名称，多个显示数量，过滤噪音 LSP
            {
              function()
                local skip = { typos_lsp = true, copilot = true }
                local clients = vim.tbl_filter(function(c)
                  return not skip[c.name]
                end, vim.lsp.get_clients({ bufnr = 0 }))
                if #clients == 0 then
                  return ""
                elseif #clients == 1 then
                  return " " .. clients[1].name
                else
                  return " " .. #clients .. " LSPs"
                end
              end,
              color = { fg = "#2aa198" },
              cond = function()
                return next(vim.lsp.get_clients({ bufnr = 0 })) ~= nil
              end,
            },
            -- encoding：仅在非 UTF-8 时显示
            {
              "encoding",
              fmt = string.upper,
              icon = "󰃤",
              cond = function()
                return (vim.bo.fenc or vim.o.enc):lower() ~= "utf-8"
              end,
            },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
            -- fileformat：仅在非 unix 时显示
            {
              "fileformat",
              symbols = {
                unix = "",
                dos = "",
                mac = "",
              },
              color = { fg = "#cb4b16", gui = "bold" },
              cond = function()
                return vim.bo.fileformat ~= "unix"
              end,
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 }, icon = "󰦨" },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            {
              function()
                return " " .. os.date("%R")
              end,
              refresh = 60000,
            },
          },
        },
        extensions = { "lazy", "fzf", "trouble", "toggleterm", "quickfix" },
      }

      -- do not add trouble symbols if aerial is enabled
      -- And allow it to be overriden for some buffer types (see autocmds)
      if vim.g.trouble_lualine and LazyVim.has("trouble.nvim") then
        local trouble = require("trouble")
        local symbols = trouble.statusline({
          mode = "symbols",
          groups = {},
          title = false,
          filter = { range = true },
          format = "{kind_icon}{symbol.name:Normal}",
          hl_group = "lualine_c_normal",
        })
        -- 只有当 symbols 有效时才添加组件
        if symbols then
          table.insert(opts.sections.lualine_c, {
            symbols.get,
            cond = function()
              return vim.b.trouble_lualine ~= false and symbols.has()
            end,
          })
        end
      end
      return opts
    end,
    config = function(_, opts)
      require("lualine").setup(opts)
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      notify = {
        enabled = false,
      },
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
  {
    "Bekaboo/dropbar.nvim",
    -- optional, but required for fuzzy finder support
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local dropbar_api = require("dropbar.api")
      vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
      vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
      vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
    end,
  },
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    dependencies = { "folke/snacks.nvim", lazy = true },
    keys = {
      { "<leader>-", "<cmd>Yazi<cr>",     mode = { "n", "v" }, desc = "Open Yazi" },
      { "<c-up>",    "<cmd>Yazi toggle<cr>",                    desc = "Resume Yazi" },
    },
    opts = {
      open_for_directories = false,
      keymaps = { show_help = "<f1>" },
    },
  },

  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
      { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
    },
    opts = {
      options = {
      -- stylua: ignore
      close_command = function(n) if package.loaded["snacks"] then Snacks.bufdelete(n) end end,
      -- stylua: ignore
      right_mouse_command = function(n) if package.loaded["snacks"] then Snacks.bufdelete(n) end end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = LazyVim.config.icons.diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "snacks_layout_box",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
        ---@param opts bufferline.IconFetcherOpts
        get_element_icon = function(opts)
          return LazyVim.config.icons.ft[opts.filetype]
        end,
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },

  {
    "NvChad/nvim-colorizer.lua",
    event = "LazyFile",
    opts = {
      "*",
      css = { css = true },
      html = { css = true },
    },
    config = function(_, opts)
      require("colorizer").setup(opts)
    end,
  },
}
