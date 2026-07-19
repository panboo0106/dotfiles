# LazyVim Extras Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace hand-copied LazyVim core/extra spec files (treesitter-style drift risk, silent dead code, one confirmed live bug) with official `lazyvim.plugins.extras.*` imports, keeping every genuine personal customization as a small `opts`/`keys` increment layered on top.

**Architecture:** This repo is a LazyVim 16 config (`~/.config/nvim`, not a git repo — see Task 0 for the safety net). `lua/config/lazy.lua` currently hand-imports 4 extras (`lang.vue`, `lang.typescript`, `lang.json`, `lang.git`) before `{ import = "plugins" }`. We add more extras to that same list, in the same position (before `{ import = "plugins" }`, so our own fragments always resolve last and win table-merge conflicts). Then we strip the corresponding hand-copied blocks out of `lua/plugins/{lsp,coding,formatting}.lua` and `lua/plugins/languages/*.lua`, replacing each with either nothing (pure duplicate) or a minimal fragment carrying only the real customization.

**Tech Stack:** Neovim 0.12.3, lazy.nvim (main), LazyVim 16 (main branch), Lua.

## Global Constraints

- No git repo in this directory (`git rev-parse --is-inside-work-tree` → fatal). No commit steps; Task 0 makes a filesystem backup instead. Do not run `git init` unless the user asks.
- Every "Modify" step shows exact before/after content. Apply with the `Edit` tool using the `old_string`/`new_string` shown — do not retype from memory.
- Fragment ordering rule: any new fragment for a plugin we're also customizing must NOT define its own `config = function(...)` unless it is deliberately meant to fully replace the plugin's config (lazy.nvim runs only the *last*-merged `config` function, full stop — this is exactly how the pre-existing `nvim-dap` bug happened, see Task 1). Prefer `opts` for anything that should merge.
- **Known dead-merge trap (do not try to "fix" during this migration, out of scope):** `lua/plugins/linting.lua` and the `venv-selector.nvim` block in `lua/plugins/languages/python.lua` both define `config = function() ... end` with no `opts` parameter used — they rebuild their tables from scratch and silently ignore any `opts` contributed by other fragments (including extras). This means the `lang.go`/`lang.markdown` extras' `nvim-lint` fragments, and the `lang.python` extra's `venv-selector` fragment, are no-ops once merged — expected and harmless, not a bug to chase in this plan.
- Task order is **not** the same order the user approved at the plan-conversation level (`luasnip/eslint/clangd → go/python/rust → test.core → markdown`). It has been reordered for correctness: `dap.core` and `test.core` must land *before* `go`/`python`/`rust`, because those three tasks attach `optional = true` fragments to `nvim-dap` and `nvim-neotest/neotest` — an `optional` fragment only takes effect if some *other*, non-optional fragment for the same plugin already exists in the merged spec. Landing `dap.core`/`test.core` first establishes that anchor cleanly, instead of having two competing non-optional definitions (the current bug) or a dangling optional fragment that silently does nothing. `luasnip`/`eslint`/`clangd`/`markdown` have no such dependency and keep their original relative order.
- Decisions already resolved in the prior conversation (do not re-litigate): (a) Java is **out of scope** for this migration — `lua/plugins/languages/java.lua` is untouched; (b) the neotest keybindings move back from `<leader>T*` (current hand-rolled prefix) — wait, corrected: they move **from the extra's default `<leader>t*` back to the project's existing `<leader>T*`**, to avoid colliding with the terminal keymaps already on `<leader>t*` in `lua/config/keymaps.lua`.

---

### Task 0: Filesystem backup (safety net, no git in this repo)

**Files:**
- Create: `/tmp/nvim-config-backup-2026-07-19.tar.gz` (outside the repo, temporary)

**Refactor: behavior unchanged** — this task touches nothing under `~/.config/nvim`, it only snapshots it.

- [ ] **Step 1: Snapshot the current `lua/` tree and lock files**

Run:
```bash
cd /Users/leo/.config/nvim && tar czf /tmp/nvim-config-backup-2026-07-19.tar.gz lua/ init.lua lazyvim.json lazy-lock.json
```
Expected: exits 0, file appears.

- [ ] **Step 2: Verify the archive is readable**

Run:
```bash
tar tzf /tmp/nvim-config-backup-2026-07-19.tar.gz | head -5
```
Expected: lists `lua/config/lazy.lua`, `lua/plugins/...` etc.

If any later task needs to be rolled back, restore a single file with:
```bash
tar xzf /tmp/nvim-config-backup-2026-07-19.tar.gz -O lua/plugins/coding.lua > /Users/leo/.config/nvim/lua/plugins/coding.lua
```

---

### Task 1: Migrate `dap.core` (foundation — also fixes the live double-`config` bug)

**Files:**
- Modify: `lua/config/lazy.lua:28`
- Modify: `lua/plugins/coding.lua:55-488` (delete), keep lines 1-54 and 489+ (renumber follows)
- Modify: `lua/plugins/languages/javascript.lua` (delete entire file)
- Modify: `lua/plugins/lang.lua:7` (remove javascript import)
- Modify: `lua/plugins/lsp.lua` (add 5 mason `ensure_installed` entries that were only reachable via the block being deleted)

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: a single non-optional `mfussenegger/nvim-dap` anchor (via the extra) that Tasks 6/7/8 (go/python/rust) will attach `optional = true` fragments to.

**Refactor: fixes a confirmed bug** — currently `coding.lua` and `languages/javascript.lua` both define `config` for `nvim-dap`; lazy.nvim only runs the last-merged one (`javascript.lua`'s, confirmed by headless test: `DapBreakpoint` sign showed `B ` instead of LazyVim's icon, and `dap.ext.vscode.json_decode` was never patched to strip JSON5 comments from `launch.json`). After this task there is exactly one `nvim-dap` config source (the extra), and it fixes both symptoms.

