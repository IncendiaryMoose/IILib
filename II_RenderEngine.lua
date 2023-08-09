require("II_MathHelpers")
require("II_SmallVectorMath")

---@section setDrawColor
currentColor = {0, 0, 0}
setDrawColor = function (color)
    if currentColor[1] ~= color[1] or currentColor[2] ~= color[2] or currentColor[3] ~= color[3] then
        currentColor[1] = color[1]
        currentColor[2] = color[2]
        currentColor[3] = color[3]
        screen.setColor(color[1], color[2], color[3])
    end
end
---@endsection

---@section inRect
function inRect(x, y, rectX, rectY, rectW, rectH)
	return x >= rectX and y >= rectY and x <= rectX + rectW and y <= rectY + rectH
end
---@endsection

---@section newButton
function newButton(x, y, w, h, boxColor, textColor, text, boxPushColor, textPushColor)
    return {
        x = x,
        y = y,
        w = w,
        h = h,
        boxColor = boxColor,
        textColor = textColor,
        text = text,
        boxPushColor = boxPushColor or boxColor,
        textPushColor = textPushColor or textColor,
        pressed = false,
        poked = false,
        updateTick = function (self, clicked, wasClicked, clickX, clickY)
            self.poked = not self.pressed
            if clicked and not wasClicked and inRect(clickX, clickY, self.x, self.y, self.w - 1, self.h - 1) then
                self.pressed = not self.pressed
            end
            self.poked = self.poked and self.pressed
        end,
        updateDraw = function (self)
            local boxColorToDraw, textColorToDraw = self.boxColor, self.textColor
            if self.pressed then
                boxColorToDraw = self.boxPushColor
                textColorToDraw = self.textPushColor
            end
            setDrawColor(boxColorToDraw)
            screen.drawRectF(self.x, self.y + 1, self.w, self.h - 2)
            screen.drawRectF(self.x + 1, self.y, self.w - 2, self.h)
            setDrawColor(textColorToDraw)
            screen.drawTextBox(self.x, self.y, self.w, self.h, self.text, 0, 0)
        end
    }
end
---@endsection

---@section newPulseButton
function newPulseButton(x, y, w, h, boxColor, textColor, text, boxPushColor, textPushColor)
    return {
        x = x,
        y = y,
        w = w,
        h = h,
        boxColor = boxColor,
        textColor = textColor,
        text = text,
        boxPushColor = boxPushColor or boxColor,
        textPushColor = textPushColor or textColor,
        pressed = false,
        updateTick = function (self, clicked, wasClicked, clickX, clickY)
            self.pressed = clicked and not wasClicked and inRect(clickX, clickY, self.x, self.y, self.w - 1, self.h - 1)
        end,
        updateDraw = function (self)
            local boxColorToDraw, textColorToDraw = self.boxColor, self.textColor
            if self.pressed then
                boxColorToDraw = self.boxPushColor
                textColorToDraw = self.textPushColor
            end
            setDrawColor(boxColorToDraw)
            screen.drawRectF(self.x, self.y + 1, self.w, self.h - 2)
            screen.drawRectF(self.x + 1, self.y, self.w - 2, self.h)
            setDrawColor(textColorToDraw)
            screen.drawTextBox(self.x, self.y, self.w, self.h, self.text, 0, 0)
        end
    }
end
---@endsection

---@section newSlider
function newSlider(x, y, w, h, sW, tW, sliderColor, textColor, text, onColor, offColor, slider)
    return {
        x = x,
        y = y,
        x1 = x + tW - 1,
        w = w - 1,
        h = h - 1,
        sW = sW,
        tW = tW,
        sliderColor = sliderColor,
        textColor = textColor,
        text = text,
        onColor = onColor,
        offColor = offColor,
        pressed = false,
        onPercent = 0,
        stateChange = false,
        slider = slider,
        updateTick = function (self, clicked, wasClicked, clickX, clickY)
            local priorState = self.pressed
            if self.slider then
                self.pressed = clicked and inRect(clickX, clickY, self.x1, self.y, self.w, self.h)
            elseif clicked and inRect(clickX, clickY, self.x1, self.y, self.w, self.h) and not wasClicked then
                self.pressed = not self.pressed
            end
            self.stateChange = priorState ~= self.pressed
            self.onPercent = clamp((self.slider and (self.pressed and ((clickX - self.x1 - self.sW/2)/(self.w-3)) or self.onPercent)) or (self.pressed and self.onPercent + 0.1) or (self.onPercent - 0.1), 0, 1)
        end,
        updateDraw = function (self)
            setDrawColor(whiteOn)
            screen.drawRect(self.x1, self.y + 2, self.w, self.h - 4)
            setDrawColor(self.offColor)
            screen.drawRectF(self.x1 + 1, self.y + 3, self.w - 1, self.h - 5)

            setDrawColor(self.onColor)
            screen.drawRectF(self.x1 + 1, self.y + 3, self.onPercent*(self.w - self.sW - 1), self.h - 5)

            setDrawColor(self.textColor)
            screen.drawTextBox(self.x, self.y + 1, self.tW, self.h, self.text, 0, 0)

            setDrawColor(self.sliderColor)
            screen.drawRectF(self.x1 + 1 + self.onPercent*(self.w - self.sW - 1), self.y, self.sW, self.h + 1)
        end
    }
end
---@endsection

---@section newTriangle
newTriangle = function (a, b, c, color)
    return {
        {a[1], a[2]},
        {b[1], b[2]},
        {c[1], c[2]},
        (a[3] + b[3] + c[3]) / 3,
        color
    }
end
---@endsection

---@section drawTri
drawTri = function (tri)
    setDrawColor(tri[5])
    screen.drawTriangleF(tri[1][1], tri[1][2], tri[2][1], tri[2][2], tri[3][1], tri[3][2])
end
---@endsection

---@section drawArrow
function drawArrow(x, y, size, angle)
    x = x + size/2 * math.cos(angle)
    y = y - size/2 * math.sin(angle)
    local a1, a2 = angle + 2.8, angle - 2.8
    screen.drawTriangleF(x, y, x + size*math.cos(a1), y - size*math.sin(a1), x + size*math.cos(a2), y - size*math.sin(a2))
end
---@endsection

---@section worldToScreenPoint
fov = property.getNumber("FOV")
h = 160
w = 288
monitor = {meterToPixelW = w/2.25, meterToPixelH = h/1.25, pixelW = w, pixelH = h, meterW = 2.25, meterH = 1.25, offsetX = 0, offsetY = 0, centerW = w/2-1, centerH = h/2, ratio = w/h}
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
---@endsection