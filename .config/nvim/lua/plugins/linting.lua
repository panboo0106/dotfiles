return {
  {
    "mfussenegger/nvim-lint",
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        svelte = { "eslint_d" },
        python = { "pylint" },
        go = { "golangcilint" },
        fish = { "fish" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      -- lint.linters.golangcilint = {
      --   cmd = "golangci-lint",
      --   append_fname = false,
      --   args = {
      --     "run",
      --     "--output.text.path=stdout",
      --     "--issues-exit-code=0",
      --     function()
      --       -- 动态查找配置文件
      --       local current_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
      --       local config_file = vim.fn.findfile(".golangci.yml", current_dir .. ";")
      --
      --       if config_file == "" then
      --         -- 回退到 nvim 配置目录
      --         local nvim_config = vim.fn.stdpath("config") .. "/.golangci.yml"
      --         if vim.fn.filereadable(nvim_config) == 1 then
      --           config_file = nvim_config
      --         end
      --       end
      --
      --       -- 如果找到配置文件，返回 --config 参数，否则返回空字符串
      --       return config_file ~= "" and ("--config=" .. config_file) or ""
      --     end,
      --     function()
      --       -- 动态返回当前目录
      --       return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
      --     end,
      --   },
      --   stream = "stdout",
      --   ignore_exitcode = true,
      --   name = "golangcilint",
      --   parser = require("lint.parser").from_errorformat(
      --     "%f:%l:%c: %t%*[^:]: %m", -- errorformat 字符串
      --     { source = "another-linter" } -- 默认值
      --   ),
      -- }

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
