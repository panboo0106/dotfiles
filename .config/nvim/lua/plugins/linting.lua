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
        python = { "vulture" }, -- Ruff + Vulture（互补）
        go = { "golangcilint" },
        -- C/C++ (新增)
        cpp = { "clangtidy" },
        c = { "clangtidy" },
        objc = { "clangtidy" },
        cuda = { "clangtidy" },
        -- Shell (已有)
        fish = { "fish" },
        -- Java (新增)
        java = { "checkstyle" },
      }

      -- eslint_d 配置（如果安装了的话）
      if vim.fn.exepath("eslint_d") ~= "" then
        lint.linters.eslint_d = {
          cmd = "eslint_d",
          name = "eslint_d",
          stdin = true,
          append_fname = false,
          args = {},
          stream = "stdout",
          ignore_exitcode = true,
          parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
            source = "eslint_d",
          }),
        }
      end

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

      -- if vim.fn.exepath("vulture") ~= "" then
      --   lint.linters.vulture = {
      --     cmd = "vulture",
      --     name = "vulture",
      --     stdin = false, -- vulture 需要文件路径
      --     append_fname = true,
      --     args = {
      --       "--min-confidence", -- 最小置信度阈值（0-100）
      --       "60", -- 默认 60，可调整
      --       "--exclude", -- 排除常见目录
      --       "venv,.venv,virtualenv,env,.env,.tox,.pytest_cache,.mypy_cache,__pycache__,build,dist,node_modules,tests,test_*.py",
      --     },
      --     stream = "stdout",
      --     ignore_exitcode = true,
      --     parser = function(output, bufnr)
      --       local diagnostics = {}
      --       local current_file = vim.api.nvim_buf_get_name(bufnr)
      --
      --       -- vulture 输出格式: filename:line: (column: ) message
      --       -- 例如: /path/to/file.py:42: unused function 'my_function'
      --       for line in output:gmatch("[^\r\n]+") do
      --         local file, lnum, message = line:match("^(.+):(%d+):%s*(.*)$")
      --         if file and lnum and message then
      --           -- 只显示当前文件的诊断
      --           if vim.fn.fnamemodify(file, ":p") == current_file then
      --             -- 判断严重程度
      --             local severity = vim.diagnostic.severity.INFO
      --             local lower_msg = message:lower()
      --
      --             -- "unused" 开头的通常是未使用的代码
      --             if lower_msg:match("^unused") then
      --               severity = vim.diagnostic.severity.INFO
      --             end
      --
      --             table.insert(diagnostics, {
      --               lnum = tonumber(lnum) - 1,
      --               col = 0,
      --               severity = severity,
      --               message = message .. " (Vulture)",
      --               source = "vulture",
      --             })
      --           end
      --         end
      --       end
      --
      --       return diagnostics
      --     end,
      --   }
      -- end

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

      -- ============ Ruff 配置（Python linter）============
      -- if vim.fn.exepath("ruff") ~= "" then
      --   lint.linters.ruff = {
      --     name = "ruff",
      --     cmd = vim.fn.exepath("ruff") ~= "" and "ruff" or vim.fn.stdpath("data") .. "/mason/bin/ruff",
      --     stdin = true,
      --     append_fname = false,
      --     args = {
      --       "check",
      --       "--force-exclude",
      --       "--output-format=json",
      --       "--stdin-filename",
      --       function()
      --         return vim.api.nvim_buf_get_name(0)
      --       end,
      --       function()
      --         -- 动态查找 ruff 配置文件
      --         local current_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
      --
      --         -- 首先在项目中查找 pyproject.toml
      --         local pyproject = vim.fn.findfile("pyproject.toml", current_dir .. ";")
      --         if pyproject ~= "" then
      --           return "--config=" .. pyproject
      --         end
      --
      --         -- 然后查找 ruff.toml
      --         local ruff_toml = vim.fn.findfile("ruff.toml", current_dir .. ";")
      --         if ruff_toml ~= "" then
      --           return "--config=" .. ruff_toml
      --         end
      --
      --         -- 查找 .ruff.toml
      --         local dot_ruff = vim.fn.findfile(".ruff.toml", current_dir .. ";")
      --         if dot_ruff ~= "" then
      --           return "--config=" .. dot_ruff
      --         end
      --
      --         -- 最后回退到 neovim 配置目录的默认配置
      --         local nvim_config = vim.fn.stdpath("config") .. "/ruff.toml"
      --         if vim.fn.filereadable(nvim_config) == 1 then
      --           return "--config=" .. nvim_config
      --         end
      --
      --         return ""
      --       end,
      --       "-",
      --     },
      --     stream = "stdout",
      --     ignore_exitcode = true,
      --     parser = function(output, bufnr)
      --       local diagnostics = {}
      --       local ok, decoded = pcall(vim.json.decode, output)
      --
      --       if not ok or not decoded then
      --         return diagnostics
      --       end
      --
      --       for _, item in ipairs(decoded) do
      --         -- Ruff 的 JSON 格式
      --         table.insert(diagnostics, {
      --           lnum = (item.location.row or item.start_location.row) - 1,
      --           col = (item.location.column or item.start_location.column) - 1,
      --           end_lnum = (item.end_location and item.end_location.row or item.location.row) - 1,
      --           end_col = (item.end_location and item.end_location.column or item.location.column),
      --           severity = vim.diagnostic.severity.WARN,
      --           message = item.message,
      --           source = "ruff",
      --           code = item.code,
      --         })
      --       end
      --
      --       return diagnostics
      --     end,
      --   }
      -- end

      -- ============ clang-tidy 配置（C++ linter，新增）============
      if vim.fn.exepath("clang-tidy") ~= "" then
        lint.linters.clangtidy = {
          cmd = "clang-tidy",
          name = "clang-tidy",
          stdin = false,
          append_fname = true,
          args = {
            "--config-file=" .. vim.fn.stdpath("config") .. "/.clang-tidy",
            "--background-index",
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

            -- 解析 Checkstyle XML 输出
            for file_entry in output:gmatch('<file name="([^"]+)">.-</file>') do
              local filepath = file_entry:match('^([^"]+)')
              local fname = vim.fn.fnamemodify(filepath, ":t")

              -- 只处理当前文件
              if fname == current_filename then
                for error_entry in file_entry:gmatch("<error (.-)/>") do
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
