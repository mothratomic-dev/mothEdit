-- main -------------------------------------------------------------------- --
local utf8 = require("utf8")
--
-- settings -------------------------------------------------------------------
bgColor             = {0.18, 0.20, 0.22} -- background color
fontColor           = {1, 1, 1, 1}       -- font color
cursorColor         = {1, 1, 1, 1}       -- cursor color
sizeFont            = 14                 -- font size
textPositionX       = 10                 -- margin > text position x
textPositionY       = 5                  -- text position y
lineNumberColor     = {0.4, 0.4, 0.4}    -- line number color
marginColor         = {0.4, 0.3, 0.4}    -- margin color
marginPositionX     = 10                 -- margin move position
marginPositionFixe  = 30                 -- margin fixe position
marginMove          = true               -- margin move true/false

--
-- load -----------------------------------------------------------------------
function love.load()
    mainFont = love.graphics.newFont(
    "fonts/JetBrainsMono-Regular.ttf", sizeFont)

    lines        = {""}
    cursorLine   = 1
    cursorColumn = 1

    love.keyboard.setKeyRepeat(true) -- repeat key
end
--
-- text input -----------------------------------------------------------------
function love.textinput(t)
    local line     = lines[cursorLine]
    local position = utf8.offset(line, cursorColumn) or #line + 1

    local before   = line:sub(1, position - 1)
    local after    = line:sub(position)

    lines[cursorLine] = before .. t .. after
    cursorColumn      = cursorColumn + utf8.len(t)
end
--
-- key input ------------------------------------------------------------------
function love.keypressed(key)
    -- fullscreen
    if key == "f1" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end

    -- up
    if key == "up" and cursorLine > 1 then
        cursorLine   = cursorLine - 1
        cursorColumn = math.min(
            cursorColumn,
            utf8.len(lines[cursorLine]) + 1)
    end

    -- down
    if key == "down" and cursorLine < #lines then
        cursorLine   = cursorLine + 1
        cursorColumn = math.min(
            cursorColumn,
            utf8.len(lines[cursorLine]) + 1)
    end

    -- left
    if key == "left" and cursorColumn > 1 then
        cursorColumn = cursorColumn - 1
    end

    -- right
    if key == "right" and
        cursorColumn <= utf8.len(lines[cursorLine]) then
            cursorColumn = cursorColumn + 1
    end

    -- return
    if key == "return" then
        local line     = lines[cursorLine]
        local position = utf8.offset(line, cursorColumn) or #line + 1

        local before = line:sub(1, position - 1)
        local after  = line:sub(position)

        lines[cursorLine] = before
        table.insert(lines, cursorLine + 1, after)

        cursorLine   = cursorLine + 1
        cursorColumn = 1
    end

    -- backspace
    if key == "backspace" then
        local line = lines[cursorLine]

        if cursorColumn > 1 then
            local start  = utf8.offset(line, cursorColumn - 1)
            local finish = utf8.offset(line, cursorColumn) or #line + 1

            lines[cursorLine] = line:sub(1, start - 1) .. line:sub(finish)
            cursorColumn      = cursorColumn - 1

        elseif cursorLine > 1 then
            local previous = lines[cursorLine - 1]

            cursorColumn          = utf8.len(previous) + 1
            lines[cursorLine - 1] = previous .. line

            table.remove(lines, cursorLine)
            cursorLine = cursorLine - 1
        end
    end

    -- tab
    if key == "tab" then
        local line     = lines[cursorLine]
        local position = utf8.offset(line, cursorColumn) or #line + 1

        local before = line:sub(1, position - 1)
        local after  = line:sub(position)

        lines[cursorLine] = before .. "    " .. after
        cursorColumn      = cursorColumn + 4
    end
end
--
-- draw -----------------------------------------------------------------------
function love.draw()
    love.graphics.setBackgroundColor(bgColor)
    love.graphics.setFont(mainFont)
    love.graphics.setColor(fontColor)

    -- margin position
    local marginWidth = marginPositionFixe
    if marginMove then
        marginWidth   = mainFont:getWidth(tostring(#lines)) + 10
    end

    local textX = marginPositionX + marginWidth + textPositionX

    -- margin
    love.graphics.setColor(marginColor)
    love.graphics.line(
        marginPositionX + marginWidth, 0,
        marginPositionX + marginWidth, love.graphics.getHeight())

    -- text draw
    for i = 1, #lines do
        local y = textPositionY + (i - 1) * mainFont:getHeight()

        -- line number
        love.graphics.setColor(lineNumberColor)
        local lineNumber  = tostring(i)
        local lineNumberX = marginPositionX +
            marginWidth - 10 - mainFont:getWidth(lineNumber)

        love.graphics.print(lineNumber, lineNumberX, y)

        -- text
        love.graphics.setColor(fontColor)
        love.graphics.print(lines[i], textX, y)
    end

    -- cursor position x
    local line     = lines[cursorLine]
    local position = utf8.offset(line, cursorColumn) or #line + 1
    local cursorX = textX + mainFont:getWidth(line:sub(1, position - 1))

    -- cursor position y
    local cursorY  = textPositionY + (
        cursorLine - 1) * mainFont:getHeight()

    -- cursor draw
    love.graphics.setColor(cursorColor)
    love.graphics.rectangle("fill", cursorX, cursorY,
    mainFont:getWidth("m"), mainFont:getHeight())
end
--
