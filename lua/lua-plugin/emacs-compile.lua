local M = {}

M.parse_buffer = function()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local quckfix_list = {}

	for _, line in ipairs(lines) do
		local file, lnum, col, msg = line:match("(.+):(%d+):(%d+) *(.*)")
		if file and lnum and col then
			table.insert(quckfix_list, {
				filename = file,
				lnum = tonumber(lnum),
				col = tonumber(col),
				text = msg,
			})
		end
	end

	if #quckfix_list > 0 then
		vim.notify("read from the buffer, pop it to the quckfix_list")
		vim.fn.setqflist(quckfix_list)
	else
		vim.notify("no list found, abort pop")
	end
end

vim.keymap.set("n", "<leader>m", M.parse_buffer, { desc = "emacs compile mode migration" })

return M
