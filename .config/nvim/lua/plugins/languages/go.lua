return {
  -- dap-go: preserve the project's custom launch configurations
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "leoluz/nvim-dap-go",
        opts = {
          dap_configurations = {
            { type = "go", name = "Debug", request = "launch", program = "${file}" },
            { type = "go", name = "Debug Package", request = "launch", program = "${workspaceFolder}" },
            { type = "go", name = "Attach Remote", mode = "remote", request = "attach" },
          },
          delve = {
            path = "dlv",
            initialize_timeout_sec = 20,
            port = "${port}",
            args = {},
            build_flags = "",
            detached = vim.fn.has("win32") == 0,
            cwd = nil,
          },
          tests = { verbose = false },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>dGt", function() require("dap-go").debug_test() end, desc = "Debug Go Test", ft = "go" },
      { "<leader>dGl", function() require("dap-go").debug_last_test() end, desc = "Debug Last Go Test", ft = "go" },
      { "<leader>dGs", function() require("dap-go").debug_subtest() end, desc = "Debug Go Subtest", ft = "go" },
    },
  },

  -- neotest-golang: replaces archived neotest-go, same flags as before
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "fredrikaverpil/neotest-golang" },
    opts = {
      adapters = {
        ["neotest-golang"] = {
          go_test_args = { "-count=1", "-timeout=60s", "-race", "-cover" },
          dap_go_enabled = true,
        },
      },
    },
  },
}
