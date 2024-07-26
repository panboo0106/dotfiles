return {
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
        ["go"] = { glyph = "", hl = "MiniIconsAzure" },
      },
    },
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function(_, opts)
      local logo = [[
███╗   ███╗██╗   ██╗    ██████╗  █████╗ ███╗   ██╗██████╗  █████╗ 
████╗ ████║╚██╗ ██╔╝    ██╔══██╗██╔══██╗████╗  ██║██╔══██╗██╔══██╗
██╔████╔██║ ╚████╔╝     ██████╔╝███████║██╔██╗ ██║██║  ██║███████║
██║╚██╔╝██║  ╚██╔╝      ██╔═══╝ ██╔══██║██║╚██╗██║██║  ██║██╔══██║
██║ ╚═╝ ██║   ██║       ██║     ██║  ██║██║ ╚████║██████╔╝██║  ██║
╚═╝     ╚═╝   ╚═╝       ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝
                                                                  
]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"
      opts.config.header = vim.split(logo, "\n")
    end,
  },
}
