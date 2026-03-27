return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = {
          ensure_installed = { "js-debug-adapter" },
        },
      },
    },
    config = function()
      local dap = require("dap")
      local js_debug = vim.fn.expand("~/.local/share/nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js")

      if vim.fn.filereadable(js_debug) ~= 1 then
        vim.notify("js-debug-adapter not found. Install with :MasonInstall js-debug-adapter", vim.log.levels.WARN)
        return
      end

      for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.adapters[lang] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = { js_debug, "${port}" },
          },
        }
      end

      for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[lang] = {
          {
            type = lang,
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
          },
          {
            type = lang,
            request = "launch",
            name = "Launch Node (npm start)",
            runtimeExecutable = "npm",
            runtimeArgs = { "run", "start" },
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**" },
          },
          {
            type = lang,
            request = "attach",
            name = "Attach to Node process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
          },
          {
            type = lang,
            request = "launch",
            name = "Debug Jest tests",
            runtimeExecutable = "node",
            runtimeArgs = {
              "./node_modules/.bin/jest",
              "--runInBand",
              "--testPathPattern",
              "${file}",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "node_modules/**" },
          },
          {
            type = lang,
            request = "launch",
            name = "Debug Next.js",
            runtimeExecutable = "node",
            runtimeArgs = {
              "--inspect",
              "./node_modules/.bin/next",
              "dev",
            },
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "node_modules/**" },
            port = 9229,
          },
        }
      end
    end,
  },
}
