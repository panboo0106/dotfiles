return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    optional = true,
    dependencies = { "codeium.nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        compat = { "codeium" },
        providers = {
          codeium = {
            kind = "Codeium",
            score_offset = 100,
            async = true,
          },
        },
      },
      fuzzy = { implementation = "prefer_rust" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      -- Simple configuration to attach to remote java debug process
      local dap = require("dap")
      dap.configurations.java = {
        {
          type = "java",
          request = "attach",
          name = "Debug (Attach) - Remote",
          hostName = "127.0.0.1",
          port = 5005,
        },
      }
    end,
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = {
          ensure_installed = { "java-debug-adapter", "java-test" },
        },
      },
      {
        "mfussenegger/nvim-dap-python",
      -- stylua: ignore
      keys = {
        { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
        { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class", ft = "python" },
      },
        config = function()
          if vim.fn.has("win32") == 1 then
            require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "/venv/Scripts/pythonw.exe"))
          else
            require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "/venv/bin/python"))
          end
        end,
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("which-key").add({
        { "<leader>r", group = "Test" },
        {
          "<leader>tr",
          function()
            require("neotest").run.run()
          end,
          desc = "Run nearest test",
        },
        {
          "<leader>tf",
          function()
            require("neotest").run.run(vim.fn.expand("%"))
          end,
          desc = "Run current file",
        },
        {
          "<leader>ta",
          function()
            require("neotest").run.run({ suite = true })
          end,
          desc = "Run all test",
        },
        {
          "<leader>ts",
          function()
            require("neotest").summary.toggle()
          end,
          desc = "Toggle summary",
        },
        {
          "<leader>tp",
          function()
            require("neotest").output_panel.toggle()
          end,
          desc = "Toggle output panel",
        },
        {
          "<leader>to",
          function()
            require("neotest").output.open()
          end,
          desc = "Show test output",
        },
      })
      require("neotest").setup({
        log_level = 0,
        consumers = {},
        icons = {
          running = "⟳",
          passed = "✓",
          failed = "✗",
          skipped = "⏭",
          unknown = "?",
        },
        -- 高亮配置
        highlights = {
          passed = "Green",
          failed = "Red",
          skipped = "Yellow",
          running = "Blue",
          -- 可以根据需要添加更多
        },
        -- 浮动窗口配置
        floating = {
          border = "rounded", -- 边框样式
          max_height = 0.6, -- 窗口最大高度 (相对于编辑器高度的比例)
          max_width = 0.6, -- 窗口最大宽度 (相对于编辑器宽度的比例)
          options = {}, -- 传递给 nvim_open_win 的选项
        },
        -- 策略配置
        strategies = {
          integrated = {
            width = 120, -- 终端宽度
            height = 40, -- 终端高度
          },
        },
        -- 运行配置
        run = {
          enabled = true, -- 启用运行测试功能
        },
        adapters = {
          require("neotest-python")({
            -- Here you can specify the settings for the adapter, i.e.
            runner = "pytest",
            -- python = ".venv/bin/python",
            python = vim.fn.expand("~/anaconda3/envs/apextest/bin/python"),
          }),
        },
        -- 显示诊断信息
        diagnostic = {
          enabled = true,
          severity = vim.diagnostic.severity.ERROR,
        },

        -- 自动打开输出窗口(测试失败时)
        output = {
          enabled = true,
          open_on_run = true,
          auto_close = true,
        },
        -- 新缺少的字段
        summary = {
          enabled = true,
          expand_errors = true,
          follow = true,
          mappings = {
            attach = "a",
            clear_marked = "M",
            clear_target = "T",
            debug = "d",
            debug_marked = "D",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            jumpto = "i",
            mark = "m",
            output = "o",
            run = "r",
            run_marked = "R",
            short = "O",
            stop = "u",
            target = "t",
          },
        },
        output_panel = {
          enabled = true,
          open = "botright split | resize 15",
        },
        quickfix = {
          enabled = false,
          open = true,
        },
        status = {
          enabled = true,
          signs = true,
          virtual_text = false,
        },
        state = {
          enabled = true,
        },
        watch = {
          enabled = true,
          symbol_queries = {
            enabled = "true",
          },
        },
        projects = {},
      })
    end,
  },
}
