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

function M.create_term()
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

function M.test_ui()
	vim.ui.input({
		prompt = "Enter your name: ",
	}, function(input)
		if input then
			vim.notify("Hello, " .. input, vim.log.levels.INFO)
			-- vim.api.nvim_echo({ { "Hello" } }, false, {})
		end
	end)
	local options = { "Red", "Green", "Blue" }
	vim.ui.select(options, { prompt = "Choose your favorite color:" }, function(choice)
		if choice then
			print("Your favorite color is " .. choice)
		else
			print("No color was chosen.")
		end
	end)
end

local function parse_cmake_output(output)
	local errors = {}
	for _, line in ipairs(output) do
		-- Simple pattern matching to find errors (customize as needed)
		local file, lineno, colno, msg = line:match("(.+):(%d+):(%d+):? (.+)")
		if file and lineno and msg then
			table.insert(errors, {
				filename = file,
				lnum = tonumber(lineno),
				col = tonumber(colno),
				text = msg,
			})
		end
	end
	return errors
end

function M.run_cmake()
	local output = {}
	local bufnr = vim.api.nvim_create_buf(false, true)
	local term_id = vim.api.nvim_open_term(bufnr, {})
	vim.api.nvim_open_win(bufnr, true, { relative = "editor", width = 80, height = 20, row = 10, col = 10 })
	local cmake_job = vim.fn.jobstart("cmake -S . -B build; cmake --build build -j 8", {
		on_stdout = function(_, data)
			for _, line in ipairs(data) do
				table.insert(output, line)
				vim.api.nvim_chan_send(term_id, line .. "\n")
			end
		end,
		on_stderr = function(_, data)
			for _, line in ipairs(data) do
				table.insert(output, line)
				vim.api.nvim_chan_send(term_id, line .. "\n")
			end
		end,
		on_exit = function()
			local errors = parse_cmake_output(output)
			if #errors > 0 then
				vim.notify("error occurs", vim.log.levels.ERROR, {})
				vim.fn.setqflist(errors)
			else
				vim.notify("cmake done", vim.log.levels.INFO, {})
			end
		end,
		stdout_buffered = true,
		stderr_buffered = true,
	})

	if cmake_job <= 0 then
		print("Failed to start cmake.")
	end
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

vim.keymap.set("n", "<leader>t", M.run_cmake, { desc = "run neovim plugin test" })

return M
