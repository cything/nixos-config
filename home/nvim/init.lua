require("plugin_specs")

local keymap = vim.keymap
local opt = vim.opt
local api = vim.api

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
require("nvim-tree").setup()

require("lualine").setup({
	options = {
		theme = "auto",
		icons_enabled = true,
		globalstatus = true,
	},
})

require("gitsigns").setup()

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.relativenumber = true
opt.ignorecase = true
opt.smartcase = true
opt.scrolloff = 3
opt.confirm = true
opt.history = 500
opt.undofile = true
opt.termguicolors = true
opt.showmode = false
opt.mouse = ""
opt.wrap = false
opt.clipboard:append("unnamedplus")

vim.cmd.colorscheme("iceberg")

-- restore terminal cursor on exit
api.nvim_create_autocmd("VimLeave", {
	callback = function()
		opt.guicursor = "a:ver25-blinkon500-blinkon500"
	end,
})

-- blinking cursor in insert mode
opt.guicursor = "i-ci-ve:ver25-blinkon500-blinkon500"

keymap.set("n", "<space>s", require("nvim-tree.api").tree.toggle, {
	desc = "toggle nvim-tree",
	silent = true,
})

-- shortcut to command mode
keymap.set({ "n", "x" }, ";", ":", { silent = true })

keymap.set("n", "<space>o", "printf('m`%so<ESC>``', v:count1)", {
	expr = true,
	desc = "insert line below without moving cursor",
})

keymap.set("n", "<space>O", "printf('m`%sO<ESC>``', v:count1)", {
	expr = true,
	desc = "insert line above without moving cursor",
})

keymap.set("n", "/", [[/\v]])

keymap.set("n", "c", '"_c')
keymap.set("n", "C", '"_C')
keymap.set("n", "cc", '"_cc')
keymap.set("x", "c", '"_c')
keymap.set("x", "p", '"_c<Esc>p')

-- Break inserted text into smaller undo units when we insert some punctuation chars.
local undo_ch = { ",", ".", "!", "?", ";", ":" }
for _, ch in ipairs(undo_ch) do
	keymap.set("i", ch, ch .. "<c-g>u")
end

keymap.set("i", "<C-A>", "<HOME>")
keymap.set("i", "<C-E>", "<END>")
