return {
  "xiyaowong/transparent.nvim",
  lazy = false, -- Загружаем сразу при старте
  config = function()
    require("transparent").setup({
      -- Группы подсветки, которые нужно сделать прозрачными
      extra_groups = {
        "NormalFloat", -- Плавающие окна
        "NvimTreeNormal", -- Если используете NvimTree
        "NeoTreeNormal", -- Для дефолтного Neo-tree в LazyVim
        "NeoTreeNormalNC",
        "BufferLineBackground", -- Панель вкладок сверху
        "BufferLineFill",
      },
    })
    -- Автоматически включаем прозрачность при запуске
    vim.cmd("TransparentEnable")
  end,
}
