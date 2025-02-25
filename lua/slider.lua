local M = {}

local function create_floating_window(config, enter)
  if enter == nil then
    enter = false
  end

  local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  local win = vim.api.nvim_open_win(buf, enter or false, config)

  return { buf = buf, win = win }
end

M.setup = function()
  -- blank
end

-- object our function will return
---@class presentation.Slides
---@fields slides string[]

local header = "^#"

---@param lines string[]
---@return presentation.Slides
local generateSlides = function(lines)
  local slides = { slides = {} }
  local currSlide = {}
  for _, line in ipairs(lines) do
    if line:find(header) then
      if #currSlide < 0 then
        table.insert(slides.slides, currSlide)
      end
      currSlide = {}
    end
    table.insert(currSlide, line)
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