- [ ] **Step 1: Verify current broken state (before editing anything)**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-dap'}})" "+lua local s=vim.fn.sign_getdefined('DapBreakpoint')[1]; print('SIGN='..(s and s.text or 'nil'))" "+lua local v=require('dap.ext.vscode'); print('JSON5_PATCHED='..tostring(v.json_decode ~= vim.json.decode))" "+qall" 2>&1 | tail -3
```
Expected: `SIGN=B ` (plain nvim-dap default, not a LazyVim icon) and `JSON5_PATCHED=false`.

- [ ] **Step 2: Add the `dap.core` extra import to `lazy.lua`**

Modify `lua/config/lazy.lua`, old_string:
```lua
    { import = "lazyvim.plugins.extras.lang.git" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```
new_string:
```lua
    { import = "lazyvim.plugins.extras.lang.git" },
    { import = "lazyvim.plugins.extras.dap.core" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```

- [ ] **Step 3: Delete the entire hand-rolled `nvim-dap` block from `coding.lua`**

The block runs from the `{ "mfussenegger/nvim-dap", recommended = true, config = function() ...` opening (line 55) through the end of its `keys` table, immediately before the `L3MON4D3/LuaSnip` entry. Modify `lua/plugins/coding.lua`, old_string is the entire block from:
```lua
  {
    "mfussenegger/nvim-dap",
    recommended = true,
    config = function()
      -- load mason-nvim-dap here, after all adapters have been setup
```
through (inclusive) the closing of the generic DAP `keys` table:
```lua
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Widgets",
      },
    },
  },
  {
    "L3MON4D3/LuaSnip",
```
new_string (deletes the whole `nvim-dap` entry, keeps `LuaSnip` — Task 3 will touch `LuaSnip` next):
```lua
  {
    "L3MON4D3/LuaSnip",
```

This removes, along with it, the dap-python 8-config block and dap-go 3-config block that lived in its `dependencies` table — **do not worry, they come back**: the dap-go 3-config block is relocated in Task 6 (go), and the dap-python 8-config block is relocated in Task 7 (python), each landing in its proper `languages/*.lua` file as an `optional = true` fragment. Between now and those tasks landing, Go/Python DAP launch configs are temporarily gone; core breakpoint/step/continue debugging (any language with an adapter, e.g. Lua via `nlua`, or manually-configured adapters) still works.

- [ ] **Step 4: Delete `languages/javascript.lua` entirely**

This file's only content is a hand-rolled `nvim-dap` adapters/configurations block for JS/TS/Vue that is now fully superseded by the `dap.core` + `lang.typescript` extra combo (the typescript extra already ships an equivalent, `optional = true` DAP fragment covering `pwa-node`/`pwa-chrome`/`pwa-msedge`, and it's already active since `lang.vue` imports `lang.typescript` internally).

Run:
```bash
rm /Users/leo/.config/nvim/lua/plugins/languages/javascript.lua
```

- [ ] **Step 5: Remove the now-dangling import in `lang.lua`**

Modify `lua/plugins/lang.lua`, old_string:
```lua
return {
  { import = "plugins.languages.markdown" },
  { import = "plugins.languages.python" },
  { import = "plugins.languages.java" },
  { import = "plugins.languages.rust" },
  { import = "plugins.languages.javascript" },
}
```
new_string:
```lua
return {
  { import = "plugins.languages.markdown" },
  { import = "plugins.languages.python" },
  { import = "plugins.languages.java" },
  { import = "plugins.languages.rust" },
}
```

- [ ] **Step 6: Re-home the 5 mason tools that were only `ensure_installed` via the deleted block**

The deleted `coding.lua` block's `dependencies` had a `mason.nvim` fragment installing `java-debug-adapter`, `java-test`, `delve`, `debugpy`, `jdtls`. `java-debug-adapter`/`java-test`/`jdtls` are still needed (Java is out of scope for this migration but still actively used — `languages/java.lua` expects them on disk). `delve` and `debugpy` are needed by Tasks 6/7. Fold all 5 into `lsp.lua`'s existing mason list (it already uses `opts_extend = {"ensure_installed"}`, so this merges safely with every other fragment).

Modify `lua/plugins/lsp.lua`, old_string:
```lua
        -- Go
        "golangci-lint",
        "goimports",
        "gofumpt",
        "gomodifytags",
        "delve",
        "impl",
```
new_string:
```lua
        -- Go
        "golangci-lint",
        "goimports",
        "gofumpt",
        "gomodifytags",
        "delve",
        "impl",

        -- Debug adapters (previously only reachable via coding.lua's deleted nvim-dap block)
        "debugpy",
        "java-debug-adapter",
        "java-test",
        "jdtls",
```

- [ ] **Step 7: Verify the fix — sign icon and JSON5 patch now correct**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-dap'}})" "+lua local s=vim.fn.sign_getdefined('DapBreakpoint')[1]; print('SIGN='..(s and s.text or 'nil'))" "+lua local v=require('dap.ext.vscode'); print('JSON5_PATCHED='..tostring(v.json_decode ~= vim.json.decode))" "+lua print('HL='..vim.inspect(vim.api.nvim_get_hl(0,{name='DapStoppedLine'})))" "+qall" 2>&1 | tail -4
```
Expected: `SIGN=` shows a LazyVim icon glyph (not plain `B `), `JSON5_PATCHED=true`, `DapStoppedLine` highlight link is present (non-empty table).

- [ ] **Step 8: Verify generic DAP keymaps still exist and Mason list has no duplicates causing errors**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-dap'}})" "+lua local k=vim.fn.maparg('<leader>db','n',false,true); print('BREAKPOINT_KEY='..(k.desc or 'MISSING'))" "+lua local k2=vim.fn.maparg('<leader>da','n',false,true); print('RUN_WITH_ARGS_KEY='..(k2.desc or 'MISSING'))" "+qall" 2>&1 | tail -3
```
Expected: `BREAKPOINT_KEY=Toggle Breakpoint`, `RUN_WITH_ARGS_KEY=Run with Args` (this second one is new — a free addition from the extra, confirms the extra's keys won).

- [ ] **Step 9: Checkpoint**

No git commit (no repo). Re-run the Task 0 backup command with a new suffix if you want a mid-migration restore point:
```bash
cd /Users/leo/.config/nvim && tar czf /tmp/nvim-config-backup-2026-07-19-after-task1.tar.gz lua/
```

---

### Task 2: Migrate `test.core` (foundation — neotest base + keybinding restore)

**Files:**
- Modify: `lua/config/lazy.lua` (add import)
- Modify: `lua/plugins/coding.lua:489-745` region (after Task 1's edits, the neotest block; delete and replace with a keys-only override)
- Modify: `lua/plugins/tools.lua:494-501` (overseer's neotest consumer fragment — verify it still applies, no change expected but confirm)

**Interfaces:**
- Consumes: nothing from Task 1 directly, but must land before Tasks 6/7/8 (go/python/rust) for the same "optional fragment needs a non-optional anchor" reason as Task 1.
- Produces: a single non-optional `nvim-neotest/neotest` anchor, plus a `keys` override restoring the `<leader>T*` prefix.

**Acceptance criterion:** Neotest is fully functional and every previously-documented `<leader>T*` keybinding (`Tt`, `TT`, `Tr`, `Tl`, `Ts`, `To`, `TO`, `TS`, `Tw`, `Td`) resolves to the same underlying `neotest` call it did before migration — verified by inspecting `maparg()` for each, not by running an actual test suite (no test project is open during this migration).

- [ ] **Step 1: Write the "test" — a headless assertion of current (pre-migration) keymap set**

Run this and save the output for comparison after Step 4:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'neotest'}})" "+lua for _,k in ipairs({'Tt','TT','Tr','Tl','Ts','To','TO','TS','Tw','Td'}) do local m=vim.fn.maparg('<leader>'..k,'n',false,true); print(k..'='..(m.desc or 'MISSING')) end" "+qall" 2>&1 | tail -10
```
Expected baseline (current behavior, before this task's edit):
```
Tt=Run File (Neotest)
TT=Run All Test Files (Neotest)
Tr=Run Nearest (Neotest)
Tl=Run Last (Neotest)
Ts=Toggle Summary (Neotest)
To=Show Output (Neotest)
TO=Toggle Output Panel (Neotest)
TS=Stop (Neotest)
Tw=Toggle Watch (Neotest)
Td=Debug Nearest (Neotest)
```

- [ ] **Step 2: Add the `test.core` extra import**

Modify `lua/config/lazy.lua`, old_string:
```lua
    { import = "lazyvim.plugins.extras.dap.core" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```
new_string:
```lua
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.test.core" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```

- [ ] **Step 3: Replace the hand-rolled `neotest` block in `coding.lua` with a `keys`-only override**

The block to delete starts at the `nvim-neotest/neotest` entry (immediately after `LuaSnip`'s closing, which Task 3 will further edit — do this step first, order between Task 2/3 within `coding.lua` doesn't matter since they touch disjoint regions) and runs through its closing `},` before `gbprod/yanky.nvim`. Modify `lua/plugins/coding.lua`, old_string is the entire block from:
```lua
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
```
through (inclusive):
```lua
      {
        "<leader>Td",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug Nearest (Neotest)",
      },
    },
  },
  {
    "gbprod/yanky.nvim",
```
new_string (deletes the whole hand-rolled `opts`/`config`/adapters block, keeps only a `keys` remap restoring the `<leader>T*` prefix — the extra's own `opts`/`config`/`consumers.trouble` logic, which is functionally identical to what was here, takes over):
```lua
  {
    "nvim-neotest/neotest",
    -- stylua: ignore
    keys = {
      -- unbind all 11 of the extra's own lowercase <leader>t* defaults (collide with terminal
      -- keys in keymaps.lua). lazy.nvim's `keys` merge dedups by EXACT lhs string, not by
      -- prefix, so the group marker alone does not shadow its children — each lhs needs its
      -- own `false` entry.
      { "<leader>t",  false },
      { "<leader>ta", false },
      { "<leader>tt", false },
      { "<leader>tT", false },
      { "<leader>tr", false },
      { "<leader>tl", false },
      { "<leader>ts", false },
      { "<leader>to", false },
      { "<leader>tO", false },
      { "<leader>tS", false },
      { "<leader>tw", false },
      { "<leader>T",  "", desc = "+test" },
      { "<leader>Ta", function() require("neotest").run.attach() end, desc = "Attach to Test (Neotest)" },
      { "<leader>Tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File (Neotest)" },
      { "<leader>TT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Test Files (Neotest)" },
      { "<leader>Tr", function() require("neotest").run.run() end, desc = "Run Nearest (Neotest)" },
      { "<leader>Tl", function() require("neotest").run.run_last() end, desc = "Run Last (Neotest)" },
      { "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary (Neotest)" },
      { "<leader>To", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output (Neotest)" },
      { "<leader>TO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel (Neotest)" },
      { "<leader>TS", function() require("neotest").run.stop() end, desc = "Stop (Neotest)" },
      { "<leader>Tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle Watch (Neotest)" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    -- stylua: ignore
    keys = {
      { "<leader>td", false }, -- unbind extra's default (collides with terminal keys)
      { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest (Neotest)" },
    },
  },
  {
    "gbprod/yanky.nvim",
```

Note (corrected — this superseded an earlier, incomplete version of this step that only unbound `<leader>t` and `<leader>td`, verified BLOCKED by an implementer subagent run and fixed here): lazy.nvim's `keys` merge dedups **by exact lhs string** (`lazy/core/plugin.lua`, keyed on the literal mapping, last occurrence for a given lhs wins), not by prefix. The `test.core` extra defines 11 distinct lowercase `<leader>t*` lhs strings (`t`, `ta`, `tt`, `tT`, `tr`, `tl`, `ts`, `to`, `tO`, `tS`, `tw`) plus `<leader>td` from its `nvim-dap` fragment — 12 total. Every one of them needs its own `{ lhs, false }` entry; unbinding only the bare `<leader>t` group marker leaves the other 10 live and colliding with the terminal keymaps in `keymaps.lua` (concretely `<leader>tt` "New Tab Terminal" and `<leader>ta` "Toggle Right" both currently lose to neotest). Confirm all 12 are neutralized in Step 5.

- [ ] **Step 4: Verify the restored keymap set matches the Step 1 baseline exactly**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'neotest'}})" "+lua for _,k in ipairs({'Tt','TT','Tr','Tl','Ts','To','TO','TS','Tw','Td'}) do local m=vim.fn.maparg('<leader>'..k,'n',false,true); print(k..'='..(m.desc or 'MISSING')) end" "+qall" 2>&1 | tail -10
```
Expected: identical output to Step 1's baseline.

- [ ] **Step 5: Verify all 12 of the extra's default `<leader>t*`/`<leader>td` lhs strings are unbound (no collision with terminal keys)**

First, under the narrow neotest-only load scope (`keymaps.lua` is NOT loaded in this scope, so an unbound key reports `UNBOUND`, not a terminal desc — that's expected and correct here):

```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'neotest'}})" "+lua for _,k in ipairs({'t','ta','tt','tT','tr','tl','ts','to','tO','tS','tw'}) do local m=vim.fn.maparg('<leader>'..k,'n',false,true); print(k..'='..(m.desc or 'UNBOUND')) end" "+qall" 2>&1 | tail -11
```
Expected: all 11 report `UNBOUND`.

Then, under a full realistic startup (lets `keymaps.lua`'s own `VeryLazy`-time terminal keymaps actually fire, confirming they — not neotest — own these lhs strings end-to-end). **Known environment gap (found during Task 2 execution, keep for any later task that needs a post-`VeryLazy` check):** a bare `nvim --headless` + `vim.defer_fn` never reaches `UIEnter`, so lazy.nvim's `VeryLazy` autocmd (gated behind `UIEnter` per `lazy/core/util.lua`'s `very_lazy()`) never fires, so `keymaps.lua` never sources and every key — not just the ones this task touches — reads back `UNBOUND` regardless of correctness. Force `UIEnter` manually first:

```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua vim.defer_fn(function() vim.api.nvim_exec_autocmds('UIEnter', {}); vim.defer_fn(function() local m=vim.fn.maparg('<leader>tt','n',false,true); io.stderr:write('TT_AFTER_STARTUP='..(m.desc or 'UNBOUND')..'\n'); local m2=vim.fn.maparg('<leader>ta','n',false,true); io.stderr:write('TA_AFTER_STARTUP='..(m2.desc or 'UNBOUND')..'\n'); vim.cmd('qall!') end, 300) end, 300)" 2>&1
```
Expected: `TT_AFTER_STARTUP=New Tab Terminal`, `TA_AFTER_STARTUP=Toggle Right` (the real terminal mappings from `lua/config/keymaps.lua`, confirming no residual collision under normal use — not just in the narrow verification scope). If either check still shows a neotest desc, the `false`-unbind list in Step 3 is still incomplete or misplaced; re-check every lhs against the extra's actual `keys` table.

- [ ] **Step 6: Verify trouble.nvim integration (test-failure auto-open) still wires up**

**Known environment gap (found during Task 2 execution):** `require('lazy').load({plugins={...}})` only puts a plugin on `rtp` — it does not call the plugin's `config`/`setup()`, so `neotest.setup()` never runs and no consumer is ever registered this way, correct or not. Also, `neotest`'s consumers are module-local (exposed only via a dynamic `__index` metatable, e.g. `n.trouble`), not a public `_consumers` field — so `n._consumers` is always empty regardless of wiring. Use a real load plus the dynamic-access pattern:

```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy.core.loader').load({'neotest','trouble.nvim'}, {})" "+lua local n = require('neotest'); local names = {'run','summary','output','output_panel','status','diagnostic','jump','state','watch','overseer','trouble'}; local found = {}; for _,name in ipairs(names) do local ok, v = pcall(function() return n[name] end); if ok and v ~= nil then table.insert(found, name) end end; print('REGISTERED_CONSUMERS='..vim.inspect(found))" "+qall" 2>&1 | tail -3
```
Expected: consumer list includes `trouble` (confirms the extra's `test.core` trouble-integration logic, equivalent to the old hand-rolled one, is active).

- [ ] **Step 7: Checkpoint** — same backup pattern as Task 1 Step 9, suffix `after-task2`.

---

### Task 3: Migrate `coding.luasnip`

**Files:**
- Modify: `lua/config/lazy.lua` (add import)
- Modify: `lua/plugins/coding.lua` (delete the `LuaSnip` block that Task 1 left in place)
- Modify: `lua/plugins/formatting.lua` — no change (unrelated)

**Refactor: behavior unchanged**, plus one free addition (project-local snippet loading from `~/.config/nvim/snippets`, which the hand-copied version was missing).

- [ ] **Step 1: Add the `coding.luasnip` extra import**

Modify `lua/config/lazy.lua`, old_string:
```lua
    { import = "lazyvim.plugins.extras.test.core" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```
new_string:
```lua
    { import = "lazyvim.plugins.extras.test.core" },
    { import = "lazyvim.plugins.extras.coding.luasnip" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```

- [ ] **Step 2: Delete the hand-rolled `LuaSnip` block from `coding.lua`**

After Task 1's edit, `coding.lua` now has `LuaSnip` immediately following `neotab.nvim`, and (after Task 2's edit) immediately followed by the `nvim-neotest/neotest` block. Modify `lua/plugins/coding.lua`, old_string:
```lua
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    build = LazyVim.is_win() and nil
      or "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp",
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    opts = function()
      LazyVim.cmp.actions.snippet_forward = function()
        if require("luasnip").jumpable(1) then
          vim.schedule(function()
            require("luasnip").jump(1)
          end)
          return true
        end
      end
      LazyVim.cmp.actions.snippet_stop = function()
        if require("luasnip").expand_or_jumpable() then
          require("luasnip").unlink_current()
          return true
        end
      end
      return {
        history = true,
        delete_check_events = "TextChanged",
      }
    end,
  },
  {
    "nvim-neotest/neotest",
```
new_string:
```lua
  {
    "nvim-neotest/neotest",
```

- [ ] **Step 3: Verify LuaSnip config resolves and Tab-forward still works**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'LuaSnip','blink.cmp'}})" "+lua local ls=require('luasnip'); print('HISTORY='..tostring(ls.config.get_config().history))" "+lua print('SNIPPET_FORWARD='..tostring(LazyVim.cmp.actions.snippet_forward ~= nil))" "+qall" 2>&1 | tail -3
```
Expected: `HISTORY=true`, `SNIPPET_FORWARD=true`.

- [ ] **Step 4: Checkpoint** — backup suffix `after-task3`.

---

### Task 4: Migrate `linting.eslint`

**Files:**
- Modify: `lua/config/lazy.lua` (add import)
- Modify: `lua/plugins/lsp.lua:122-135` (delete `eslint` server block)

**Acceptance criterion:** ESLint's LSP-based formatter actually registers with LazyVim's format dispatcher and fixes autofixable issues on save — this did not work before (the old block set `format = true` in `settings` but never called `LazyVim.format.register`, so the setting was inert).

- [ ] **Step 1: Write the "test" — confirm eslint is currently NOT a registered LazyVim formatter**

Requires a scratch JS file with an autofixable issue (e.g. missing semicolon, if the local eslint config enables that rule) in a directory with an eslint config. If no such fixture is handy, use this weaker but still valid structural check instead:

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-lspconfig'}})" "+lua local ok, fmt = pcall(function() return LazyVim.format.formatters() end); local names={}; if ok then for _,f in ipairs(fmt) do table.insert(names, f.name) end end; print('FORMATTERS='..table.concat(names, ','))" "+qall" 2>&1 | tail -2
```
Expected (before this task): `eslint: lsp` is **absent** from the list.

- [ ] **Step 2: Add the `linting.eslint` extra import**

Modify `lua/config/lazy.lua`, old_string:
```lua
    { import = "lazyvim.plugins.extras.coding.luasnip" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```
new_string:
```lua
    { import = "lazyvim.plugins.extras.coding.luasnip" },
    { import = "lazyvim.plugins.extras.linting.eslint" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```

- [ ] **Step 3: Delete the hand-rolled `eslint` server block from `lsp.lua`**

Modify `lua/plugins/lsp.lua`, old_string:
```lua
        -- ============ JavaScript/TypeScript ============
        eslint = {
          settings = {
            validate = "on",
            packageManager = "npm",
            format = true,
            nodePath = "",
            rules = {},
            workingDirectory = { mode = "location" },
            experimental = {
              useFlatConfig = true,
            },
          },
        },

        ts_ls = {
          settings = {
            typescript = {
              format = {
                enable = false,
              },
            },
          },
        },
```
new_string:
```lua
        -- ============ JavaScript/TypeScript ============
        -- eslint: handled by extras.linting.eslint (registers LazyVim formatter, unlike the old inert `format=true`)
        -- ts_ls: dead code removed — lang.vue → lang.typescript extra forces vtsls, ts_ls.enabled=false always
```

(This also removes the `ts_ls` block, which was confirmed dead: `lang.vue` imports `lang.typescript`, whose `init.lua` unconditionally sets `opts.servers.ts_ls.enabled = false` because `vim.g.lazyvim_ts_lsp` defaults to `"vtsls"`.)

- [ ] **Step 4: Verify eslint is now a registered formatter**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-lspconfig'}})" "+lua local ok, fmt = pcall(function() return LazyVim.format.formatters() end); local names={}; if ok then for _,f in ipairs(fmt) do table.insert(names, f.name) end end; print('FORMATTERS='..table.concat(names, ','))" "+qall" 2>&1 | tail -2
```
Expected: `eslint: lsp` now appears in the list.

- [ ] **Step 5: Verify `ts_ls` is not configured as an active server (confirm it really was dead before too)**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-lspconfig'}})" "+lua local ok,cfg=pcall(vim.lsp.config.ts_ls); print('TS_LS_ENABLED='..tostring(ok and cfg and cfg.enabled))" "+qall" 2>&1 | tail -2
```
Expected: `TS_LS_ENABLED=false`.

- [ ] **Step 6: Checkpoint** — backup suffix `after-task4`.

---

### Task 5: Migrate `lang.clangd`

**Files:**
- Modify: `lua/config/lazy.lua` (add import)
- Modify: `lua/plugins/lsp.lua:147-159` (replace `clangd` block with a minimal override carrying only the real customization)

**Acceptance criterion:** `clangd` keeps the one deliberate deviation from the extra's defaults (`--header-insertion=never` instead of the extra's `--header-insertion=iwyu`), and gains the extra's C/C++ additions for free: `clangd_extensions.nvim`, `<leader>ch` source/header switch, utf-16 offset encoding, C/C++ DAP via codelldb.

- [ ] **Step 1: Add the `lang.clangd` extra import**

Modify `lua/config/lazy.lua`, old_string:
```lua
    { import = "lazyvim.plugins.extras.linting.eslint" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```
new_string:
```lua
    { import = "lazyvim.plugins.extras.linting.eslint" },
    { import = "lazyvim.plugins.extras.lang.clangd" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```

- [ ] **Step 2: Replace the hand-rolled `clangd` block in `lsp.lua` with a minimal cmd override**

The extra's own `cmd` is `{"clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu", "--completion-style=detailed", "--function-arg-placeholders", "--fallback-style=llvm"}`. `cmd` is a list value — table-merge on a plain array means our later fragment's `cmd`, if set, fully replaces the extra's (arrays don't append-merge meaningfully here since we want ALL our own flags, not a splice). Modify `lua/plugins/lsp.lua`, old_string:
```lua
        -- ============ C/C++ ============
        clangd = {
          keys = {
            { "<leader>cR", "<cmd>ClangdReset<cr>", desc = "Clangd Reset" },
          },
          cmd = {
            "clangd",
            "--header-insertion=never",
            "--completion-style=detailed",
            "--background-index",
            "--clang-tidy",
          },
        },
```
new_string:
```lua
        -- ============ C/C++ ============
        -- clangd: base config from extras.lang.clangd; only --header-insertion differs from its default (iwyu)
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
        },
```

(The dead `<leader>cR ClangdReset` key is dropped — `:ClangdReset` is not a real command in this setup, confirmed nothing defines it; it was a no-op keybinding.)

- [ ] **Step 3: Verify the merged `cmd` has our header-insertion flag and the extra's other flags**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-lspconfig'}})" "+lua local cfg=vim.lsp.config.clangd; print('CMD='..table.concat(cfg.cmd or {}, ' '))" "+qall" 2>&1 | tail -2
```
Expected: contains `--header-insertion=never` (not `iwyu`) and also `--clang-tidy`, `--background-index`.

- [ ] **Step 4: Verify `clangd_extensions.nvim` loaded (free addition from the extra)**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua local ok = pcall(require, 'clangd_extensions'); print('CLANGD_EXTENSIONS_AVAILABLE='..tostring(ok))" "+qall" 2>&1 | tail -2
```
Expected: `CLANGD_EXTENSIONS_AVAILABLE=true` (module resolvable, even if not yet loaded — confirms the plugin is in the merged spec / installed by lazy.nvim on next sync).

Note: this plugin is new — run `:Lazy sync` (or `:Lazy install`) once interactively before this check will show `true`, since Task 5 only edits specs, it doesn't install the new plugin automatically outside of Neovim's normal startup lazy-sync flow.

- [ ] **Step 5: Checkpoint** — backup suffix `after-task5`.

---

### Task 6: Migrate `lang.go`

**Files:**
- Modify: `lua/config/lazy.lua` (add import)
- Modify: `lua/plugins/lsp.lua:193-229` (delete `gopls` block)
- Modify: `lua/plugins/formatting.lua:17,64-73` (drop `goimports-reviser`, confirm-first)
- Modify: `lua/plugins/languages/rust.lua` — no change (unrelated, listed for clarity only)
- Create: (nothing new — dap-go and neotest-go/-golang config move into a new fragment inside `lua/plugins/languages/go.lua`, a file that doesn't exist yet)
- Modify: `lua/plugins/lang.lua` (add `plugins.languages.go` import)

**Interfaces:**
- Consumes: `dap.core` anchor (Task 1), `test.core` anchor (Task 2).
- Produces: `neotest-golang` adapter (replaces archived `neotest-go`), `dap-go` config relocated.

**Acceptance criterion:** `golangci-lint` diagnostics still resolve project `.golangci.yml` with the existing nvim-config fallback (untouched — `linting.lua` ignores merged `opts`, see Global Constraints, so this is a no-op verification, not a real merge); Go test running via `<leader>Tr`/`<leader>Tt` uses `neotest-golang` (not the archived `neotest-go`) with the same flags as before.

- [ ] **Step 1: Confirm `goimports-reviser` is currently non-functional (justifies deleting it, not just relocating)**

Run:
```bash
which goimports-reviser || echo "NOT ON PATH"
grep -c "goimports-reviser" /Users/leo/.config/nvim/lua/plugins/lsp.lua
```
Expected: `NOT ON PATH` (or, if it happens to be on PATH from some other install, the second command's `0` confirms it was never added to this config's own `mason ensure_installed` list either way — check both before deleting). If it turns out to be genuinely installed and used, STOP and tell the user rather than silently dropping a working formatter — do not proceed to Step 5 in that case.

- [ ] **Step 2: Add the `lang.go` extra import**

Modify `lua/config/lazy.lua`, old_string:
```lua
    { import = "lazyvim.plugins.extras.lang.clangd" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```
new_string:
```lua
    { import = "lazyvim.plugins.extras.lang.clangd" },
    { import = "lazyvim.plugins.extras.lang.go" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```

- [ ] **Step 3: Delete the hand-rolled `gopls` block from `lsp.lua`**

The extra's `gopls` settings are field-for-field identical to this block, plus it adds the documented `semanticTokensProvider` workaround (`init_options.semanticTokens=true` + a `Snacks.util.lsp.on` patch) which the hand-copied version was missing (it set a non-standard `semanticTokens=true` directly under `settings.gopls`, which is not a real gopls setting key and was a no-op). Modify `lua/plugins/lsp.lua`, old_string:
```lua
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },

```
new_string:
```lua
        -- gopls: config now comes entirely from extras.lang.go (identical settings + the
        -- semanticTokensProvider workaround the hand-copied version was missing)

```

- [ ] **Step 4: Create `lua/plugins/languages/go.lua` with the relocated dap-go and neotest adapter customization**

```lua
return {
  -- dap-go: preserve the project's custom launch configurations
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "leoluz/nvim-dap-go",
        opts = {
          dap_configurations = {
            { type = "go", name = "Debug", request = "launch", program = "${file}" },
            { type = "go", name = "Debug Package", request = "launch", program = "${workspaceFolder}" },
            { type = "go", name = "Attach Remote", mode = "remote", request = "attach" },
          },
          delve = {
            path = "dlv",
            initialize_timeout_sec = 20,
            port = "${port}",
            args = {},
            build_flags = "",
            detached = vim.fn.has("win32") == 0,
            cwd = nil,
          },
          tests = { verbose = false },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>dGt", function() require("dap-go").debug_test() end, desc = "Debug Go Test", ft = "go" },
      { "<leader>dGl", function() require("dap-go").debug_last_test() end, desc = "Debug Last Go Test", ft = "go" },
      { "<leader>dGs", function() require("dap-go").debug_subtest() end, desc = "Debug Go Subtest", ft = "go" },
    },
  },

  -- neotest-golang: replaces archived neotest-go, same flags as before
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "fredrikaverpil/neotest-golang" },
    opts = {
      adapters = {
        ["neotest-golang"] = {
          go_test_args = { "-count=1", "-timeout=60s", "-race", "-cover" },
          dap_go_enabled = true,
        },
      },
    },
  },
}
```

- [ ] **Step 5: Remove `goimports-reviser` from `formatting.lua` (only if Step 1 confirmed it's unused)**

Modify `lua/plugins/formatting.lua`, old_string:
```lua
      -- Go 语言（保持顺序，先导入整理后格式化）
      go = { "goimports", "gofumpt", "goimports-reviser" },
```
new_string:
```lua
      -- Go 语言（保持顺序，先导入整理后格式化）
      go = { "goimports", "gofumpt" },
```

Modify `lua/plugins/formatting.lua`, old_string:
```lua
    -- 添加一些格式化工具的特定配置
    formatters = {
      ["goimports-reviser"] = {
        command = "goimports-reviser",
        args = {
          "-rm-unused",
          "-set-alias",
          "-format",
          "$FILENAME",
        },
        stdin = false,
      },
      shfmt = {
```
new_string:
```lua
    -- 添加一些格式化工具的特定配置
    formatters = {
      shfmt = {
```

- [ ] **Step 6: Register the new `languages/go.lua` module**

Modify `lua/plugins/lang.lua`, old_string:
```lua
return {
  { import = "plugins.languages.markdown" },
  { import = "plugins.languages.python" },
  { import = "plugins.languages.java" },
  { import = "plugins.languages.rust" },
}
```
new_string:
```lua
return {
  { import = "plugins.languages.markdown" },
  { import = "plugins.languages.python" },
  { import = "plugins.languages.java" },
  { import = "plugins.languages.rust" },
  { import = "plugins.languages.go" },
}
```

- [ ] **Step 7: Verify gopls settings resolved correctly**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-lspconfig'}})" "+lua local cfg=vim.lsp.config.gopls; print('GOFUMPT='..tostring(cfg.settings.gopls.gofumpt)); print('STATICCHECK='..tostring(cfg.settings.gopls.staticcheck)); print('INIT_SEMTOK='..tostring(cfg.init_options and cfg.init_options.semanticTokens))" "+qall" 2>&1 | tail -3
```
Expected: `GOFUMPT=true`, `STATICCHECK=true`, `INIT_SEMTOK=true` (the last one is the fix — was previously not set anywhere valid).

- [ ] **Step 8: Verify neotest-golang adapter present with correct flags, neotest-go gone**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'neotest'}})" "+lua local ok, na = pcall(require, 'neotest-golang'); print('NEOTEST_GOLANG_LOADABLE='..tostring(ok))" "+lua local ok2 = pcall(require, 'neotest-go'); print('NEOTEST_GO_STILL_PRESENT='..tostring(ok2))" "+qall" 2>&1 | tail -3
```
Expected: `NEOTEST_GOLANG_LOADABLE=true`, `NEOTEST_GO_STILL_PRESENT=false` (module gone — confirms the dependency swap, not just an additive install).

- [ ] **Step 9: Verify formatter list for Go has exactly 2 entries**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+e /tmp/x.go" "+lua vim.defer_fn(function() local c=require('conform'); local fmts=c.list_formatters_for_buffer(0); local names={}; for _,f in ipairs(fmts) do table.insert(names, f) end; print('GO_FORMATTERS='..table.concat(names,',')); vim.cmd('qall') end, 300)" 2>&1 | tail -2
```
Expected: `GO_FORMATTERS=goimports,gofumpt` (no `goimports-reviser`).

- [ ] **Step 10: Checkpoint** — backup suffix `after-task6`.

---

### Task 7: Migrate `lang.python` (also folds in the Ruff config-discovery fix — audit item #4, kept here deliberately rather than in the separate `2026-07-19-non-extras-fixes.md` plan, since both touch the same `lsp.lua` ruff block and duplicating the edit risks the same class of defect Task 2 hit)

**Files:**
- Modify: `lua/config/lazy.lua` (add import)
- Modify: `lua/plugins/lsp.lua:264-292` (simplify `ruff` block, drop redundant `on_attach`)
- Modify: `lua/plugins/languages/python.lua` (add dap-python + neotest-python fragments; venv-selector block untouched)
- Modify: `lua/config/options.lua:9-10` (remove the dead `RUFF_CONFIG` env var)
- Modify: `lua/plugins/formatting.lua` (replace the custom `ruff_format`/`ruff_imports` formatter definitions with conform's own built-in `ruff_format`/`ruff_organize_imports`)
- Move: `~/.config/nvim/ruff.toml` → `~/.config/ruff/ruff.toml` (ruff's real user-level config discovery path — empirically verified, see Step 3)

**Interfaces:**
- Consumes: `dap.core` anchor (Task 1), `test.core` anchor (Task 2).
- Produces: dap-python relocated with all 8 original launch configs intact.

**Acceptance criterion:** All 8 custom `dap.configurations.python` entries (Launch file / Launch file with arguments / Launch current module / Attach remote / Attach local / Debug Django / Debug Flask / Pytest) survive the move verbatim; `pyright` config (venv detection, diagnostic severity overrides) untouched; ruff hover-disable still active (now via the extra's more robust `Snacks.util.lsp.on` pattern instead of `on_attach`); **Ruff config discovery is fixed**: a project with its own `pyproject.toml`/`ruff.toml` is respected (previously the formatter's hardcoded `--config=~/.config/nvim/ruff.toml` silently overrode it), and a project with no config of its own still gets the user's custom rules, now via ruff's real user-config path instead of the dead `RUFF_CONFIG` env var (ruff has no such env var — confirmed via `ruff check --help`/`ruff format --help`, neither lists it).

- [ ] **Step 1: Add the `lang.python` extra import**

Modify `lua/config/lazy.lua`, old_string:
```lua
    { import = "lazyvim.plugins.extras.lang.go" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```
new_string:
```lua
    { import = "lazyvim.plugins.extras.lang.go" },
    { import = "lazyvim.plugins.extras.lang.python" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```

- [ ] **Step 2: Simplify the `ruff` block in `lsp.lua`, drop the now-redundant `on_attach`**

The extra's `setup.ruff` hook uses `Snacks.util.lsp.on` to disable hover, which survives LSP restarts more reliably than a plain `on_attach` — keep the project's genuine customizations (`settings.organizeImports/fixAll/logLevel/codeAction`), drop the now-duplicate hover-disable `on_attach`. Modify `lua/plugins/lsp.lua`, old_string:
```lua
        -- Ruff 配置（代码质量、格式化 + 未使用函数检测）
        ruff = {
          -- 禁用一些功能，避免与 pyright 冲突
          on_attach = function(client, bufnr)
            -- 禁用 hover，避免与 pyright 冲突
            if client.server_capabilities then
              client.server_capabilities.hoverProvider = false
            end
          end,
          -- 使用 ~/.config/nvim/ruff.toml 中的自定义规则
          -- Ruff 通过规则检测未使用函数（如 PLR0913, F841 等）
          settings = {
```
new_string:
```lua
        -- Ruff 配置（代码质量、格式化 + 未使用函数检测）
        -- hover 禁用已由 extras.lang.python 的 Snacks.util.lsp.on 钩子接管（比 on_attach 更抗重启）
        ruff = {
          -- 使用 ~/.config/nvim/ruff.toml 中的自定义规则
          -- Ruff 通过规则检测未使用函数（如 PLR0913, F841 等）
          settings = {
```

- [ ] **Step 3: Fix Ruff config discovery (relocate the global config, drop the dead env var and the hardcoded `--config` override)**

Three independent problems, verified empirically immediately before writing this task (not from memory): (a) `options.lua:10`'s `vim.env.RUFF_CONFIG = ...` is a no-op — ruff has no such environment variable (`ruff check --help` / `ruff format --help` list no `RUFF_CONFIG`); (b) `formatting.lua`'s custom `ruff_format` formatter hardcodes `--config=~/.config/nvim/ruff.toml`, which silently overrides any project's own `pyproject.toml`/`ruff.toml` when one exists; (c) ruff DOES support a real user-level fallback config at `~/.config/ruff/ruff.toml` — confirmed by an empirical test in this session: with `HOME` pointed at a scratch directory containing only `~/.config/ruff/ruff.toml` (ignoring rule `F401`), `ruff check` on a file with an unused import produced zero findings; adding a project-level `ruff.toml` back (selecting `F401`) in the same directory caused ruff to flag it again — i.e. project config wins, user config is a fallback only, exactly the desired semantics.

Step 3a — move the config file to ruff's real discovery path:
```bash
mkdir -p ~/.config/ruff && mv ~/.config/nvim/ruff.toml ~/.config/ruff/ruff.toml
```

Step 3b — remove the dead env var. **Cross-plan note:** `docs/plans/2026-07-19-non-extras-fixes.md` Task H independently removes the neighboring `vim.g.build_cmd = "make"` line from this same file — if Task H has already landed by the time this step runs, `options.lua` will no longer contain that line; the old_string below already assumes Task H ran first (matches this plan's actual execution order in this session). If Task H has NOT run yet when this step executes, re-add `vim.g.build_cmd = "make"` as a trailing line in the old_string/new_string below before applying, or just re-read the current file and adjust — don't force a non-matching Edit.

Modify `lua/config/options.lua`, old_string:
```lua
vim.opt.spell = false
-- 设置 Ruff 全局配置文件路径
vim.env.RUFF_CONFIG = vim.fn.stdpath("config") .. "/ruff.toml"
```
new_string:
```lua
vim.opt.spell = false
```

Step 3c — replace the custom `ruff_format`/`ruff_imports` conform formatters with conform's own built-in `ruff_format`/`ruff_organize_imports` (both confirmed via direct source read of `conform.nvim/lua/conform/formatters/ruff_format.lua` and `ruff_organize_imports.lua`: neither hardcodes `--config`, both set `cwd` to the discovered project root via `pyproject.toml`/`ruff.toml`/`.ruff.toml`, letting ruff's own normal discovery — project first, then the new `~/.config/ruff/ruff.toml` fallback — do the rest). Modify `lua/plugins/formatting.lua`, old_string:
```lua
      -- Python - 优化逻辑，保持您的条件判断
      python = function(bufnr)
        if require("conform").get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_imports", "ruff_format" }
        else
          return { "isort", "black" }
        end
      end,
```
new_string:
```lua
      -- Python - 优化逻辑，保持您的条件判断
      python = function(bufnr)
        if require("conform").get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_organize_imports", "ruff_format" }
        else
          return { "isort", "black" }
        end
      end,
```

Modify `lua/plugins/formatting.lua`, old_string:
```lua
      ruff_imports = {
        command = "ruff",
        args = {
          "check",
          "--select=I",
          "--fix",
          "--stdin-filename",
          "$FILENAME",
          "-",
        },
        stdin = true,
      },
      ruff_format = {
        command = "ruff",
        args = { "format", "--config=" .. vim.fn.expand("~/.config/nvim/ruff.toml"), "--stdin-filename", "$FILENAME", "-" },
        stdin = true,
      },
      yamlfmt = {
```
new_string:
```lua
      yamlfmt = {
```

(Deletes both custom formatters entirely — conform resolves `ruff_format`/`ruff_organize_imports` from its own built-in definitions now, confirmed present at `conform.nvim/lua/conform/formatters/ruff_format.lua` and `ruff_organize_imports.lua`, no further registration needed here.)

- [ ] **Step 4: Add dap-python and neotest-python fragments to `languages/python.lua`**

Modify `lua/plugins/languages/python.lua`, old_string (append after the existing `venv-selector.nvim` block, before the file's closing):
```lua
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
```
new_string:
```lua
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

  -- dap-python: relocated from coding.lua, all 8 original launch configs preserved verbatim
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        keys = {
          {
            "<leader>dPt",
            function() require("dap-python").test_method() end,
            desc = "Debug Python Method",
            ft = "python",
          },
          {
            "<leader>dPc",
            function() require("dap-python").test_class() end,
            desc = "Debug Python Class",
            ft = "python",
          },
          {
            "<leader>dPs",
            function() require("dap-python").debug_selection() end,
            desc = "Debug Python Selection",
            ft = "python",
          },
        },
        config = function()
          local mason_debugpy = vim.fn.expand("$HOME") .. "/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
          local debugpy_cmd = vim.fn.executable("python3") == 1 and "python3" or "python"
          if vim.fn.executable(mason_debugpy) == 1 then
            debugpy_cmd = mason_debugpy
          end
          require("dap-python").setup(debugpy_cmd)

          local dap = require("dap")
          dap.configurations.python = {
            {
              type = "python",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              pythonPath = debugpy_cmd,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "launch",
              name = "Launch file with arguments",
              program = "${file}",
              args = function()
                local args_string = vim.fn.input("Arguments: ")
                return vim.split(args_string, " +")
              end,
              pythonPath = debugpy_cmd,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "launch",
              name = "Launch current module",
              module = function()
                return vim.fn.input("Module name: ")
              end,
              pythonPath = debugpy_cmd,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "attach",
              name = "Attach remote",
              connect = {
                host = "localhost",
                port = function()
                  return tonumber(vim.fn.input("Port: ")) or 5678
                end,
              },
              mode = "remote",
              pythonPath = debugpy_cmd,
            },
            {
              type = "python",
              request = "attach",
              name = "Attach local",
              processId = function()
                return require("dap.utils").pick_process()
              end,
              pythonPath = debugpy_cmd,
            },
            {
              type = "python",
              request = "launch",
              name = "Debug Django",
              program = function()
                return vim.fn.getcwd() .. "/manage.py"
              end,
              args = { "runserver", "--noreload" },
              justMyCode = false,
              pythonPath = debugpy_cmd,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "launch",
              name = "Debug Flask",
              module = "flask",
              args = { "run", "--no-debugger", "--no-reload" },
              justMyCode = false,
              pythonPath = debugpy_cmd,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "launch",
              name = "Pytest",
              module = "pytest",
              args = function()
                return vim.fn.input("Pytest args: ")
              end,
              justMyCode = false,
              pythonPath = debugpy_cmd,
              console = "integratedTerminal",
            },
          }
        end,
      },
    },
  },

  -- neotest-python adapter: relocated from coding.lua, same config
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = {
      adapters = {
        ["neotest-python"] = {
          dap = { justMyCode = false },
          args = { "--log-level", "DEBUG" },
          runner = "pytest",
          python = (function()
            local py = vim.fn.exepath("python3")
            return py ~= "" and py or vim.fn.exepath("python")
          end)(),
        },
      },
    },
  },
}
```

- [ ] **Step 5: Verify all 8 dap-python configurations survived**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-dap'}})" "+lua require('lazy').load({plugins={'nvim-dap-python'}})" "+lua vim.defer_fn(function() local d=require('dap'); local names={}; for _,c in ipairs(d.configurations.python or {}) do table.insert(names, c.name) end; print('CONFIGS='..table.concat(names,'|')); vim.cmd('qall') end, 200)" 2>&1 | tail -2
```
Expected: `CONFIGS=Launch file|Launch file with arguments|Launch current module|Attach remote|Attach local|Debug Django|Debug Flask|Pytest` (8 entries, same names/order as before).

- [ ] **Step 6: Verify ruff hover-disable still works and pyright config untouched**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-lspconfig'}})" "+lua local cfg=vim.lsp.config.pyright; print('DIAG_MODE='..tostring(cfg.settings.python.analysis.diagnosticMode)); print('ORGANIZE_IMPORTS='..tostring(cfg.settings.pyright.disableOrganizeImports))" "+qall" 2>&1 | tail -2
```
Expected: `DIAG_MODE=openFilesOnly`, `ORGANIZE_IMPORTS=true` (both unchanged from before migration).

- [ ] **Step 7: Verify the Ruff config-discovery fix — project config wins, user config is a fallback**

Run (mirrors the empirical test already done once while writing Step 3 — repeat it now against the actual moved file and actual formatter definitions, not a scratch copy):
```bash
mkdir -p /tmp/ruff-verify/project && cd /tmp/ruff-verify/project
printf 'import os\nx = 1\n' > bad.py
echo "=== no project config: should inherit the user's ~/.config/ruff/ruff.toml rules ==="
~/.local/share/nvim/mason/bin/ruff check bad.py --no-cache 2>&1
echo "=== with a project ruff.toml selecting F401: project must win ==="
printf '[lint]\nselect = ["F401"]\n' > ruff.toml
~/.local/share/nvim/mason/bin/ruff check bad.py --no-cache 2>&1
rm -rf /tmp/ruff-verify
```
Expected: the first run's output matches whatever the user's own `~/.config/ruff/ruff.toml` rules produce (not necessarily flagging `F401` — depends on the user's actual custom rule set, that's the point: it's now genuinely in effect instead of silently ignored); the second run flags `F401` regardless of the user's config, since `select` in a project-level file takes priority. Also confirm the old path is gone and the new one exists:
```bash
ls ~/.config/nvim/ruff.toml 2>&1; ls ~/.config/ruff/ruff.toml 2>&1
```
Expected: first `ls` fails (`No such file`), second succeeds.

- [ ] **Step 8: Verify neotest-python adapter present**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'neotest'}})" "+lua local ok = pcall(require, 'neotest-python'); print('NEOTEST_PYTHON_LOADABLE='..tostring(ok))" "+qall" 2>&1 | tail -2
```
Expected: `NEOTEST_PYTHON_LOADABLE=true`.

- [ ] **Step 9: Checkpoint** — backup suffix `after-task7`.

---

### Task 8: Migrate `lang.rust`

**Files:**
- Modify: `lua/config/lazy.lua` (add import)
- Modify: `lua/plugins/lsp.lua:170-171` (remove redundant `rust_analyzer = false`)
- Modify: `lua/plugins/languages/rust.lua` (delete `crates.nvim` block entirely — fixes the `cond` bug; simplify codelldb path detection)

**Acceptance criterion:** the `crates.nvim` bug is fixed — previously it only loaded if Neovim was launched with `nvim Cargo.toml` directly (a startup-time `cond` check against buffer 0), so opening `Cargo.toml` mid-session never loaded it. After migration it loads via `event = "BufRead Cargo.toml"`, confirmed by opening a `Cargo.toml` file mid-session in a headless test.

- [ ] **Step 1: Write the "test" — confirm current `cond`-based load only works at direct-launch time**

Run (simulates opening Cargo.toml *after* Neovim has already started, matching the real bug):
```bash
cd /Users/leo/.config/nvim && nvim --headless "+enew" "+e /tmp/Cargo.toml" "+lua vim.defer_fn(function() local ok = pcall(require, 'crates'); print('CRATES_LOADED_MIDSESSION='..tostring(ok)); vim.cmd('qall') end, 300)" 2>&1 | tail -2
```
(Create `/tmp/Cargo.toml` first with `touch /tmp/Cargo.toml` if it doesn't exist.) Expected (bug reproduced): `CRATES_LOADED_MIDSESSION=false`.

- [ ] **Step 2: Add the `lang.rust` extra import**

Modify `lua/config/lazy.lua`, old_string:
```lua
    { import = "lazyvim.plugins.extras.lang.python" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```
new_string:
```lua
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```

- [ ] **Step 3: Remove the redundant `rust_analyzer = false` line from `lsp.lua`**

The extra sets `servers.rust_analyzer = { enabled = false }` itself (same effect, LazyVim-native disable pattern). Modify `lua/plugins/lsp.lua`, old_string:
```lua
        -- ============ Rust (managed by rustaceanvim) ============
        rust_analyzer = false,

```
new_string:
```lua
        -- ============ Rust (managed by rustaceanvim) ============
        -- rust_analyzer disable now comes from extras.lang.rust

```

- [ ] **Step 4: Delete the hand-rolled `crates.nvim` block from `languages/rust.lua`**

The extra's own `crates.nvim` definition (`event = { "BufRead Cargo.toml" }`, `opts = {completion={crates={enabled=true}}, lsp={enabled=true,actions=true,completion=true,hover=true}}`) is a strict superset of the current one (same `lsp` block, plus completion). Modify `lua/plugins/languages/rust.lua`, old_string:
```lua
  -- Cargo.toml 依赖版本提示
  {
    "saecki/crates.nvim",
    ft = "toml",
    cond = function()
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t") == "Cargo.toml"
    end,
    opts = {
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },
}
```
new_string:
```lua
  -- crates.nvim: now entirely from extras.lang.rust (event="BufRead Cargo.toml" fixes the
  -- old cond-based bug where opening Cargo.toml mid-session never loaded the plugin)
}
```

- [ ] **Step 5: Verify the fix — Cargo.toml opened mid-session now loads crates.nvim**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+enew" "+e /tmp/Cargo.toml" "+lua vim.defer_fn(function() local ok = pcall(require, 'crates'); print('CRATES_LOADED_MIDSESSION='..tostring(ok)); vim.cmd('qall') end, 300)" 2>&1 | tail -2
```
Expected: `CRATES_LOADED_MIDSESSION=true` (fixed).

- [ ] **Step 6: Verify `<leader>r*` keymap set (9 keys) still resolves — confirms our on_attach won over the extra's 2-key version**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+e /tmp/x.rs" "+lua vim.defer_fn(function() for _,k in ipairs({'rr','rt','rD','re','rc','rp','rh','ra','rx'}) do local m=vim.fn.maparg('<leader>'..k,'n',false,true); print(k..'='..(m.desc or 'MISSING')) end; vim.cmd('qall') end, 800)" 2>&1 | tail -10
```
Expected: all 9 keys resolve with the original descriptions (Runnables/Testables/Debuggables/Expand Macro/Open Cargo.toml/Parent Module/Hover Actions/Code Action/Explain Error). Note: these are buffer-local keys set in `rustaceanvim`'s `server.on_attach`, so this requires `rust-analyzer` to actually attach — if it doesn't (e.g. no `rust-analyzer` binary), the `defer_fn` delay may need lengthening or this step becomes an interactive-only check (open a real `.rs` file in a project with `Cargo.toml` and run `:checkhealth` / press `<leader>r` to see the which-key group).

- [ ] **Step 7: Verify clippy is still the checkOnSave command**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua print('CHECK_CMD='..tostring(vim.g.rustaceanvim.server.default_settings['rust-analyzer'].check.command))" "+qall" 2>&1 | tail -2
```
Expected: `CHECK_CMD=clippy`.

- [ ] **Step 8: Checkpoint** — backup suffix `after-task8`.

---

### Task 9: Migrate `lang.markdown`

**Files:**
- Modify: `lua/config/lazy.lua` (add import)
- Modify: `lua/plugins/formatting.lua:36-37` (make markdown formatter list explicit, avoid relying on ambiguous array-merge order)
- Modify: `lua/plugins/languages/markdown.lua` — no change to `render-markdown.nvim`'s 340-line `opts` (table-merges cleanly, project's values win on every leaf key already set); only the `markdown-preview.nvim` keys stay as-is (extra uses a different key, `<leader>cp`; project keeps its own `<leader>mp/ms/mt` — both can coexist, no removal needed)

**Acceptance criterion:** `markdownlint-cli2` and `markdown-toc` (already `mason ensure_installed`, previously never wired into any formatter/linter pipeline) become live: `markdownlint-cli2` runs conditionally when markdownlint diagnostics exist, `markdown-toc` runs conditionally when a `<!-- toc -->` marker exists in the buffer. `render-markdown.nvim`'s extensive customization (headings, callouts, tables, etc.) is verified unchanged.

- [ ] **Step 1: Add the `lang.markdown` extra import**

Modify `lua/config/lazy.lua`, old_string:
```lua
    { import = "lazyvim.plugins.extras.lang.rust" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```
new_string:
```lua
    { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    -- 禁用 LazyVim 默认的 lualine，使用自定义配置
```

- [ ] **Step 2: Make the markdown formatter list explicit in `formatting.lua`**

`formatters_by_ft.markdown` is a plain array; lazy.nvim's opts-merge does positional-index table-extend across fragments, which is order-dependent and easy to get wrong silently. Since `plugins/formatting.lua` loads after the extra (it's inside `{ import = "plugins" }`, listed last in `lazy.lua`), write the desired final list explicitly here rather than relying on merge order. Modify `lua/plugins/formatting.lua`, old_string:
```lua
      markdown = { "prettierd", "prettier" },
      ["markdown.mdx"] = { "prettierd", "prettier" },
```
new_string:
```lua
      markdown = { "prettierd", "prettier", "markdownlint-cli2", "markdown-toc" },
      ["markdown.mdx"] = { "prettierd", "prettier", "markdownlint-cli2", "markdown-toc" },
```

(`markdownlint-cli2`/`markdown-toc` formatters both have `condition` functions defined by the extra — they no-op unless their trigger condition is met, confirmed by reading the extra source, so adding them unconditionally to the list is safe: no-op most of the time, active only when relevant.)

- [ ] **Step 3: Verify the formatter list**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+e /tmp/x.md" "+lua vim.defer_fn(function() local c=require('conform'); local fmts=c.list_formatters_for_buffer(0); local names={}; for _,f in ipairs(fmts) do table.insert(names, f) end; print('MD_FORMATTERS='..table.concat(names,',')); vim.cmd('qall') end, 300)" 2>&1 | tail -2
```
Expected: `MD_FORMATTERS=prettierd,prettier,markdownlint-cli2,markdown-toc`.

- [ ] **Step 4: Verify `render-markdown.nvim` customization is unchanged (spot-check 3 deep keys)**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'render-markdown.nvim'}})" "+lua local rm = require('render-markdown.state'); local o = rm.config; print('CHECKBOX_ENABLED='..tostring(o.checkbox.enabled)); print('HEADING_BORDER='..tostring(o.heading.border)); print('CODE_BORDER='..tostring(o.code.border))" "+qall" 2>&1 | tail -3
```
Expected: `CHECKBOX_ENABLED=true`, `HEADING_BORDER=true`, `CODE_BORDER=thin` — all match the project's original values (the extra's own markdown-preset for these 3 keys is `false`/no-icons/default, which would show up here if the merge had gone the wrong way, i.e. if the extra's fragment had loaded *after* `languages/markdown.lua`'s — it doesn't, since `plugins/` imports last).

- [ ] **Step 5: Checkpoint** — backup suffix `after-task9` (final).

---

## Final Verification (run once, after all 9 tasks)

- [ ] **Full headless startup with no errors**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+qall" 2>&1
```
Expected: empty output (no error text). Any `Error detected while processing...` line means a task's edit broke spec loading — identify which fragment via the message and re-check that task's Modify steps.

- [ ] **`:Lazy sync` to install newly-added plugins**

This must be run interactively (not headless) since it's a TUI. Open Neovim normally, run `:Lazy sync`, confirm no red/failed entries for: `clangd_extensions.nvim`, `fredrikaverpil/neotest-golang`. Also confirm `neotest-go` and `languages/javascript.lua`'s old dependencies are gone from the installed list (or at least unused — lazy.nvim doesn't auto-uninstall on spec removal, run `:Lazy clean` if you want to reclaim disk space, reviewing what it proposes to remove first).

- [ ] **Health check**

Run interactively: `:checkhealth lazy` and `:checkhealth lsp`. Confirm no new errors versus pre-migration baseline.

- [ ] **Manual smoke test per language** (open one real file per language if available in any local project, otherwise skip — the headless checks above already cover config correctness)
  - Go: open a `.go` file, confirm `gopls` attaches (`:LspInfo`), run `<leader>Tr` on a `_test.go` file.
  - Python: open a `.py` file, confirm `pyright`+`ruff` attach, run `<leader>dPt` inside a test function.
  - Rust: open a `.rs` file in a `Cargo.toml` project, confirm `<leader>rr` (Runnables) works.
  - Markdown: open a `.md` file, confirm headings/tables still render as before.
