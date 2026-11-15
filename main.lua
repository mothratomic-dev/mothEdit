-- main -------------------------------------------------------------------- --
local utf8 = require("utf8")
--
-- settings -------------------------------------------------------------------
bgColor             = {0.18, 0.20, 0.22} -- background color
-- font
fontColor           = {1, 1, 1, 1}       -- font color
sizeFont            = 14                 -- font size
-- cursor
cursorColor         = {1, 1, 1, 1}       -- cursor color
-- text
textPositionX       = 10                 -- margin > text position x
textPositionY       = 5                  -- text position y
-- margin
lineNumberColor     = {0.4, 0.4, 0.4}    -- line number color
marginColor         = {0.4, 0.3, 0.4}    -- margin color
marginPositionX     = 10                 -- margin move position
marginPositionFixe  = 30                 -- margin fixe position
marginMove          = true               -- margin move true/false
-- scroll
scrollSpeed         = 1                  -- scroll speed /line
--
-- load -----------------------------------------------------------------------
function love.load()
    mainFont = love.graphics.newFont(
    "fonts/JetBrainsMono-Regular.ttf", sizeFont)

    lines        = {""}
    cursorLine   = 1
    cursorColumn = 1
    scrollX      = 0
    scrollY      = 0

    love.keyboard.setKeyRepeat(true) -- repeat key
end
--
-- scroll ---------------------------------------------------------------------
function updateScroll()
    local lineHeight   = mainFont:getHeight()
    local visibleLines = math.max(1, math.floor(
        (love.graphics.getHeight() - textPositionY) / lineHeight))

    if cursorLine <= scrollY then
        scrollY = cursorLine - 1
    end

    if cursorLine > scrollY + visibleLines then
        scrollY = cursorLine - visibleLines
    end

    local marginWidth = marginPositionFixe

    if marginMove then
        marginWidth = mainFont:getWidth(tostring(#lines)) + 10
    end

    local textX     = marginPositionX + marginWidth + textPositionX
    local charWidth = mainFont:getWidth("m")
    local visibleColumns = math.max(1, math.floor(
        (love.graphics.getWidth() - textX) / charWidth) - 1)

    if cursorColumn <= scrollX then
        scrollX = cursorColumn - 1
    end

    if cursorColumn > scrollX + visibleColumns then
        scrollX = cursorColumn - visibleColumns
    end
end
-- resize ---------------------------------------------------------------------
function love.resize()
    updateScroll()
end
-- mouse scroll ---------------------------------------------------------------
function love.wheelmoved(x, y)
    scrollY = scrollY - y * scrollSpeed
    scrollY = math.floor(scrollY)
    scrollY = math.max(0, math.min(scrollY, #lines - 1))
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

    updateScroll()
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

    updateScroll()
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
    local scrollOffsetX = scrollX * mainFont:getWidth("m")

    -- margin
    love.graphics.setColor(marginColor)
    love.graphics.line(
        marginPositionX + marginWidth, 0,
        marginPositionX + marginWidth, love.graphics.getHeight())
    --
    -- text draw
    local lineHeight = mainFont:getHeight()
    local firstLine  = scrollY + 1
    local lastLine   = math.min(#lines,
        scrollY + math.ceil((
            love.graphics.getHeight() - textPositionY) / lineHeight))
    --
    -- line numbers
    for i = firstLine, lastLine do
        local y = textPositionY + (i - 1 - scrollY) * lineHeight

        love.graphics.setColor(lineNumberColor)
        local lineNumber  = tostring(i)
        local lineNumberX = marginPositionX +
            marginWidth - 10 - mainFont:getWidth(lineNumber)

        love.graphics.print(lineNumber, lineNumberX, y)
    end
    -- text clipping
    love.graphics.setScissor(textX, 0, math.max(0,
        love.graphics.getWidth() - textX), love.graphics.getHeight())

    -- text draw
    for i = firstLine, lastLine do
        local y = textPositionY + (i - 1 - scrollY) * lineHeight

        love.graphics.setColor(fontColor)
        love.graphics.print(lines[i], textX - scrollOffsetX, y)
    end

    -- cursor position x
    local line     = lines[cursorLine]
    local position = utf8.offset(line, cursorColumn) or #line + 1
    local cursorX  = textX - scrollOffsetX
        + mainFont:getWidth(line:sub(1, position - 1))

    -- cursor position y
    local cursorY  = textPositionY + (
        cursorLine - 1 - scrollY) * mainFont:getHeight()

    -- cursor draw
    love.graphics.setColor(cursorColor)
    love.graphics.rectangle("fill", cursorX, cursorY,
    mainFont:getWidth("m"), mainFont:getHeight())

    love.graphics.setScissor()
--
end
