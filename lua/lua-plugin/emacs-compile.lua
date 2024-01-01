local M = {}

local parse_lines = function(start_pos, end_pos)
	local lines = vim.api.nvim_buf_get_lines(0, start_pos, end_pos, false)
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

function M.parse_buffer()
	parse_lines(0, -1)
end

function M.parse_selected()
	-- get line number and decrease it by one
	-- because the table is {line, col} and it start at 1
	local start_pos = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
	local end_pos = vim.api.nvim_buf_get_mark(0, ">")[1]
	parse_lines(start_pos, end_pos)
end

vim.keymap.set("n", "<leader>m", M.parse_buffer, { desc = "emacs compile mode migration" })
vim.keymap.set("v", "<leader>m", M.parse_selected, { desc = "emacs compile mode migration" })

return M
