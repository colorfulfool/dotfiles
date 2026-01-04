require("plugins")
require("commands")

require("astrotheme").setup({
  palette = "astrodark",
  style = {
    transparent = true,
    simple_syntax_colors = true
  },

  termguicolors = true,
})

vim.cmd("colorscheme astrodark")

vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH

local set = vim.opt -- set options
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2
set.number = false
set.relativenumber = true
set.scrolloff = 5
set.signcolumn = "no"
set.expandtab = true

vim.cmd("set wrap!")
vim.cmd("set cursorline")

-- vim.opt.foldmethod = "indent"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight_yank', {}),
  desc = 'Hightlight selection on yank',
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
  end,
})

vim.api.nvim_set_option("clipboard", "unnamed")

vim.api.nvim_set_keymap('t', '<ESC>', '<C-\\><C-n>', { noremap = true })

local bufopts = { noremap = true, silent = true, buffer = buffer }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, bufopts)
vim.keymap.set("n", "]e", vim.diagnostic.goto_next, bufopts)
vim.keymap.set("n", "[e", vim.diagnostic.goto_prev, bufopts)
vim.keymap.set("n", "]q", ":cnext<cr>")
vim.keymap.set("n", "[q", ":cprev<cr>")
vim.keymap.set("n", "<space>h", ":noh<cr>")

vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})

-- Line swapping functionality
vim.keymap.set('n', '<C-S-j>', function()
  local current_line = vim.fn.line('.')
  local total_lines = vim.fn.line('$')
  if current_line < total_lines then
    vim.cmd('move .+1')
  end
end, { noremap = true, silent = true })

vim.keymap.set('n', '<C-S-k>', function()
  local current_line = vim.fn.line('.')
  if current_line > 1 then
    vim.cmd('move .-2')
  end
end, { noremap = true, silent = true })

vim.api.nvim_create_user_command("BlankSlate", "%bd|!git switch main", {})
vim.api.nvim_create_user_command("CleanSlate", "%bd|!git switch main", {})

local function remove_qf_item(mode)
  local qf_list = vim.fn.getqflist()
  local del_qf_idx, del_ct

  if mode == 'v' then
    local start_lnum = vim.fn.getpos("'<")[2]
    local end_lnum = vim.fn.getpos("'>")[2]
    del_qf_idx = start_lnum - 1
    del_ct = end_lnum - del_qf_idx
  else
    del_qf_idx = vim.fn.line('.') - 1
    del_ct = vim.v.count > 1 and vim.v.count or 1
  end

  -- Delete items (Lua tables are 1-indexed)
  for _ = 1, del_ct do
    table.remove(qf_list, del_qf_idx + 1)
  end

  vim.fn.setqflist(qf_list, 'r')

  if #qf_list > 0 then
    vim.cmd(string.format('%dcfirst', del_qf_idx + 1))
    vim.cmd.copen()
  else
    vim.cmd.cclose()
  end
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function()
    vim.keymap.set('n', 'dd', function() remove_qf_item('n') end, { buffer = true })
    vim.keymap.set('v', 'x', function() remove_qf_item('v') end, { buffer = true })
  end
})
