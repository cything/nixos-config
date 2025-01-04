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

-- copied from https://github.com/jdhao/nvim-config/blob/c7fb090e4ce94e72414169a247ac62f049d6b03b/lua/custom-autocmd.lua#L138
-- Return to last cursor position when opening a file, note that here we cannot use BufReadPost
-- as event. It seems that when BufReadPost is triggered, FileType event is still not run.
-- So the filetype for this buffer is empty string.
api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("resume_cursor_position", { clear = true }),
  pattern = "*",
  callback = function(ev)
    local mark_pos = api.nvim_buf_get_mark(ev.buf, '"')
    local last_cursor_line = mark_pos[1]

    local max_line = vim.fn.line("$")
    local buf_filetype = api.nvim_get_option_value("filetype", { buf = ev.buf })
    local buftype = api.nvim_get_option_value("buftype", { buf = ev.buf })

    -- only handle normal files
    if buf_filetype == "" or buftype ~= "" then
      return
    end

    -- Only resume last cursor position when there is no go-to-line command (something like '+23').
    if vim.fn.match(vim.v.argv, [[\v^\+(\d){1,}$]]) ~= -1 then
      return
    end

    if last_cursor_line > 1 and last_cursor_line <= max_line then
      -- vim.print(string.format("mark_pos: %s", vim.inspect(mark_pos)))
      -- it seems that without vim.schedule, the cursor position can not be set correctly
      vim.schedule(function()
        local status, result = pcall(api.nvim_win_set_cursor, 0, mark_pos)
        if not status then
          api.nvim_err_writeln(
            string.format("Failed to resume cursor position. Context %s, error: %s", vim.inspect(ev), result)
          )
        end
      end)
      -- the following two ways also seem to work,
      -- ref: https://www.reddit.com/r/neovim/comments/104lc26/how_can_i_press_escape_key_using_lua/
      -- vim.api.nvim_feedkeys("g`\"", "n", true)
      -- vim.fn.execute("normal! g`\"")
    end
  end,
})

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
