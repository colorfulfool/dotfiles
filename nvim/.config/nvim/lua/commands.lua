local function kebab_to_pascal_case(str)
  return str:gsub("-(%l)", string.upper):gsub("^(%l)", string.upper):gsub("-", "")
end

local function pascal_to_kebab_case(str)
  return str:gsub("(%u)", "-%1"):lower():gsub("^-", "")
end

local function jump_between_story_and_component()
  local source_name, source_extension = vim.fn.expand("%:t"):match("^([^.]+)%.(.+)$")
  local target_filename = source_extension == "tsx"
      and kebab_to_pascal_case(source_name) .. ".stories.tsx"
      or pascal_to_kebab_case(source_name) .. ".tsx"
  vim.cmd("edit src/**/" .. target_filename)
end

vim.api.nvim_create_user_command("JumpToStory", jump_between_story_and_component, {})
vim.api.nvim_create_user_command("JumpToComponent", jump_between_story_and_component, {})

vim.keymap.set('n', '<space>gs', jump_between_story_and_component)

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

vim.keymap.set('v', '<C-S-j>', ":move '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('v', '<C-S-k>', ":move '<-2<CR>gv=gv", { noremap = true, silent = true })
