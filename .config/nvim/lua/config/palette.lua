-- =============================================================================
-- Solarized Zen Palette - Single source of truth
-- =============================================================================
-- Mirrors:
--   kitty/solarized-zen-dark.conf   (dark mode)
--   kitty/solarized-zen-light.conf  (light mode)
--
-- When changing a color here, update the matching line in the kitty conf.
-- Each kitty conf color value is preceded by a comment line: "# palette: <key>".
-- =============================================================================

local M = {}

-- ---------------------------------------------------------------------------
-- Dark palette
-- ---------------------------------------------------------------------------
M.dark = {
  -- Backgrounds (dark → light)
  -- main background | kitty: background
  bg   = "#00242c",
  -- sidebar, statusbar, tab bar | kitty: tab_bar_background
  bg1  = "#002830",
  -- popup, visual, inactive tab | kitty: inactive_tab_background
  bg2  = "#0a3848",
  -- lualine section c depth
  bg3  = "#003440",
  -- cursor line highlight
  bg4  = "#003a4a",
  -- lualine inactive depth
  bg5  = "#004050",

  -- Foregrounds (light → dark)
  -- main foreground / color7 | kitty: foreground
  fg      = "#839395",
  -- comment, lineNr, inactive tab fg
  fg2     = "#637981",
  -- muted text / color8 (bright black)
  fg3     = "#576d74",
  -- max contrast on colored bg (e.g. lualine command mode)
  fg_max  = "#fdf6e3",
  -- one step below fg_max — bold/strong emphasis without going full white
  fg_strong = "#aeb2aa",

  -- ANSI normal (color0–7)
  -- color0 | kitty: color0
  black   = "#4a7080",
  -- color1 | kitty: color1
  red     = "#db302d",
  -- color2 | kitty: color2
  green   = "#849900",
  -- color3 | kitty: color3
  yellow  = "#b28500",
  -- color4 | kitty: color4
  blue    = "#268bd3",
  -- color5 | kitty: color5
  magenta = "#d23681",
  -- color6 | kitty: color6
  cyan    = "#29a298",

  -- ANSI bright (color8–15)
  -- color8 | kitty: color8
  br_black   = "#576d74",
  -- color9 | kitty: color9
  br_red     = "#e8524f",
  -- color10 | kitty: color10
  br_green   = "#9eb200",
  -- color11 | kitty: color11
  br_yellow  = "#cc9b00",
  -- color12 | kitty: color12
  br_blue    = "#4aa3e3",
  -- color13 | kitty: color13
  br_magenta = "#e04a95",
  -- color14 | kitty: color14
  br_cyan    = "#35bdb2",
  -- color15 | kitty: color15
  br_white   = "#a0b2b2",

  -- Extended
  -- color16 | kitty: color16
  orange    = "#c94c16",
  -- color17 | kitty: color17
  br_orange = "#f55350",

  -- Semantic UI
  -- kitty: selection_background
  selection     = "#268bd3",
  -- kitty: url_color
  url           = "#29a298",
  -- LspReference read/text (cool blue-dark)
  lsp_ref       = "#003850",
  -- LspReference write (warm dark)
  lsp_ref_write = "#2a1800",
}

-- ---------------------------------------------------------------------------
-- Light palette
-- ---------------------------------------------------------------------------
M.light = {
  -- Backgrounds (light → dark)
  -- main background | kitty: background
  bg   = "#f4f0e2",
  -- sidebar, inactive tab | kitty: inactive_tab_background
  bg1  = "#e4dfcc",
  -- selection, popup, visual | kitty: selection_background
  bg2  = "#b8d0e8",
  -- cursor line highlight
  bg3  = "#dcd8ca",
  -- tab bar background | kitty: tab_bar_background
  bg4  = "#c8c0aa",
  -- lualine inactive depth
  bg5  = "#c4bcaa",

  -- Foregrounds (dark → light)
  -- main foreground | kitty: foreground
  fg      = "#1c1c1e",
  -- secondary text
  fg2     = "#44444c",
  -- muted: lineNr, comment | kitty: inactive_border_color
  fg3     = "#9a9aa4",
  -- max contrast text = br_white | kitty: color15
  fg_max  = "#0d0d0d",
  -- one step below fg_max — bold/strong emphasis (light mode has little headroom)
  fg_strong = "#232323",

  -- ANSI normal (color0–7)
  -- color0 | kitty: color0
  black   = "#3d4551",
  -- color1 | kitty: color1
  red     = "#be1e2d",
  -- color2 | kitty: color2
  green   = "#0a7c3c",
  -- color3 | kitty: color3
  yellow  = "#8a6200",
  -- color4 | kitty: color4
  blue    = "#1565c0",
  -- color5 | kitty: color5
  magenta = "#7c3aed",
  -- color6 | kitty: color6
  cyan    = "#0e7490",
  -- color7 | kitty: color7
  white   = "#57606a",

  -- ANSI bright (color8–15, deeper on light bg)
  -- color8 | kitty: color8
  br_black   = "#24292f",
  -- color9 | kitty: color9
  br_red     = "#9e1823",
  -- color10 | kitty: color10
  br_green   = "#065f46",
  -- color11 | kitty: color11
  br_yellow  = "#7c5200",
  -- color12 | kitty: color12
  br_blue    = "#1e40af",
  -- color13 | kitty: color13
  br_magenta = "#5b21b6",
  -- color14 | kitty: color14
  br_cyan    = "#155e75",
  -- color15 | kitty: color15
  br_white   = "#0d0d0d",

  -- Extended
  -- color16 | kitty: color16
  orange    = "#b84600",
  -- color17 | kitty: color17
  br_orange = "#922f00",

  -- Semantic UI
  -- kitty: selection_background
  selection     = "#b8d0e8",
  -- kitty: cursor / active_border_color
  url           = "#0550ae",
  -- LspReference read/text (light blue)
  lsp_ref       = "#dde8f0",
  -- LspReference write (light orange)
  lsp_ref_write = "#f0e0dd",
}

return M
