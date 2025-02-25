local M = {}

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  -- Calculate the position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Create a buffer
  local buf = vim.api.nvim_create_buf(false, true)

  -- Define window configuration
  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal", -- No borders or extra UI elements
    border = "rounded",
  }

  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

M.setup = function()
  -- blank
end

-- object our function will return
---@class presentation.Slides
---@fields slides string[]

---@param lines string[]
---@return presentation.Slides
local generateSlides = function(lines)
  local slides = { slides = {} }
  local cur = {}
  local header = "^#"

  for _, line in ipairs(lines) do
    if line:find(header) then
      if #cur < 0 then
        table.insert(slides.slides, cur)
      end
      cur = {}
    end
    table.insert(cur, line)
  end
  return slides
end

M.start_presentation = function(opts)
  opts = opts or {}
  opts.bufnr = opts.bufnr or 0

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local parsed = generateSlides(lines)
  local float = create_floating_window()
  local currSlide = 1

  vim.keymap.set("n", "n", function()
    currSlide = math.min(currSlide + 1, #parsed.slides)
    vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[currSlide])
  end, {
    buffer = float.buf,
  })

  vim.keymap.set("n", "p", function()
    currSlide = math.max(currSlide - 1, 1)
    vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[currSlide])
  end, {
    buffer = float.buf,
  })

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(float.win, true)
  end, {
    buffer = float.buf,
  })

  vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[1])
end

return M

--[[
--
Error executing Lua callback: ...samuel/.local/share/nvim/lazy/slider.nvim/lua/slider.lua:87: Invalid 'replacement': Expected Lua table
stack traceback:
	[C]: in function 'nvim_buf_set_lines'
	...samuel/.local/share/nvim/lazy/slider.nvim/lua/slider.lua:87: in function 'start_presentation'
	...amuel/.local/share/nvim/lazy/slider.nvim/plugin/load.lua:3: in function <...amuel/.local/share/nvim/lazy/slider.nvim/plugin/load.lua:1>
```
--
--]]
