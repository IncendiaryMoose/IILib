require("II_MathHelpers")
require("II_SmallVectorMath")

fov = property.getNumber("FOV")
h = 160
w = 288
monitor = {meterToPixelW = w/2.25, meterToPixelH = h/1.25, pixelW = w, pixelH = h, meterW = 2.25, meterH = 1.25, offsetX = 0, offsetY = 0, centerW = w/2-1, centerH = h/2, ratio = w/h}

drawTri = function (tri)
    if tri.p1 and tri.p2 and tri.p3 then
        screen.drawTriangleF(tri.p1.x, tri.p1.y, tri.p2.x, tri.p2.y, tri.p3.x, tri.p3.y)
    end
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