vim.api.nvim_create_user_command("Slider", function()
  package.loaded["slider"] = nil
  require("slider").start_presentation()
end, {})
