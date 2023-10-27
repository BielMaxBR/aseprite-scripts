do
    local image = app.activeCel.image
    local copy = image:clone()

    local x = 13
    local y = 13

    local center = 64
    local rx = center + x
    local ry = center + y
    copy:drawPixel(rx, ry, app.fgColor)
    for i = 1, 256 do
        cos = math.cos(math.pi/128 * i)
        sin = math.sin(math.pi/128 * i)
        local newx = x * cos - y * sin
        local newy = x * sin + y * cos
        copy:drawPixel(math.floor(newx + center), math.floor(newy + center), app.bgColor)
    end
    app.activeCel.image:drawImage(copy)
end