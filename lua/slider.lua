local M = {}

--todo
M.setup = function() end

---@class slider.Slides
---@field slides string[]

---@param lines string[]
---@return slider.Slides
local generateSlides = function(lines)
  local slides = { slides = {} }
  local cur = {}
  local header = "^#"

  for _, line in ipairs(lines) do
    if line:find(header) then
      if #cur > 0 then
        table.insert(slides.slides, cur)
      end
      cur = {}
    end
    table.insert(cur, line)
  end
  return slides
end

-- function for opening a floating window
local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)

  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    -- style = "minimal",
    border = "shadow",
  }

  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

M.start_presentation = function(opts)
  opts = opts or {}
  opts.bufnr = opts.bufnr or 0

  local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
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
