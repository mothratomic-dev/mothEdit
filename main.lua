-- mothratomic - moth edit lua - love2d ------------------------------------ --
-- ------------------------------------------------------------------------- --
-- main -------------------------------------------------------------------- --
local utf8 = require("utf8")
--
-- settings -------------------------------------------------------------------
-- background
bgColor                 = {0.18, 0.20, 0.22}    -- background color
-- font
fontColor               = {1, 1, 1, 1}          -- font color
sizeFont                = 14                    -- font size
-- cursor
cursorColor             = {0.8, 0.6, 1, 0.6}    -- cursor color
-- text
textPositionX           = 10                    -- margin > text position x
textPositionY           = 5                     -- text position y
-- scroll
scrollSpeed             = 1                     -- scroll speed /line
-- margin
lineNumberColor         = {0.4, 0.4, 0.4}       -- line number color
lineNumberActiveColor   = {1, 0.8, 1}           -- active line number color
marginColor             = {0.4, 0.3, 0.4}       -- margin color
marginPositionX         = 10                    -- margin move position
marginPositionFixe      = 30                    -- margin fixe position
marginMove              = true                  -- margin move true/false
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
-- margin width ---------------------------------------------------------------
function getMarginWidth()
    if marginMove then
        return mainFont:getWidth(tostring(#lines)) + 10
    end

    return marginPositionFixe
end
--
-- scroll ---------------------------------------------------------------------
function updateScroll()
    -- vertical scroll
    local lineHeight   = mainFont:getHeight()
    local visibleLines = math.max(1, math.floor(
        (love.graphics.getHeight() - textPositionY) / lineHeight))

    if cursorLine <= scrollY then
        scrollY    = cursorLine - 1
    end

    if cursorLine > scrollY + visibleLines then
        scrollY   = cursorLine - visibleLines
    end
    -- horizontal scroll
    local marginWidth  = getMarginWidth()
    local textX        = marginPositionX + marginWidth + textPositionX
    local visibleWidth = love.graphics.getWidth() - textX

    local line     = lines[cursorLine]
    local position = utf8.offset(line, cursorColumn) or #line + 1
    local cursorX  = mainFont:getWidth(line:sub(1, position - 1))

    if cursorX  < scrollX then
        scrollX = cursorX
    end

    if cursorX  + mainFont:getWidth("m") > scrollX + visibleWidth then
        scrollX = cursorX + mainFont:getWidth("m") - visibleWidth
    end

    scrollX = math.max(0, scrollX)
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
-- mouse input ----------------------------------------------------------------
function love.mousepressed(x, y, button)
    if button ~= 1 then return end
    local lineHeight = mainFont:getHeight()
    local textX      = marginPositionX + getMarginWidth() + textPositionX

    if x < textX then return end

    -- line
    cursorLine = math.floor((y - textPositionY) / lineHeight)
        + scrollY + 1
    cursorLine = math.max(1, math.min(cursorLine, #lines))

    -- column
    local line   = lines[cursorLine]
    local mouseX = x - textX + scrollX

    cursorColumn = 1

    for i = 1, utf8.len(line) do
        local position = utf8.offset(line, i + 1) or #line + 1
        local width    = mainFont:getWidth(line:sub(1, position - 1))
        local start    = utf8.offset(line, i)
        local previousWidth = mainFont:getWidth(line:sub(1, start - 1))

        if mouseX < (previousWidth + width) / 2 then
            break
        end
        cursorColumn = i + 1
    end

    updateScroll()
end
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
    --
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
    if key == "left" then
        if cursorColumn   > 1 then
            cursorColumn  = cursorColumn - 1
        elseif cursorLine > 1 then
            cursorLine    = cursorLine - 1
            cursorColumn  = utf8.len(lines[cursorLine]) + 1
        end
    end

    -- right
    if key == "right" then
        if cursorColumn  <= utf8.len(lines[cursorLine]) then
            cursorColumn  = cursorColumn + 1
        elseif cursorLine < #lines then
            cursorLine    = cursorLine + 1
            cursorColumn  = 1
        end
    end
    --
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

        if cursorColumn  > 1 then
            local start  = utf8.offset(line, cursorColumn - 1)
            local finish = utf8.offset(line, cursorColumn) or #line + 1

            lines[cursorLine] = line:sub(1, start - 1) .. line:sub(finish)
            cursorColumn      = cursorColumn - 1

        elseif cursorLine  > 1 then
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
    -- setup
    love.graphics.setBackgroundColor(bgColor)
    love.graphics.setFont(mainFont)

    local marginWidth = getMarginWidth()
    local textX       = marginPositionX + marginWidth + textPositionX
    local lineHeight  = mainFont:getHeight()

    local firstLine = scrollY + 1
    local lastLine  = math.min(#lines,
        scrollY + math.ceil(
            (love.graphics.getHeight() - textPositionY) / lineHeight))

    -- margin
    love.graphics.setColor(marginColor)
    love.graphics.line(
        marginPositionX + marginWidth, 0,
        marginPositionX + marginWidth, love.graphics.getHeight())

    for i = firstLine, lastLine do
        local y = textPositionY + (i - 1 - scrollY) * lineHeight

        if i == cursorLine then
            love.graphics.setColor(lineNumberActiveColor)
        else
            love.graphics.setColor(lineNumberColor)
        end

        local lineNumber  = tostring(i)
        local lineNumberX = marginPositionX
            + marginWidth - 10 - mainFont:getWidth(lineNumber)

        love.graphics.print(lineNumber, lineNumberX, y)
    end

    -- text
    love.graphics.setScissor(
        textX, 0,
        math.max(0, love.graphics.getWidth() - textX),
        love.graphics.getHeight())

    for i = firstLine, lastLine do
        local y = textPositionY + (i - 1 - scrollY) * lineHeight

        love.graphics.setColor(fontColor)
        love.graphics.print(lines[i], textX - scrollX, y)
    end

    -- cursor
    local line     = lines[cursorLine]
    local position = utf8.offset(line, cursorColumn) or #line + 1

    local cursorX  = textX - scrollX
        + mainFont:getWidth(line:sub(1, position - 1))

    local cursorY  = textPositionY
        + (cursorLine - 1 - scrollY) * lineHeight

    love.graphics.setColor(cursorColor)
    love.graphics.rectangle(
        "fill", cursorX, cursorY,
        mainFont:getWidth("m"), lineHeight)

    -- cleanup
    love.graphics.setScissor()
end
