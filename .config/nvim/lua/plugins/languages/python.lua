return {
  {
    "linux-cultist/venv-selector.nvim",
    branch = "main",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    ft = { "python" },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" },
    },
    opts = {
      name = { "venv", ".venv", "env", ".env" },
      search_venv_managers = true,
      search_workspace = true,
      auto_refresh = true,
    },
    config = function()
      require("venv-selector").setup({
        settings = {
          search = {
            anaconda_base = {
              command = "fd /python$ /Users/leo/anaconda3/bin --full-path --color never -E /proc",
              type = "anaconda",
            },
            anaconda_envs = {
              command = "fd /python$ /Users/leo/anaconda3/envs --full-path --color never -E /proc",
              type = "anaconda",
            },
          },
        },
      })
    end,
  },
}