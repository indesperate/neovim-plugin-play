local M = {}

local function run_and_echo(term_id, command)
	vim.api.nvim_chan_send(term_id, "start run " .. command .. "\n\n")
	vim.fn.jobstart(command, {
		on_stdout = function(_, data)
			if data then
				local std_output = table.concat(data, "\n") .. "\n"
				if std_output ~= "" then
					vim.api.nvim_chan_send(term_id, std_output)
				end
			end
		end,
		on_stderr = function(_, data)
			if data then
				local stderr_output = table.concat(data, "\n")
				if stderr_output ~= "" then
					vim.api.nvim_err_writeln(stderr_output)
				end
			end
		end,
		stdout_buffered = true,
		stderr_buffered = true,
	})
end

function M.some_function()
	local bufnr = vim.api.nvim_create_buf(false, true)
	local term_id = vim.api.nvim_open_term(bufnr, {})
	local win_id =
		vim.api.nvim_open_win(bufnr, true, { relative = "editor", width = 80, height = 20, row = 10, col = 10 })
	run_and_echo(term_id, "echo hello")
	run_and_echo(term_id, "ls -al")
	run_and_echo(term_id, "lc -al")
	-- vim.fn.termopen("bash")
	vim.keymap.set("n", "q", function()
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end, { desc = "run neovim plugin test", buffer = bufnr })
	vim.api.nvim_create_autocmd("WinLeave", {
		buffer = bufnr,
		callback = function()
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end,
	})
end

vim.keymap.set("n", "<leader>t", M.some_function, { desc = "run neovim plugin test" })

return M
