-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
-- vim.keymap.set({ "i", "c", "t" }, "jk", "<Esc>", { desc = "jk exit" })
vim.keymap.set({ "i", "c", "t", "v" }, "<C-c>", "<Esc>")
vim.keymap.set({ "n" }, "<C-c>", "<cmd>nohlsearch<CR>")
