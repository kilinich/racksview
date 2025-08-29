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
    return get_cmd_output("uptime -p")
end

local function get_cpu_temp()
    return get_cmd_output("vcgencmd measure_temp") .. " " .. get_cmd_output("vcgencmd get_throttled")
end

local function get_radio_status()
    local output = get_cmd_output("rfkill list all")
    if output == "" then
        return "disabled"
    end
    return output
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

local function get_disk_usage(folder)
    local line = get_cmd_output("df -h " .. folder .. " | tail -n 1")
    local total, used = line:match("^%S+%s+(%S+)%s+(%S+)")
    if total and used then
        return string.format("%s GB / %s GB", used, total)
    end
    return "N/A"
end

local function get_ip_address()
    return get_cmd_output("hostname -I")
end

local function get_CPU_usage()
    return get_cmd_output("cat /proc/loadavg")
end

local function get_service_status(name)
    local status = get_cmd_output("systemctl is-active " .. name)
    local uptime = get_cmd_output("systemctl show -p ActiveEnterTimestamp " .. name)
    uptime = uptime:match("ActiveEnterTimestamp=(.*)")
    return status, uptime or "N/A"
end

local function get_motion_status(flag, unflag, dump)
    local result = ""
    local f = io.open(flag, "r")
    if f then
        result = f:read("*a")
        f:close()
    else
        local f_dump = io.open(dump, "r")
        if f_dump then
            local dump_content = f_dump:read("*a")
            f_dump:close()
            result = "monitoring" .. dump_content
        else
            result = "no data"
        end
    end

    local f2 = io.open(unflag, "r")
    if f2 then
        local unflag_content = f2:read("*a")
        f2:close()
        result = result .. "\n" .. unflag_content
    end

    return result
end

local function plain_status_dual()
    local lines = {}
    table.insert(lines, "Motion-front:")
    table.insert(lines, get_motion_status("/opt/racksview/var/motion-front.flg", "/opt/racksview/var/no-motion-front.flg", "/dev/shm/mdetector-front.txt"))
    table.insert(lines, "")
    table.insert(lines, "Motion-back:")
    table.insert(lines, get_motion_status("/opt/racksview/var/motion-back.flg", "/opt/racksview/var/no-motion-back.flg", "/dev/shm/mdetector-back.txt"))
    table.insert(lines, "")
    table.insert(lines, "Services Status:")
    local services = {
        "gstreamer-front.service",
        "mdetector-front.service",
        "vrecorder-front.service",
        "gstreamer-back.service",
        "mdetector-back.service",
        "vrecorder-back.service"
    }
    for _, svc in ipairs(services) do
        local status, uptime = get_service_status(svc)
        table.insert(lines, string.format("%s: %s, %s", svc, status, uptime))
    end
    table.insert(lines, "")
    table.insert(lines, "Hostname: " .. get_hostname())
    table.insert(lines, "IP Address: " .. get_ip_address())
    table.insert(lines, "OS: " .. get_os_version())
    table.insert(lines, "Kernel: " .. get_kernel_version())
    table.insert(lines, "Uptime: " .. get_uptime())
    table.insert(lines, "CPU Load: " .. get_CPU_usage())
    table.insert(lines, "CPU Temp: " .. get_cpu_temp())
    table.insert(lines, "RAM Used: " .. get_ram_usage())
    table.insert(lines, "Main storage Used: " .. get_disk_usage("/opt/racksview"))
    table.insert(lines, "Video storage Used: " .. get_disk_usage("/opt/racksview/var/video"))
    table.insert(lines, "")
    table.insert(lines, "Radio Status: ")
    table.insert(lines, get_radio_status())
    return table.concat(lines, "\n")
end

local function plain_status_single()
    local lines = {}
    table.insert(lines, "Motion:")
    table.insert(lines, get_motion_status("/opt/racksview/var/motion-front.flg","/opt/racksview/var/no-motion-front.flg", "/dev/shm/mdetector-front.txt"))
    table.insert(lines, "")
    table.insert(lines, "Services Status:")
    local services = {
        "gstreamer-front.service",
        "mdetector-front.service",
        "vrecorder-front.service"
    }
    for _, svc in ipairs(services) do
        local status, uptime = get_service_status(svc)
        table.insert(lines, string.format("%s: %s, %s", svc, status, uptime))
    end
    table.insert(lines, "")
    table.insert(lines, "Hostname: " .. get_hostname())
    table.insert(lines, "IP Address: " .. get_ip_address())
    table.insert(lines, "OS: " .. get_os_version())
    table.insert(lines, "Kernel: " .. get_kernel_version())
    table.insert(lines, "Uptime: " .. get_uptime())
    table.insert(lines, "CPU Load: " .. get_CPU_usage())
    table.insert(lines, "CPU Temp: " .. get_cpu_temp())
    table.insert(lines, "RAM Used: " .. get_ram_usage())
    table.insert(lines, "Main storage Used: " .. get_disk_usage("/opt/racksview"))
    table.insert(lines, "Video storage Used: " .. get_disk_usage("/opt/racksview/var/video"))
    table.insert(lines, "")
    table.insert(lines, "Radio Status: ")
    table.insert(lines, get_radio_status())
    return table.concat(lines, "\n")
end

return {
    plain_status_dual = plain_status_dual,
    plain_status_single = plain_status_single
}