local function stream_mjpeg(port, boundary)
    -- Set HTTP response headers
    ngx.status = 200
    ngx.header.content_type = "multipart/x-mixed-replace; boundary=" .. boundary
    ngx.header["Cache-Control"] = "no-cache"
    ngx.header["Pragma"] = "no-cache"
    ngx.header["Connection"] = "close"

    -- Create and connect TCP socket
    local sock = ngx.socket.tcp()
    sock:settimeout(30000)  -- 30s timeout; adjust as needed
    local ok, err = sock:connect("127.0.0.1", port)
    if not ok then
        ngx.log(ngx.ERR, "Failed to connect to TCP stream on port " .. port .. ": ", err)
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    -- Stream data in chunks with robust error handling
    local count = 0
    local success, loop_err = pcall(function()
        while true do
            count = count + 1
            if count % 1000 == 0 then collectgarbage("collect") end

            local data, recv_err, partial = sock:receive(8192)  -- Efficient buffer size
            local chunk = data or partial
            if chunk then
                local ok, err = ngx.print(chunk)
                if not ok then
                    if err == "closed" or err == "client aborted" then
                        ngx.log(ngx.INFO, "Client closed connection for port " .. port)
                        return
                    else
                        ngx.log(ngx.ERR, "Error printing to client for port " .. port .. ": ", err)
                        return
                    end
                end
                local ok, err = ngx.flush(true)
                if not ok then
                    if err == "closed" or err == "client aborted" then
                        ngx.log(ngx.INFO, "Client closed connection during flush for port " .. port)
                        return
                    else
                        ngx.log(ngx.ERR, "Error flushing to client for port " .. port .. ": ", err)
                        return
                    end
                end
            else
                if recv_err == "closed" then
                    ngx.log(ngx.INFO, "Upstream closed connection for port " .. port)
                    return
                elseif recv_err == "timeout" then
                    ngx.log(ngx.WARN, "Timeout receiving from TCP stream on port " .. port)
                    return
                else
                    ngx.log(ngx.ERR, "Error receiving from TCP stream on port " .. port .. ": ", recv_err)
                    return
                end
            end
        end
    end)

    -- Always clean up
    if sock and sock.close then
        pcall(function() sock:close() end)
    end
    if not success then
        ngx.log(ngx.ERR, "Loop error for port " .. port .. ": ", loop_err)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
end

--[[
Module API:
    stream_mjpeg(port, boundary)
        Streams an MJPEG stream from a local TCP port to the HTTP client.
        Arguments:
            port (number): The TCP port to connect to for the MJPEG stream.
            boundary (string): The boundary string for multipart MJPEG.
        Returns:
            nil. Handles HTTP response directly.
]]
return { stream_mjpeg = stream_mjpeg }