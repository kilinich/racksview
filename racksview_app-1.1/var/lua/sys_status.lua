local function get_cmd_output(cmd)
    local f = io.popen(cmd)
    if not f then return "N/A" end
    local res = f:read("*a")
    f:close()
    return (res:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function get_hostname()
    return get_cmd_output("uname -n")
end

local function get_os_version()
    return get_cmd_output("cat /etc/os-release | grep PRETTY_NAME | cut -d '\"' -f2")
end

local function get_kernel_version()
    return get_cmd_output("uname -r")
end

local function get_uptime()
    local uptime_seconds = get_cmd_output("awk '{print int($1)}' /proc/uptime")
    local seconds = tonumber(uptime_seconds)
    if not seconds then return "N/A" end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    return string.format("%d days, %d hours, %d minutes", days, hours, minutes)
end

local function get_cpu_temp()
    local temp = get_cmd_output("cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null")
    if temp ~= "" and tonumber(temp) then
        return string.format("%.1f °C", tonumber(temp)/1000)
    end
    return "N/A"
end

local function get_ram_usage()
    local meminfo = {}
    for line in io.lines("/proc/meminfo") do
        local k, v = line:match("^(%w+):%s+(%d+)")
        if k and v then meminfo[k] = tonumber(v) end
    end
    if meminfo.MemTotal and meminfo.MemAvailable then
        local used = meminfo.MemTotal - meminfo.MemAvailable
        return string.format("%.1f MB / %.1f MB", used/1024, meminfo.MemTotal/1024)
    end
    return "N/A"
end

local function get_disk_usage(device)
    device = device or "/dev/sda"
    local line = get_cmd_output("df -h | grep '^" .. device .. "' | head -1")
    if line == "" then
        return "N/A"
    end
    local total, used = line:match("^%S+%s+(%S+)%s+(%S+)")
    if total and used then
        return string.format("%s GB / %s GB", used, total)
    end
    return "N/A"
end

local function get_ip_address()
    local ip = get_cmd_output("hostname -I | awk '{print $1}'")
    return ip ~= "" and ip or "N/A"
end

local function get_service_status(name)
    local status = get_cmd_output("systemctl is-active " .. name)
    local uptime = get_cmd_output("systemctl show -p ActiveEnterTimestamp " .. name)
    uptime = uptime:match("ActiveEnterTimestamp=(.*)")
    return status, uptime or "N/A"
end

local function plain_status()
    local lines = {}
    table.insert(lines, "Hostname: " .. get_hostname())
    table.insert(lines, "IP Address: " .. get_ip_address())
    table.insert(lines, "OS: " .. get_os_version())
    table.insert(lines, "Kernel: " .. get_kernel_version())
    table.insert(lines, "Uptime: " .. get_uptime())
    table.insert(lines, "CPU Temp: " .. get_cpu_temp())
    table.insert(lines, "RAM Used: " .. get_ram_usage())
    table.insert(lines, "Disk Used: " .. get_disk_usage("/dev/mmcblk0p2"))
    table.insert(lines, "USB Used: " .. get_disk_usage("/dev/sda1"))
    table.insert(lines, "")
    table.insert(lines, "Services Status:")
    local services = {
        "gstreamer-front.service",
        "gstreamer-back.service",
        "mdetector-front.service",
        "mdetector-back.service"
    }
    for _, svc in ipairs(services) do
        local status, uptime = get_service_status(svc)
        table.insert(lines, string.format("%s: %s, %s", svc, status, uptime))
    end
    return table.concat(lines, "\n")
end

return {
    plain_status = plain_status
}