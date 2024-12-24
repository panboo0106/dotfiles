return {
  {
    "AckslD/swenv.nvim",
    lazy = false,
    config = function()
      require("swenv").setup({
        -- 配置环境切换后的回调
        post_set_venv = function(venv)
          -- 切换环境后重启 LSP
          vim.cmd("LspRestart")
          -- 可选：打印当前激活的环境
          vim.notify(string.format("Activated env: %s", venv.name), vim.log.levels.INFO)
        end,

        -- 使用插件默认的 get_venvs 函数，它会自动处理:
        -- - conda 环境 (包括 base)
        -- - virtualenv 环境
        -- - pyenv 环境
        -- - pixi 环境
        -- - micromamba 环境
      })

      -- 设置快捷键
      vim.keymap.set("n", "<leader>cv", function()
        require("swenv.api").pick_venv()
      end, { desc = "Choose Python Env" })

      -- -- 可选：自动检测并激活项目虚拟环境
      -- vim.keymap.set("n", "<leader>ca", function()
      --   require("swenv.api").auto_venv()
      -- end, { desc = "Auto Detect Python Env" })

      -- 可选：获取当前环境信息
      vim.keymap.set("n", "<leader>ci", function()
        local current = require("swenv.api").get_current_venv()
        if current then
          vim.notify(
            string.format("Current env:\nName: %s\nPath: %s\nSource: %s", current.name, current.path, current.source),
            vim.log.levels.INFO
          )
        else
          vim.notify("No active environment", vim.log.levels.WARN)
        end
      end, { desc = "Show Python Env Info" })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- 可选：如果要使用 auto_venv 功能
      -- "ahmedkhalf/project.nvim",
    },
  },
}
