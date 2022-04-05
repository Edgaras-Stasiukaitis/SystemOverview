local M = {}

function File_exists(name)
    local f = io.open(name,"r")
    if f ~= nil then io.close(f) return true else return false end
end

function M.create_file()
    local filename = "/etc/config/view"
    if (File_exists(filename)) then return end
    local file = io.open(filename, "w")
    file:close()

    return { ok = true, message = "file created"}
end

return M
