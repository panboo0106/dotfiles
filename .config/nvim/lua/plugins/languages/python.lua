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
    config = function()
      require("venv-selector").setup({
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
      })
    end,
  },
}