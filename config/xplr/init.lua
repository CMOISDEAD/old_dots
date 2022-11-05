---@diagnostic disable
version = "0.20.0"
---@diagnostic enable
local home = os.getenv("HOME")
package.path = home .. "/.config/xplr/plugins/?/init.lua;" .. home .. "/.config/xplr/plugins/?.lua;" .. package.path
require("icons").setup()
require("zentable").setup()
require("fzf").setup({
	mode = "default",
	key = "ctrl-f",
	args = "--preview 'pistol {}'",
})
require("zoxide").setup({
	mode = "default",
	key = "Z",
})
require("dual-pane").setup({
	active_pane_width = { Percentage = 70 },
	inactive_pane_width = { Percentage = 30 },
})
require("preview-tabbed").setup({
	mode = "action",
	key = "p",
	fifo_path = "/tmp/xplr.fifo",
	previewer = os.getenv("HOME") .. "/.config/nnn/plugins/preview-tabbed",
})
require("ouch").setup({
	mode = "action",
	key = "o",
})
require("qrcp").setup({
	mode = "action",
	key = "Q",
	send_options = "-i wlp2s0",
	receive_options = "-i wlp2s0",
})
require("xclip").setup({
	copy_command = "xclip-copyfile",
	copy_paths_command = "xclip -sel clip",
	paste_command = "xclip-pastefile",
	keep_selection = false,
})
require("tri-pane").setup({
	layout_key = "T", -- In switch_layout mode
	as_default_layout = true,
	left_pane_width = { Percentage = 20 },
	middle_pane_width = { Percentage = 50 },
	right_pane_width = { Percentage = 30 },
})
