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
        python = { "ruff" }, -- 可选pyright
        go = { "golangcilint" },
        fish = { "fish" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

      -- ruff 自定义配置
      lint.linters.ruff = {
        name = "ruff",
        cmd = "ruff",
        stdin = true,
        append_fname = false,
        args = {
          "check",
          "--force-exclude",
          "--quiet",
          "--output-format=json",
          "--stdin-filename",
          function()
            return vim.api.nvim_buf_get_name(0)
          end,
          function()
            -- 动态查找 ruff 配置文件
            local current_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")

            -- 首先在项目中查找 pyproject.toml
            local pyproject = vim.fn.findfile("pyproject.toml", current_dir .. ";")
            if pyproject ~= "" then
              return "--config=" .. pyproject
            end

            -- 然后查找 ruff.toml
            local ruff_toml = vim.fn.findfile("ruff.toml", current_dir .. ";")
            if ruff_toml ~= "" then
              return "--config=" .. ruff_toml
            end

            -- 查找 .ruff.toml
            local dot_ruff = vim.fn.findfile(".ruff.toml", current_dir .. ";")
            if dot_ruff ~= "" then
              return "--config=" .. dot_ruff
            end

            -- 最后回退到 neovim 配置目录的默认配置
            local nvim_config = vim.fn.stdpath("config") .. "/ruff.toml"
            if vim.fn.filereadable(nvim_config) == 1 then
              return "--config=" .. nvim_config
            end

            return ""
          end,
          "-",
        },
        stream = "stdout",
        ignore_exitcode = true,
        parser = function(output, bufnr)
          local diagnostics = {}
          local ok, decoded = pcall(vim.json.decode, output)

          if not ok or not decoded then
            return diagnostics
          end

          for _, item in ipairs(decoded) do
            -- Ruff 的 JSON 格式
            table.insert(diagnostics, {
              lnum = (item.location.row or item.start_location.row) - 1,
              col = (item.location.column or item.start_location.column) - 1,
              end_lnum = (item.end_location and item.end_location.row or item.location.row) - 1,
              end_col = (item.end_location and item.end_location.column or item.location.column),
              severity = vim.diagnostic.severity.WARN,
              message = item.message,
              source = "ruff",
              code = item.code,
            })
          end

          return diagnostics
        end,
      }

      -- golangci-lint 配置保持不变
      lint.linters.golangcilint = {
        cmd = "golangci-lint",
        append_fname = false,
        args = {
          "run",
          "--output.text.path=stdout",
          "--issues-exit-code=0",
          function()
            local current_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
            local config_file = vim.fn.findfile(".golangci.yml", current_dir .. ";")
            if config_file == "" then
              local nvim_config = vim.fn.stdpath("config") .. "/.golangci.yml"
              if vim.fn.filereadable(nvim_config) == 1 then
                config_file = nvim_config
              end
            end
            return config_file ~= "" and ("--config=" .. config_file) or ""
          end,
          function()
            return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
          end,
        },
        stream = "stdout",
        ignore_exitcode = true,
        name = "golangcilint",
        parser = require("lint.parser").from_errorformat("%f:%l:%c: %t%*[^:]: %m", { source = "another-linter" }),
      }

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
