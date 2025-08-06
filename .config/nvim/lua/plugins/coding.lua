return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    optional = true,
    dependencies = {
      "codeium.nvim",
      "saghen/blink.compat",
      "L3MON4D3/LuaSnip",
      version = "v2.*",
    },
    opts = {
      snippets = {
        preset = "luasnip",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
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
    recommended = true,
    config = function()
      -- load mason-nvim-dap here, after all adapters have been setup
      if LazyVim.has("mason-nvim-dap.nvim") then
        require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
      end

      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      for name, sign in pairs(LazyVim.config.icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      -- setup dap config by VsCode launch.json file
      local vscode = require("dap.ext.vscode")
      local json = require("plenary.json")
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end
    end,
    dependencies = {
      -- Mason 确保调试器安装
      {
        "williamboman/mason.nvim",
        opts = {
          ensure_installed = {
            "java-debug-adapter",
            "java-test",
            "delve", -- Go debugger
            "debugpy", -- Python debugger
          },
        },
      },

      -- Python 调试支持
      {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        keys = {
          {
            "<leader>dPt",
            function()
              require("dap-python").test_method()
            end,
            desc = "Debug Python Method",
            ft = "python",
          },
          {
            "<leader>dPc",
            function()
              require("dap-python").test_class()
            end,
            desc = "Debug Python Class",
            ft = "python",
          },
          {
            "<leader>dPs",
            function()
              require("dap-python").debug_selection()
            end,
            desc = "Debug Python Selection",
            ft = "python",
          },
        },
        config = function()
          local python_path = vim.fn.has("win32") == 1 and LazyVim.get_pkg_path("debugpy", "/venv/Scripts/pythonw.exe")
            or LazyVim.get_pkg_path("debugpy", "/venv/bin/python")

          require("dap-python").setup(python_path)

          -- 添加额外的 Python 调试配置
          local dap = require("dap")
          table.insert(dap.configurations.python, {
            type = "python",
            request = "attach",
            name = "Attach Remote",
            connect = {
              host = "localhost",
              port = 5678,
            },
          })
        end,
      },

      -- Go 调试支持
      {
        "leoluz/nvim-dap-go",
        ft = "go",
        keys = {
          {
            "<leader>dGt",
            function()
              require("dap-go").debug_test()
            end,
            desc = "Debug Go Test",
            ft = "go",
          },
          {
            "<leader>dGl",
            function()
              require("dap-go").debug_last_test()
            end,
            desc = "Debug Last Go Test",
            ft = "go",
          },
          {
            "<leader>dGs",
            function()
              require("dap-go").debug_subtest()
            end,
            desc = "Debug Go Subtest",
            ft = "go",
          },
        },
        config = function()
          require("dap-go").setup({
            dap_configurations = {
              {
                type = "go",
                name = "Attach Remote",
                mode = "remote",
                request = "attach",
              },
            },
            delve = {
              path = "dlv",
              initialize_timeout_sec = 20,
              port = "${port}",
              args = {},
              build_flags = "",
              detached = vim.fn.has("win32") == 0,
              cwd = nil, -- 使用当前工作目录
            },
            tests = {
              verbose = false,
            },
          })
        end,
      },

      -- Java 调试支持
      {
        "mfussenegger/nvim-jdtls",
        ft = "java",
        optional = true,
      },
    },

    -- 通用调试按键映射
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Conditional Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run to Cursor",
      },
      {
        "<leader>dg",
        function()
          require("dap").goto_()
        end,
        desc = "Go to Line (No Execute)",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<leader>dj",
        function()
          require("dap").down()
        end,
        desc = "Down",
      },
      {
        "<leader>dk",
        function()
          require("dap").up()
        end,
        desc = "Up",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Run Last",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dp",
        function()
          require("dap").pause()
        end,
        desc = "Pause",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "Session",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Widgets",
      },
    },
  },
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    build = (not LazyVim.is_win())
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },
  {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    opts = function()
      LazyVim.cmp.actions.snippet_forward = function()
        if require("luasnip").jumpable(1) then
          vim.schedule(function()
            require("luasnip").jump(1)
          end)
          return true
        end
      end
      LazyVim.cmp.actions.snippet_stop = function()
        if require("luasnip").expand_or_jumpable() then -- or just jumpable(1) is fine?
          require("luasnip").unlink_current()
          return true
        end
      end
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",

      -- 语言适配器
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
      "rcasia/neotest-java",
    },

    opts = {
      -- 适配器配置 - 可以是适配器列表、适配器名称列表或配置表
      adapters = {
        -- Python 适配器
        ["neotest-python"] = {
          dap = { justMyCode = false },
          args = { "--log-level", "DEBUG" },
          runner = "pytest",
          python = vim.fn.expand("~/anaconda3/envs/apextest/bin/python"),
        },

        -- Go 适配器
        ["neotest-go"] = {
          experimental = { test_table = true },
          args = { "-count=1", "-timeout=60s", "-race", "-cover" },
          recursive_run = true,
        },

        -- Java 适配器
        ["neotest-java"] = {
          -- 自动下载 JUnit jar
          junit_jar = nil,
          incremental_build = true,
        },
      },

      -- 状态配置
      status = {
        virtual_text = true,
        signs = true,
      },

      -- 输出配置
      output = {
        open_on_run = true,
      },

      -- Quickfix 配置
      quickfix = {
        open = function()
          -- 如果有 trouble.nvim 则使用它，否则使用标准 quickfix
          if pcall(require, "trouble") then
            require("trouble").open({ mode = "quickfix", focus = false })
          else
            vim.cmd("copen")
          end
        end,
      },
    },

    config = function(_, opts)
      -- 创建 neotest 命名空间用于诊断
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            -- 格式化诊断信息，替换换行和制表符为空格
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)

      -- Trouble.nvim 集成（如果可用）
      if pcall(require, "trouble") then
        opts.consumers = opts.consumers or {}
        -- 测试完成后刷新和自动关闭 trouble
        opts.consumers.trouble = function(client)
          client.listeners.results = function(adapter_id, results, partial)
            if partial then
              return
            end
            local tree = assert(client:get_position(nil, { adapter = adapter_id }))
            local failed = 0
            for pos_id, result in pairs(results) do
              if result.status == "failed" and tree:get_key(pos_id) then
                failed = failed + 1
              end
            end
            vim.schedule(function()
              local trouble = require("trouble")
              if trouble.is_open() then
                trouble.refresh()
                if failed == 0 then
                  trouble.close()
                end
              end
            end)
            return {}
          end
        end
      end

      -- 处理适配器配置
      if opts.adapters then
        local adapters = {}
        for name, config in pairs(opts.adapters or {}) do
          if type(name) == "number" then
            if type(config) == "string" then
              config = require(config)
            end
            adapters[#adapters + 1] = config
          elseif config ~= false then
            local adapter = require(name)
            if type(config) == "table" and not vim.tbl_isempty(config) then
              local meta = getmetatable(adapter)
              if adapter.setup then
                adapter.setup(config)
              elseif adapter.adapter then
                adapter.adapter(config)
                adapter = adapter.adapter
              elseif meta and meta.__call then
                adapter = adapter(config)
              else
                error("Adapter " .. name .. " does not support setup")
              end
            end
            adapters[#adapters + 1] = adapter
          end
        end
        opts.adapters = adapters
      end

      require("neotest").setup(opts)
    end,

    -- 键位映射
    keys = {
      { "<leader>t", "", desc = "+test" },
      {
        "<leader>tt",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run File (Neotest)",
      },
      {
        "<leader>tT",
        function()
          require("neotest").run.run(vim.uv.cwd())
        end,
        desc = "Run All Test Files (Neotest)",
      },
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest (Neotest)",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run Last (Neotest)",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle Summary (Neotest)",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "Show Output (Neotest)",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle Output Panel (Neotest)",
      },
      {
        "<leader>tS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop (Neotest)",
      },
      {
        "<leader>tw",
        function()
          require("neotest").watch.toggle(vim.fn.expand("%"))
        end,
        desc = "Toggle Watch (Neotest)",
      },

      -- 调试支持（需要 nvim-dap）
      {
        "<leader>td",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug Nearest (Neotest)",
      },
    },
  },
}
