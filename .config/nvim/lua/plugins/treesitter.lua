return {

  -- Treesitter config/build/event/cmd now entirely from LazyVim core (was a stale hand-copy
  -- that predated upstream's indent/fold wiring and silently dropped indentexpr/foldexpr).
  -- Only the project's own parser additions survive here; opts_extend merges them into core's list.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "go", "gomod", "gosum", "java", "jsonc", "rust", "mermaid" },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {},
    keys = function()
      local moves = {
        goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
        goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
        goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
      }
      local ret = {} ---@type LazyKeysSpec[]
      for method, keymaps in pairs(moves) do
        for key, query in pairs(keymaps) do
          local desc = query:gsub("@", ""):gsub("%..*", "")
          desc = desc:sub(1, 1):upper() .. desc:sub(2)
          desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
          desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
          ret[#ret + 1] = {
            key,
            function()
              -- don't use treesitter if in diff mode and the key is one of the c/C keys
              if vim.wo.diff and key:find("[cC]") then
                return vim.cmd("normal! " .. key)
              end
              require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
            end,
            desc = desc,
            mode = { "n", "x", "o" },
            silent = true,
          }
        end
      end
      return ret
    end,
    config = function(_, opts)
      local TS = require("nvim-treesitter-textobjects")
      if not TS.setup then
        LazyVim.error("Please use `:Lazy` and update `nvim-treesitter`")
        return
      end
      TS.setup(opts)
    end,
  },

  -- Automatically add closing tags for HTML and JSX
  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = {},
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = {
      max_lines = 3,
      trim_scope = "outer",
    },
    keys = {
      { "g[c", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Jump to context" },
    },
  },
}
