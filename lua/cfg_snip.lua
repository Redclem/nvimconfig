-- Jump forward
vim.keymap.set({ "i", "s" }, "<C-j>", function()
  if vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
  else
    -- Fall back to normal Tab / indent
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<C-j>", true, false, true),
      "n",
      false
    )
  end
end, { desc = "Jump to next snippet placeholder or Tab" })

-- Jump backward
vim.keymap.set({ "i", "s" }, "<C-k>", function()
  if vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
  else
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<C-k>", true, false, true),
      "n",
      false
    )
  end
end, { desc = "Jump to previous snippet placeholder" })
