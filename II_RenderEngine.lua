require("II_MathHelpers")
require("II_SmallVectorMath")

fov = property.getNumber("FOV")
h = 160
w = 288
monitor = {meterToPixelW = w/2.25, meterToPixelH = h/1.25, pixelW = w, pixelH = h, meterW = 2.25, meterH = 1.25, offsetX = 0, offsetY = 0, centerW = w/2-1, centerH = h/2, ratio = w/h}

currentColor = {0, 0, 0}
setDrawColor = function (color)
    if currentColor[1] ~= color[1] or currentColor[2] ~= color[2] or currentColor[3] ~= color[3] then
        currentColor[1] = color[1]
        currentColor[2] = color[2]
        currentColor[3] = color[3]
        screen.setColor(color[1], color[2], color[3])
    end
end

newTriangle = function (a, b, c, color)
    return {
        {a[1], a[2]},
        {b[1], b[2]},
        {c[1], c[2]},
        (a[3] + b[3] + c[3]) / 3,
        color
    }
end

drawTri = function (tri)
    setDrawColor(tri[5])
    screen.drawTriangleF(tri[1][1], tri[1][2], tri[2][1], tri[2][2], tri[3][1], tri[3][2])
end

worldToScreenPoint = function(cameraLocation, cameraMatrix, points, screenPoints)
    for index, point in ipairs(points) do
        point:setAdd(cameraLocation, -1)
        point:matrixRotate(cameraMatrix)
        local sx = monitor.centerW - (point[2] * (1 / (point[1] + 1)) * monitor.meterToPixelW) -0.5
        local sy = monitor.centerH - (point[3] * (1 / (point[1] + 1)) * monitor.meterToPixelH) +0.5
        local sz = point[1]
        if sz > 0 and sx >= -fov and sx <= w + fov and sy >= -fov and sy <= h + fov then
            screenPoints[#screenPoints + 1] = {
                sx,
                sy,
                sz,
                point:magnitude()
            }
        end
    end
end