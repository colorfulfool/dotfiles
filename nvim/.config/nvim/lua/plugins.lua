local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Installing packer close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

return packer.startup(function(use)
  use("wbthomason/packer.nvim") -- Have packer manage itself

  use("AstroNvim/astrotheme")

  use {
    'nvim-telescope/telescope.nvim',
    commit = '814f102',
    requires = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-github.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    },
    config = function()
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = {
            "^node_modules/",
            "%.next/",
            "^build/",
            "^out/",
            "^performance/",
            "^venv/",
            "^__pycache__/",
            "^.git/",
            ".png$",
            ".avif$",
            ".webp$",
            ".mp3$",
          },
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden' -- search in .github and such
          },
        },
        pickers = {
          buffers = { sort_mru = true },
          find_files = { hidden = true },
          git_branches = { pattern = "refs/heads" }
        }
      })

      require('telescope').load_extension('fzf')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<space><space>', builtin.find_files, {})
      vim.keymap.set('n', '<space>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<space>fs', function()
        local col = vim.fn.col('.')
        local line = vim.fn.getline('.')
        local s, e = col, col
        while s > 1 and line:sub(s - 1, s - 1):match('[%w_%-]') do s = s - 1 end
        while e < #line and line:sub(e + 1, e + 1):match('[%w_%-]') do e = e + 1 end
        builtin.grep_string({ search = line:sub(s, e) })
      end, {})
      vim.keymap.set('v', '<space>fs', function()
        vim.cmd('noau normal! "vy"')
        local text = vim.fn.getreg('v')
        builtin.grep_string({ search = text })
      end, {})
      vim.keymap.set('n', '<space>fb', builtin.buffers, {})
      vim.keymap.set('n', '<space>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<space>fr', builtin.resume, {})
      vim.keymap.set('n', '<space>gb', builtin.git_branches, {})
      vim.keymap.set('n', '<space>fL', builtin.lsp_dynamic_workspace_symbols, {})
      local make_entry = require('telescope.make_entry')
      local pickers = require('telescope.pickers')
      local finders = require('telescope.finders')
      local conf = require('telescope.config').values

      -- <space>fa (workspace symbols): dynamic_workspace_symbols returns a flat
      -- SymbolInformation list and ignores both file_ignore_patterns and the
      -- `symbols` kind option, so filter in a custom entry_maker:
      --   * drop generated files (e.g. Next.js .next/types)
      --   * keep functions / methods / classes
      --   * keep PascalCase variables/constants too, since arrow-function
      --     components (const Foo = () => ...) report as Variable, not Function.
      --     The PascalCase test (initial upper + a lowercase) keeps components
      --     like PrimaryButton while dropping consts like defaultCountry/API_URL.
      local function filtered_symbol_maker()
        local default_maker = make_entry.gen_from_lsp_symbols({})
        return function(item)
          if item.filename and item.filename:match('%.next/') then
            return nil
          end
          local kind = (item.kind or ''):lower()
          local name = (item.text or ''):match('%]%s+(.*)')
          local callable = kind == 'function' or kind == 'method' or kind == 'class'
          local component = (kind == 'variable' or kind == 'constant')
            and name and name:match('^%u') and name:match('%l')
          if not (callable or component) then
            return nil
          end
          return default_maker(item)
        end
      end
      vim.keymap.set('n', '<space>fa', function()
        builtin.lsp_dynamic_workspace_symbols({ entry_maker = filtered_symbol_maker() })
      end, {})

      local SK = vim.lsp.protocol.SymbolKind
      local KEEP = { Function = true, Method = true, Constructor = true,
        Class = true, Interface = true, Enum = true, Namespace = true,
        Module = true, Variable = true, Constant = true }
      local RECURSE = { Class = true, Interface = true, Enum = true,
        Namespace = true, Module = true, Struct = true }

      local function import_line_set(bufnr)
        local set = {}
        local in_import = false
        for i, raw in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
          local l = raw:gsub('^%s+', '')
          if in_import then
            set[i - 1] = true -- LSP lines are 0-indexed
            if l:match("from%s+['\"]") or l:match("['\"]%s*;?%s*$") then
              in_import = false
            end
          elseif l:match('^import[%s{*\'"]') or l == 'import' then
            set[i - 1] = true
            if not (l:match("from%s+['\"]") or l:match("^import%s+['\"]")) then
              in_import = true -- multi-line import, keep consuming until `from '...'`
            end
          end
        end
        return set
      end

      local function collect_defs(symbols, bufnr, imports, out)
        for _, s in ipairs(symbols or {}) do
          local kind = SK[s.kind]
          local sel = s.selectionRange or s.range or (s.location and s.location.range)
          local is_import = (kind == 'Variable' or kind == 'Constant')
            and sel and imports[sel.start.line]
          if sel and KEEP[kind] and not is_import then
            table.insert(out, {
              filename = vim.api.nvim_buf_get_name(bufnr),
              lnum = sel.start.line + 1,
              col = sel.start.character + 1,
              kind = kind,
              text = string.format('[%s] %s', kind, s.name),
            })
          end
          if s.children and RECURSE[kind] then
            collect_defs(s.children, bufnr, imports, out)
          end
        end
      end

      vim.keymap.set('n', '<space>fl', function()
        local bufnr = vim.api.nvim_get_current_buf()
        local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
        vim.lsp.buf_request_all(bufnr, 'textDocument/documentSymbol', params, function(results)
          local symbols
          for _, r in pairs(results or {}) do
            if r.result and #r.result > 0 then symbols = r.result break end
          end
          if not symbols then
            vim.notify('No document symbols', vim.log.levels.INFO)
            return
          end
          local items = {}
          collect_defs(symbols, bufnr, import_line_set(bufnr), items)
          pickers.new({}, {
            prompt_title = 'Document Definitions',
            finder = finders.new_table({
              results = items,
              entry_maker = make_entry.gen_from_lsp_symbols({ bufnr = bufnr }),
            }),
            sorter = conf.generic_sorter({}),
            previewer = conf.qflist_previewer({}),
          }):find()
        end)
      end, {})
      vim.keymap.set('n', 'gr', builtin.lsp_references, {})

      local telescope = require('telescope')
      vim.keymap.set('n', '<space>gp', telescope.extensions.gh.pull_request, {})
    end
  }

  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      vim.keymap.set("n", "<space>ti",
        function()
          local result = vim.treesitter.get_captures_at_cursor(0)
          print(vim.inspect(result))
        end,
        { noremap = true, silent = false }
      )

      require('nvim-treesitter.configs').setup {
        ensure_installed = { "lua", "javascript", "typescript", "python", "ruby", "gleam", "bash", "go", "markdown", "css" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = true,
        },
      }
    end
  }

  use {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        window = {
          width = 30
        },
        filesystem = {
          follow_current_file = {
            enabled = true
          }
        }
      })

      vim.keymap.set('n', '<space>te', ':Neotree toggle<cr>')
    end
  }

  use {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({
        columns = {}
      })

      vim.keymap.set('n', '<space>o', ':Oil<cr>')
    end,
  }

  use {
    "colorfulfool/todo-comments.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup({
        search = {
          pattern = [[\b(TODO|BUG|FIXME):]]
        }
      })
    end,
  }

  use {
    "neovim/nvim-lspconfig",
    requires = { "saghen/blink.cmp" },
    tag = "v2.5.0",
    config = function()
      local lspconfig = require('lspconfig')
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      lspconfig.gleam.setup({ capabilities = capabilities })
      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.rust_analyzer.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
      lspconfig.svelte.setup({ capabilities = capabilities })
      lspconfig.tailwindcss.setup({
        capabilities = capabilities,
        cmd_env = { NODE_OPTIONS = "--max-old-space-size=8192" },
        settings = {
          tailwindCSS = {
            rootFontSize = vim.fn.fnamemodify(vim.fn.getcwd(), ':t') == 'asvla-site-frontend' and 20 or 16,
          },
        },
      })

      -- Resolve Tailwind v4 var(--*) refs in tailwindcss LSP hover to literal
      -- values (v4 generates `font-size: var(--text-lg)` and the language
      -- server shows the var ref instead of the resolved px).
      local theme_vars = nil
      local function load_theme_vars()
        if theme_vars then return theme_vars end
        theme_vars = {}
        local files = vim.fn.systemlist("rg -l --glob '*.css' -- '--[a-z]' 2>/dev/null")
        for _, f in ipairs(files) do
          for _, line in ipairs(vim.fn.readfile(f)) do
            local name, val = line:match("^%s*(%-%-[%w-]+):%s*([^;]+);")
            if name and val then theme_vars[name] = vim.trim(val) end
          end
        end
        return theme_vars
      end
      vim.api.nvim_create_user_command("TailwindReloadThemeVars", function()
        theme_vars = nil
      end, {})

      local orig_hover = vim.lsp.handlers["textDocument/hover"]
      vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client and client.name == "tailwindcss" and result and result.contents then
          local vars = load_theme_vars()
          local function fix(s)
            return (s:gsub("var%((%-%-[%w-]+)%)", function(n)
              return vars[n] and (vars[n] .. " /* " .. n .. " */") or ("var(" .. n .. ")")
            end))
          end
          local c = result.contents
          if type(c) == "string" then
            result.contents = fix(c)
          elseif c.value then
            c.value = fix(c.value)
          end
        end
        return orig_hover(err, result, ctx, config)
      end
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
          },
        },
      })
      -- lspconfig.elixirls.setup({
      --   capabilities = capabilities,
      --   cmd = { "/Users/antonkhamets/.local/elixir-ls/language_server.sh" }
      -- })

      -- tsgo: the Go TypeScript LSP (@typescript/native-preview), standard LSP
      vim.lsp.config('tsgo', {
        cmd = { 'tsgo', '--lsp', '--stdio' },
        filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
        root_markers = { { 'tsconfig.json', 'jsconfig.json' }, 'package.json', '.git' },
        capabilities = capabilities,
      })
      vim.lsp.enable('tsgo')

      -- Replicate typescript-tools commands via standard LSP code actions.
      -- tsgo advertises these WITHOUT the `.ts` suffix that tsserver/typescript-tools used:
      --   quickfix, source.organizeImports, source.removeUnusedImports, source.sortImports, source.fixAll
      local function ts_source_action(kind)
        return function()
          vim.lsp.buf.code_action({
            context = { only = { kind }, diagnostics = {} },
            apply = true,
          })
        end
      end

      -- tsgo does NOT advertise `source.addMissingImports`; it only offers the
      -- import as a `quickfix` action attached to each "Cannot find name"
      -- diagnostic (and an aggregate "Add all missing imports" when several are
      -- missing). So we request quickfix actions for all buffer diagnostics and
      -- apply the aggregate, falling back to the lone "Add import" action.
      local function ts_add_missing_imports()
        local bufnr = vim.api.nvim_get_current_buf()
        local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'tsgo' })[1]
        if not client then return end
        local lsp_diags = {}
        for _, d in ipairs(vim.diagnostic.get(bufnr)) do
          if d.user_data and d.user_data.lsp then
            table.insert(lsp_diags, d.user_data.lsp)
          end
        end
        if #lsp_diags == 0 then return end
        local params = {
          textDocument = vim.lsp.util.make_text_document_params(bufnr),
          range = {
            start = { line = 0, character = 0 },
            ['end'] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
          },
          context = { only = { 'quickfix' }, diagnostics = lsp_diags },
        }
        client:request('textDocument/codeAction', params, function(err, result)
          if err or not result then return end
          local chosen
          for _, a in ipairs(result) do
            if type(a) == 'table' and a.title == 'Add all missing imports' then
              chosen = a
              break
            end
          end
          if not chosen then
            for _, a in ipairs(result) do
              if type(a) == 'table' and a.title and a.title:match('^Add import') then
                chosen = a
                break
              end
            end
          end
          if not chosen then return end
          local function apply(a)
            if a.edit then
              vim.lsp.util.apply_workspace_edit(a.edit, client.offset_encoding)
            end
            if a.command then
              client:request('workspace/executeCommand', a.command, nil, bufnr)
            end
          end
          if chosen.edit or chosen.command then
            apply(chosen)
          else
            client:request('codeAction/resolve', chosen, function(_, resolved)
              apply(resolved or chosen)
            end, bufnr)
          end
        end, bufnr)
      end

      vim.api.nvim_create_user_command('TSToolsAddMissingImports', ts_add_missing_imports, {})
      vim.api.nvim_create_user_command('TSToolsOrganizeImports', ts_source_action('source.organizeImports'), {})
      vim.api.nvim_create_user_command('TSToolsRemoveUnused', ts_source_action('source.removeUnused'), {})
      vim.api.nvim_create_user_command('TSToolsRemoveUnusedImports', ts_source_action('source.removeUnusedImports'), {})
      vim.api.nvim_create_user_command('TSToolsSortImports', ts_source_action('source.sortImports'), {})
      vim.api.nvim_create_user_command('TSToolsFixAll', ts_source_action('source.fixAll'), {})

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        callback = function(args)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf, silent = true })
        end
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client_id = args.data.client_id

          local client = vim.lsp.get_client_by_id(client_id)
          if not client then return end

          if client:supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              callback = function()
                local now_client = vim.lsp.get_client_by_id(client_id)
                if not now_client then return end

                vim.lsp.buf.format({ bufnr = args.buf, id = client_id })
              end
            })
          end
        end
      })
    end
  }

  use {
    "luckasRanarison/tailwind-tools.nvim",
    run = ":UpdateRemotePlugins",
    requires = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("tailwind-tools").setup({
        document_color = {
          enabled = false
        },
        conceal = {
          enabled = false
        },
        server = {
          override = false, -- LSP configured directly via lspconfig.tailwindcss.setup
        }
      })
    end
  }

  use {
    "windwp/nvim-ts-autotag",
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,          -- Auto close tags
          enable_rename = true,         -- Auto rename pairs of tags
          enable_close_on_slash = false -- Auto close on trailing </
        }
      })
    end
  }

  use "almo7aya/openingh.nvim"

  use {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = { show_start = false, show_end = false },
        exclude = {}
      })
    end
  }

  use {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup({ n_lines = 100 })
      require("mini.surround").setup({
        n_lines = 100,
        custom_surroundings = {
          T = {
            output = { left = '{twMerge(', right = ')}' },
          },
          t = {
            output = function()
              local tag = MiniSurround.user_input("Tag")
              if not tag then return nil end
              local name = tag:match("^%S*")
              local pad = string.rep(" ", vim.fn.indent(vim.fn.line(".")))
              local sel_start = vim.fn.line("'<")
              local sel_end = vim.fn.line("'>")
              vim.schedule(function()
                vim.cmd((sel_start + 1) .. "," .. (sel_end + 1) .. ">")
              end)
              return { left = "<" .. tag .. ">\n" .. pad, right = "\n" .. pad .. "</" .. name .. ">" }
            end,
          },
        },
      })
      require("mini.operators").setup({
        replace = { prefix = "fuck" }
      })
      vim.keymap.set("x", "S", "sa", { remap = true })
    end
  }

  use {
    "aznhe21/actions-preview.nvim",
    config = function()
      vim.keymap.set('n', '<space>ca', require('actions-preview').code_actions)
    end
  }

  use {
    -- "felipejz/i18n-menu.nvim",
    "colorfulfool/i18n-menu.nvim",
    branch = "feature/function-patterns-config",
    requires = {
      "smjonas/snippet-converter.nvim",
    },
    config = function()
      require("i18n-menu").setup()
      vim.keymap.set("n", "<leader>ii", ":TranslateMenu<CR>")
    end,
  }

  use "rafamadriz/friendly-snippets"

  use {
    "saghen/blink.cmp",
    tag = "v0.11.0",
    config = function()
      require("blink.cmp").setup({
        keymap = {
          preset = 'default',
          ['<CR>'] = { 'accept', 'fallback' },
          ['<Up>'] = { 'select_prev', 'fallback' },
          ['<Down>'] = { 'select_next', 'fallback' },
          cmdline = {
            preset = 'enter',
            ['<Tab>'] = { 'show', 'snippet_forward', 'fallback' },
          }
        },
        completion = {
          menu = { auto_show = function(ctx) return ctx.mode ~= 'cmdline' end }
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono'
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
          cmdline = {},
          providers = {
            lsp = {
              fallbacks = {},
              enabled = function()
                for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                  if client.name == 'tailwindcss' then
                    return true
                  end
                end
                local node = vim.treesitter.get_node()
                while node do
                  if node:type() == 'string' or node:type() == 'string_content' or node:type() == 'string_fragment' or node:type() == 'template_string' then
                    return false
                  end
                  node = node:parent()
                end
                return true
              end,
            },
            path = { fallbacks = {} },
            buffer = { score_offset = -3 },
          },
        },
        signature = { enabled = false }
      })
    end,
  }

  use {
    "brenton-leighton/multiple-cursors.nvim",
    config = function()
      require("multiple-cursors").setup()

      vim.keymap.set({ "n", "x" }, "<space>a", "<Cmd>MultipleCursorsAddJumpNextMatch<CR>")
      vim.keymap.set({ "v" }, "<space>a", "<Cmd>MultipleCursorsAddVisualArea<CR>")
      vim.keymap.set({ "n", "x" }, "<space>A", "<Cmd>MultipleCursorsJumpNextMatch<CR>")
    end
  }

  use {
    "napmn/react-extract.nvim",
    config = function()
      require("react-extract").setup()

      vim.api.nvim_create_user_command("ReactExtract", require("react-extract").extract_to_new_file, {})
      vim.api.nvim_create_user_command("ReactExtractCurrentFile", require("react-extract").extract_to_current_file, {})
      vim.keymap.set({ "v" }, "<space>re", require("react-extract").extract_to_new_file)
      vim.keymap.set({ "v" }, "<space>rc", require("react-extract").extract_to_current_file)
    end
  }

  use {
    "ThePrimeagen/99",
    config = function()
      local _99 = require("99")
      local cwd = vim.uv.cwd()
      local basename = vim.fs.basename(cwd)
      _99.setup({
        model = "opencode/mimo-v2.5-free",
        logger = {
          level = _99.DEBUG,
          path = "/tmp/" .. basename .. ".99.debug",
          print_on_error = true,
        },
      })

      vim.api.nvim_create_user_command("PrimeVisual", function() _99.visual() end, { range = true })
      vim.api.nvim_create_user_command("PrimeFill", function() _99.fill_in_function() end, {})
      vim.api.nvim_create_user_command("PrimeStop", function() _99.stop_all_requests() end, {})

      vim.keymap.set("v", "<space>pv", function() _99.visual() end)
      vim.keymap.set("n", "<space>pf", function() _99.fill_in_function() end)
      vim.keymap.set("n", "<space>ps", function() _99.stop_all_requests() end)
    end,
  }

  use {
    "folke/ts-comments.nvim",
    config = function()
      require("ts-comments").setup()
    end
  }

  use {
    "m4xshen/autoclose.nvim",
    config = function()
      require("autoclose").setup()
    end
  }

  use {
    'dmmulroy/tsc.nvim',
    config = function()
      require('tsc').setup()
    end,
  }

  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
