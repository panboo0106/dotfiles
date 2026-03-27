return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = { "rust" },
    -- opts 必须是函数，避免 IIFE 在启动时执行（rustaceanvim 尚未加载）
    opts = function()
      local codelldb_path = vim.fn.expand("~/.local/share/nvim/mason/packages/codelldb/extension/")
      local codelldb_bin = codelldb_path .. "adapter/codelldb"
      local liblldb = codelldb_path .. "lldb/lib/liblldb"
      local this_os = vim.uv.os_uname().sysname
      liblldb = liblldb .. (this_os == "Linux" and ".so" or ".dylib")

      local adapter
      if vim.fn.filereadable(codelldb_bin) == 1 then
        adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_bin, liblldb)
      else
        vim.notify("codelldb not found. Install with :MasonInstall codelldb", vim.log.levels.WARN)
        adapter = require("rustaceanvim.config").get_rustc_adapter()
      end

      return {
        server = {
          on_attach = function(client, bufnr)
            local wk = require("which-key")
            wk.add({
              -- buffer = bufnr 确保 group 也是 buffer-local，避免与 transfer.nvim 冲突
              { "<leader>r", group = "Rust", icon = "", buffer = bufnr },
              {
                "<leader>rr",
                function() vim.cmd.RustLsp("runnables") end,
                desc = "Runnables",
                buffer = bufnr,
              },
              {
                "<leader>rt",
                function() vim.cmd.RustLsp("testables") end,
                desc = "Testables",
                buffer = bufnr,
              },
              {
                "<leader>rD",
                function() vim.cmd.RustLsp("debuggables") end,
                desc = "Debuggables",
                buffer = bufnr,
              },
              {
                "<leader>re",
                function() vim.cmd.RustLsp("expandMacro") end,
                desc = "Expand Macro",
                buffer = bufnr,
              },
              {
                "<leader>rc",
                function() vim.cmd.RustLsp("openCargo") end,
                desc = "Open Cargo.toml",
                buffer = bufnr,
              },
              {
                "<leader>rp",
                function() vim.cmd.RustLsp("parentModule") end,
                desc = "Parent Module",
                buffer = bufnr,
              },
              {
                "<leader>rh",
                function() vim.cmd.RustLsp({ "hover", "actions" }) end,
                desc = "Hover Actions",
                buffer = bufnr,
              },
              {
                "<leader>ra",
                function() vim.cmd.RustLsp("codeAction") end,
                desc = "Code Action",
                buffer = bufnr,
              },
              {
                "<leader>rx",
                function() vim.cmd.RustLsp("explainError") end,
                desc = "Explain Error",
                buffer = bufnr,
              },
            })
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = { enable = true },
              },
              checkOnSave = true,
              check = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
              inlayHints = {
                bindingModeHints = { enable = false },
                chainingHints = { enable = true },
                closingBraceHints = { enable = true, minLines = 25 },
                closureReturnTypeHints = { enable = "never" },
                lifetimeElisionHints = { enable = "never" },
                parameterHints = { enable = true },
                typeHints = { enable = true },
              },
            },
          },
        },
        dap = { adapter = adapter },
      }
    end,
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
    end,
  },

  -- Cargo.toml 依赖版本提示
  {
    "saecki/crates.nvim",
    ft = "toml",
    opts = {
      completion = {
        cmp = { enabled = true },
      },
    },
  },
}
