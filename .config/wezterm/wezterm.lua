-- Import the wezterm module
local wezterm = require 'wezterm'
-- Creates a config object which we will be adding our config to
local config = wezterm.config_builder()

-- (This is where our config will go)
config.color_scheme = 'Solarized Dark Higher Contrast'
config.font =wezterm.font_with_fallback { 
	{ family = 'JetBrainsMono Nerd Font', weight= 'Bold'},
        'FZQingKeBenYueSongS-R-GB'
}
config.font_size = 16
config.window_background_opacity = 0.8
config.macos_window_background_blur = 30
config.window_frame = {
  font =wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold'}),
  font_size = 13,
}
config.window_decorations = "RESIZE"
config.default_prog = { 'zsh' }
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}


-- 关闭时不进行确认
config.window_close_confirmation = "NeverPrompt"
-- 如果只有一个标签页，则隐藏标签栏
config.hide_tab_bar_if_only_one_tab = true
-- 禁用滚动条
config.enable_scroll_bar = false

-- 配置窗口打开时默认大小
config.initial_cols = 120
config.initial_rows = 30


-- 修改切换终端快捷键
config.keys = {

	{ key = "[", mods = "CTRL|ALT", action = wezterm.action({ ActivateTabRelative = -1 }) },
	{ key = "]", mods = "CTRL|ALT", action = wezterm.action({ ActivateTabRelative = 1 }) },
	{ key = "w", mods = "CTRL|ALT", action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
	{ key = "n", mods = "CTRL|ALT", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
	--  切换全屏
	{ key = "t", mods = "CTRL|SHIFT", action = wezterm.action.ToggleFullScreen },
	-- Ctrl + Shift + - 缩小字体
	{ key = "-", mods = "CTRL|SHIFT", action = wezterm.action.IncreaseFontSize },
	-- Ctrl + Shift + = 扩大字体
	{ key = "=", mods = "CTRL|SHIFT", action = wezterm.action.DecreaseFontSize },
	-- Ctrl + Shift + 0 重置字体
	{ key = "0", mods = "CTRL|SHIFT", action = wezterm.action.ResetFontSize },
}


-- 定义 Alt+数字 切换到对应标签页的快捷键
for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'ALT',
        action = wezterm.action.ActivateTab(i - 1),
    })
end


-- Returns our config to be evaluated. We must always do this at the bottom of this file
return config
