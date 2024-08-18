local M =  {}

M.config = {
    enabled_on_start = true,
    truncate_str = "...",
    line_start_length = 8,
    temporary_toggle_dur = 2000,
    hilight_group = "Comment"
}

-- some vars for readability
local current_buffer = vim.api.nvim_get_current_buf()
local augroup = vim.api.nvim_create_augroup('VirtualText', { clear = true })
local virt_text_ns = vim.api.nvim_create_namespace('virtual_text_namespace')

function M.setup(opts)
    -- if different values are passed to user config, use those instead
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})

    -- Function to display virtual text
    local function truncate_line()

        -- clear existing virtual text
        vim.api.nvim_buf_clear_namespace(current_buffer, virt_text_ns, 0, -1)

        -- get first and last lines visible on screen
        local start_line = vim.fn.line('w0')
        local end_line = vim.fn.line('w$')

        for line = start_line - 1, end_line - 1 do
            -- store line content in var
            local line_content = vim.api.nvim_buf_get_lines(current_buffer, line, line + 1, false)[1]

            -- if line content isn't nil or empty (will still show truncate char if line has spaces)
            if line_content and line_content ~= "" then

                local function hidden_start(line_number)
                    -- compare first non white space char with window view
                    -- and return true if it is hidden
                    local view = vim.fn.winsaveview()
                    local first_char_col = vim.fn.indent(line_number)
                    return first_char_col < view.leftcol
                end

                local line_number = line + 1 -- i have no idea why i need to adjust for index here

                if hidden_start(line_number) then
                    -- Get the first n non whitespace characters, handle empty or whitespace-only lines
                    local virtual_text = line_content:match("^%s*(%S.-)%s*$") or ""
                    -- trim the string to the given char count
                    local line_start_length = M.config.line_start_length
                    virtual_text = virtual_text:sub(1, line_start_length)
                    -- adds the truncate characters, if given
                    local truncate_str = M.config.truncate_str
                    virtual_text = virtual_text .. truncate_str

                    -- Set the virtual text on the left side
                    local hilight_group = M.config.hilight_group
                    vim.api.nvim_buf_set_extmark(current_buffer, virt_text_ns, line, 0, {
                        virt_text = { { virtual_text, hilight_group } },
                        hl_mode = "replace",
                        virt_text_pos = "overlay",
                    })
                end
            end
        end
    end

    -- if enabled, trigger autocmd
    local function create_ac()
        -- this hopefully fixes the first install bug, without stopping the thing
        -- this is a bodge because while it will prevent plugin from breaking if lazy is open, it also won't work in normal buffers
        if _G.is_truncate_enabled and current_buffer ~= 2 then
            vim.api.nvim_create_autocmd({ "CursorMoved", "WinScrolled" }, {
                group = augroup,
                callback = truncate_line,
            })
        end
    end

    function M.ToggleTruncate()
        if _G.is_truncate_enabled then
            _G.is_truncate_enabled = false
            print('TruncateLine disabled')
            vim.api.nvim_buf_clear_namespace(current_buffer, virt_text_ns, 0, -1)
            vim.cmd[[autocmd! VirtualText]]
        else
            _G.is_truncate_enabled = true
            create_ac()
            truncate_line()
            print('TruncateLine enabled')
        end
    end

    -- quickly turn on/off
    function M.TemporaryToggle()
        M.ToggleTruncate()
        local temporary_toggle_dur = M.config.temporary_toggle_dur
        -- timer to return to previous on/off state
        vim.defer_fn(M.ToggleTruncate, temporary_toggle_dur)
    end

    -- enable on start?
    if M.config.enabled_on_start then
        _G.is_truncate_enabled = true
        create_ac()
    end

end

return M

