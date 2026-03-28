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
        python = { "vulture" }, -- Ruff + Vulture（互补）
        go = { "golangcilint" },
        -- C/C++ (新增)
        cpp = { "clangtidy" },
        c = { "clangtidy" },
        objc = { "clangtidy" },
        cuda = { "clangtidy" },
        -- Shell
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        fish = { "fish" },
        -- Java (新增)
        java = { "checkstyle" },
      }

      -- ============ Vulture 配置（Python 死代码检测，新增）============
      -- vulture 配置（检测未使用的函数、类、变量）
      if vim.fn.exepath("vulture") ~= "" then
        lint.linters.vulture = {
          cmd = "vulture",
          name = "vulture",
          stdin = false,
          append_fname = true,
          args = {
            "--min-confidence",
            "60",
            "--exclude",
            "venv,.venv,virtualenv,env,.env,.tox,.pytest_cache,.mypy_cache,__pycache__,build,dist,node_modules,tests,test_*.py",
          },
          stream = "stdout",
          ignore_exitcode = true,
          parser = function(output, bufnr)
            local diagnostics = {}
            local current_file = vim.api.nvim_buf_get_name(bufnr)
            for line in output:gmatch("[^\r\n]+") do
              local file, lnum, message = line:match("^(.+):(%d+):%s*(.*)$")
              if file and lnum and message then
                if vim.fn.fnamemodify(file, ":p") == current_file then
                  table.insert(diagnostics, {
                    lnum = tonumber(lnum) - 1,
                    col = 0,
                    severity = vim.diagnostic.severity.INFO,
                    message = message .. " (Vulture)",
                    source = "vulture",
                  })
                end
              end
            end
            return diagnostics
          end,
        }
      end

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

      -- ============ clang-tidy 配置（C++ linter）============
      if vim.fn.exepath("clang-tidy") ~= "" then
        lint.linters.clangtidy = {
          cmd = "clang-tidy",
          name = "clang-tidy",
          stdin = false,
          append_fname = true,
          args = {
            "--config-file=" .. vim.fn.stdpath("config") .. "/.clang-tidy",
          },
          stream = "stdout",
          ignore_exitcode = true,
          parser = require("lint.parser").from_errorformat("%f:%l:%c: %t%*[^:]: %m", {
            source = "clang-tidy",
          }),
        }
      end

      -- ============ Checkstyle 配置（Java linter，新增）============
      if vim.fn.exepath("checkstyle") ~= "" then
        lint.linters.checkstyle = {
          cmd = "checkstyle",
          name = "checkstyle",
          stdin = false,
          append_fname = true,
          args = {
            "-c",
            function()
              -- 查找项目配置
              local current_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
              local config_files = { "checkstyle.xml", ".checkstyle.xml", "google_checks.xml" }
              for _, file in ipairs(config_files) do
                local config = vim.fn.findfile(file, current_dir .. ";")
                if config ~= "" then
                  return config
                end
              end
              -- 使用 nvim 默认配置
              local default_config = vim.fn.stdpath("config") .. "/checkstyle.xml"
              if vim.fn.filereadable(default_config) == 1 then
                return default_config
              end
              -- 使用内置 Google 风格
              return "/google_checks.xml"
            end,
            "-f",
            "xml",
          },
          stream = "stdout",
          ignore_exitcode = true,
          parser = function(output, bufnr)
            local diagnostics = {}
            local current_file = vim.api.nvim_buf_get_name(bufnr)
            local current_filename = vim.fn.fnamemodify(current_file, ":t")

            -- 解析 Checkstyle XML 输出（同时捕获文件路径和 XML 块内容）
            for filepath, block in output:gmatch('<file name="([^"]+)">(.-)</file>') do
              local fname = vim.fn.fnamemodify(filepath, ":t")

              -- 只处理当前文件
              if fname == current_filename then
                for error_entry in block:gmatch("<error (.-)/>") do
                  local line = error_entry:match('line="(%d+)"')
                  local col = error_entry:match('column="(%d+)"')
                  local severity_str = error_entry:match('severity="(%w+)"')
                  local message = error_entry:match('message="([^"]+)"')
                  local source = error_entry:match('source="([^"]+)"')

                  if line and message then
                    local severity_map = {
                      error = vim.diagnostic.severity.ERROR,
                      warning = vim.diagnostic.severity.WARN,
                      info = vim.diagnostic.severity.INFO,
                    }
                    local severity = severity_map[severity_str] or vim.diagnostic.severity.WARN

                    table.insert(diagnostics, {
                      lnum = tonumber(line) - 1,
                      col = tonumber(col) and (tonumber(col) - 1) or 0,
                      severity = severity,
                      message = message,
                      source = source or "checkstyle",
                    })
                  end
                end
              end
            end

            return diagnostics
          end,
        }
      end

      -- golangci-lint 配置保持不变
      lint.linters.golangcilint = {
        cmd = vim.fn.exepath("golangci-lint") ~= "" and "golangci-lint"
          or vim.fn.stdpath("data") .. "/mason/bin/golangci-lint",
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
            return config_file ~= "" and ("--config=" .. config_file) or nil
          end,
          function()
            return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
          end,
        },
        stream = "stdout",
        ignore_exitcode = true,
        name = "golangcilint",
        parser = require("lint.parser").from_errorformat("%f:%l:%c: %t%*[^:]: %m", { source = "golangci-lint" }),
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
