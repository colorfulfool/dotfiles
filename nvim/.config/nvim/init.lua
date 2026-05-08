require("plugins")
require("lsp-commands")
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

vim.opt.foldmethod = "manual"
vim.opt.foldlevelstart = 99

for _, key in ipairs({ "zc", "zC", "zo", "zO", "za", "zA", "zM", "zR", "zm", "zr", "zv", "zx" }) do
  vim.keymap.set("n", key, function()
    if not vim.b.ts_folds_enabled then
      vim.b.ts_folds_enabled = true
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
    vim.api.nvim_feedkeys(key, "n", false)
  end)
end

vim.opt.splitright = true
vim.opt.splitbelow = true

local saved_views = {}
vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave", "WinLeave" }, {
  callback = function(args)
    saved_views[args.buf] = vim.fn.winsaveview()
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  callback = function(args)
    local view = saved_views[args.buf]
    if view then vim.fn.winrestview(view) end
  end,
})
vim.api.nvim_create_autocmd("BufWipeout", {
  callback = function(args) saved_views[args.buf] = nil end,
})

vim.opt.lazyredraw = true

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight_yank', {}),
  desc = 'Hightlight selection on yank',
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
  end,
})


vim.api.nvim_set_keymap('t', '<ESC>', '<C-\\><C-n>', { noremap = true })

vim.diagnostic.config({ virtual_text = true })

if vim.lsp.document_color then
  vim.lsp.document_color.enable(false)
end

local bufopts = { noremap = true, silent = true, buffer = buffer }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, bufopts)
vim.keymap.set("n", "]e", vim.diagnostic.goto_next, bufopts)
vim.keymap.set("n", "[e", vim.diagnostic.goto_prev, bufopts)
vim.keymap.set("n", "]q", ":cnext<cr>")
vim.keymap.set("n", "[q", ":cprev<cr>")
vim.keymap.set("n", "<space>h", ":noh<cr>")

vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})

vim.api.nvim_create_user_command("GitBlame", function(data)
  vim.cmd(string.format("!git blame '%s' -L%d,%d", vim.fn.expand("%"), data.line1, data.line2))
end, { range = true })

vim.api.nvim_create_user_command("BlankSlate", "%bd|!git switch main", {})

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
