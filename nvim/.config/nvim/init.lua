require("plugins")

require("astrotheme").setup({
  palette = "astrodark",
	style = {
    transparent = true,        
    simple_syntax_colors = true,
    italic_comments = false
  },

  termguicolors = true,
})

vim.cmd("colorscheme astrodark")

local set = vim.opt -- set options
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2
set.number = false
set.relativenumber = true
set.scrolloff = 5
set.signcolumn = "no"
set.expandtab = true

vim.opt.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<space><space>', builtin.find_files, {})
vim.keymap.set('n', '<space>fg', builtin.live_grep, {})
vim.keymap.set('n', '<space>fs', builtin.grep_string, {})
vim.keymap.set('n', '<space>fb', builtin.buffers, {})
vim.keymap.set('n', '<space>fh', builtin.help_tags, {})
vim.keymap.set('n', '<space>gb', builtin.git_branches, {})
local telescope = require('telescope')
vim.keymap.set('n', '<space>gp', telescope.extensions.gh.pull_request, {})

vim.api.nvim_set_keymap('t', '<ESC>', '<C-\\><C-n>', {noremap = true})

vim.api.nvim_set_option("clipboard","unnamed")

local bufopts = { noremap = true, silent = true, buffer = bufnr }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, bufopts)

local api = require('typescript-tools.api')
vim.keymap.set('n', 'gd', api.go_to_source_definition, {})

require('telescope').setup{
  defaults = {
    file_ignore_patterns = {
      "node_modules",
      "build",
      "out"
    }
  }
}

require("autoclose").setup()
