return {
  -- 替代 Treesitter 的 Python indent（TS Python indent 有长期 bug）
  -- https://github.com/nvim-treesitter/nvim-treesitter/issues/2947
  {
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  },
  {
    "linux-cultist/venv-selector.nvim",
    branch = "main",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap-python",
    },
    ft = { "python" },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" },
    },
    -- opts (not a hardcoded config() table) so extras.lang.python's own venv-selector
    -- fragment deep-merges in instead of being silently discarded.
    opts = {
      settings = {
        search = {
          anaconda_base = {
            command = "fd /python$ " .. vim.fn.expand("~") .. "/anaconda3/bin --full-path --color never -E /proc",
            type = "anaconda",
          },
          anaconda_envs = {
            command = "fd /python$ " .. vim.fn.expand("~") .. "/anaconda3/envs --full-path --color never -E /proc",
            type = "anaconda",
          },
        },
      },
    },
    config = function(_, opts)
      require("venv-selector").setup(opts)
    end,
  },

  -- dap-python: relocated from coding.lua, all 8 original launch configs preserved verbatim
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        keys = {
          {
            "<leader>dPt",
            function() require("dap-python").test_method() end,
            desc = "Debug Python Method",
            ft = "python",
          },
          {
            "<leader>dPc",
            function() require("dap-python").test_class() end,
            desc = "Debug Python Class",
            ft = "python",
          },
          {
            "<leader>dPs",
            function() require("dap-python").debug_selection() end,
            desc = "Debug Python Selection",
            ft = "python",
          },
        },
        config = function()
          local mason_debugpy = vim.fn.expand("$HOME") .. "/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
          local debugpy_cmd = vim.fn.executable("python3") == 1 and "python3" or "python"
          if vim.fn.executable(mason_debugpy) == 1 then
            debugpy_cmd = mason_debugpy
          end
          require("dap-python").setup(debugpy_cmd)

          local dap = require("dap")
          dap.configurations.python = {
            {
              type = "python",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              pythonPath = debugpy_cmd,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "launch",
              name = "Launch file with arguments",
              program = "${file}",
              args = function()
                local args_string = vim.fn.input("Arguments: ")
                return vim.split(args_string, " +")
              end,
              pythonPath = debugpy_cmd,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "launch",
              name = "Launch current module",
              module = function()
                return vim.fn.input("Module name: ")
              end,
              pythonPath = debugpy_cmd,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "attach",
              name = "Attach remote",
              connect = {
                host = "localhost",
                port = function()
                  return tonumber(vim.fn.input("Port: ")) or 5678
                end,
              },
              mode = "remote",
              pythonPath = debugpy_cmd,
            },
            {
              type = "python",
              request = "attach",
              name = "Attach local",
              processId = function()
                return require("dap.utils").pick_process()
              end,
              pythonPath = debugpy_cmd,
            },
            {
              type = "python",
              request = "launch",
              name = "Debug Django",
              program = function()
                return vim.fn.getcwd() .. "/manage.py"
              end,
              args = { "runserver", "--noreload" },
              justMyCode = false,
              pythonPath = debugpy_cmd,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "launch",
              name = "Debug Flask",
              module = "flask",
              args = { "run", "--no-debugger", "--no-reload" },
              justMyCode = false,
              pythonPath = debugpy_cmd,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "launch",
              name = "Pytest",
              module = "pytest",
              args = function()
                return vim.fn.input("Pytest args: ")
              end,
              justMyCode = false,
              pythonPath = debugpy_cmd,
              console = "integratedTerminal",
            },
          }
        end,
      },
    },
  },

  -- neotest-python adapter: relocated from coding.lua, same config
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = {
      adapters = {
        ["neotest-python"] = {
          dap = { justMyCode = false },
          args = { "--log-level", "DEBUG" },
          runner = "pytest",
          python = (function()
            local py = vim.fn.exepath("python3")
            return py ~= "" and py or vim.fn.exepath("python")
          end)(),
        },
      },
    },
  },
}