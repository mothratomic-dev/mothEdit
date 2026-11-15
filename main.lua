-- main -------------------------------------------------- --
local utf8 = require("utf8")
--
-- settings -------------------------------------------------
bgColor       = {0.2, 0.25, 0.3}   -- background color
fontColor     = {1, 1, 1, 1}       -- font color
cursorColor   = {1, 1, 1, 1}       -- cursor color
sizeFont      = 14                 -- font size
textPositionX = 10                 -- position x text : start
textPositionY = 10                 -- position y text : start
tabSize       = "    "             -- tab size
--
-- load -----------------------------------------------------
function love.load()
    mainFont = love.graphics.newFont(
    "fonts/JetBrainsMono-Regular.ttf", sizeFont)

    lines        = {""}
    cursorLine   = 1
    cursorColumn = 1

    love.keyboard.setKeyRepeat(true) -- repeat key
end
--
-- text input -----------------------------------------------
function love.textinput(t)
    lines[cursorLine] = lines[cursorLine] .. t
end
--
-- key input ------------------------------------------------
function love.keypressed(key)
    -- fullscreen
    if key == "f1" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end

    -- return
    if key == "return" then
        table.insert(lines, "")
        cursorLine = cursorLine + 1
    end

    -- backspace
    if key == "backspace" then
        local line = lines[cursorLine]

        if line ~= "" then
            local position = utf8.offset(line, - 1)
            lines[cursorLine] = line:sub(1, position - 1)

        elseif cursorLine > 1 then
            table.remove(lines, cursorLine)
            cursorLine = cursorLine - 1
        end
    end

    -- tab
    if key == "tab" then
        lines[cursorLine] = lines[cursorLine] .. tabSize
    end
end
--
-- draw -----------------------------------------------------------------
function love.draw()
    love.graphics.setBackgroundColor(bgColor) -- select background color
    love.graphics.setFont(mainFont)           -- select font
    love.graphics.setColor(fontColor)         -- select font color

    -- text input draw
    for i = 1, #lines do
        local x = textPositionX
        local y = textPositionY + (i - 1) * mainFont:getHeight()

        love.graphics.print(lines[i], x, y)
    end

    -- cursor position
    local cursorX = textPositionX + mainFont:getWidth(lines[cursorLine])
    local cursorY = textPositionY + (cursorLine - 1) * mainFont:getHeight()

    -- cursor draw
    love.graphics.setColor(cursorColor)
    love.graphics.rectangle("fill", cursorX, cursorY,
    mainFont:getWidth("m"), mainFont:getHeight())
end
--
