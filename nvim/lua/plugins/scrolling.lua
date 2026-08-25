return {
  {
    "karb94/neoscroll.nvim",
    config = function()
      local neoscroll = require("neoscroll")
      
      neoscroll.setup({
        hide_cursor = false,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
      })

      local modes = { "n", "v", "x" }
      
      vim.keymap.set(modes, "<ScrollWheelUp>", function()
        neoscroll.scroll(-3, { move_cursor = false, duration = 70, easing = "quadratic" })
      end)
      
      vim.keymap.set(modes, "<ScrollWheelDown>", function()
        neoscroll.scroll(3, { move_cursor = false, duration = 70, easing = "quadratic" })
      end)
    end,
  },
}
