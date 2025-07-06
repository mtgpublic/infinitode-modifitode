local pagesOpenedCallbacks = {}

local menu = C.SideMenu.new(960)
local button = menu:getWrapper():findActor("side_menu_toggle_button")
menu:setOffscreen(true)
menu:getWrapper():getChild(1):setVisible(false)
button:setVisible(false)
button:setClickHandler(C.Runnable(function()
    menu:setOffscreen(true)
    menu:getWrapper():getChild(1):setVisible(false)
    button:setVisible(false)
end))
local content = C.Table.new():top():left():padTop(32)
content:setBackground(C.Game.i.assetManager:getDrawable("blank"):tint(C.Color.new_i(0x252525FF)))
local contentScroll = C.ScrollPane.new_A(content)
C.UiUtils:enableMouseMoveScrollFocus(contentScroll)
contentScroll:setSize(960, 1080)
local container = menu:createContainer("container")
container:addActor(contentScroll)
container:show()
local table = C.Game.i.uiManager:addLayer(C.MainUiLayer.SCREEN, 103, "additional_settings_button_layer"):getTable()
C.Game.EVENTS:getListeners(com.prineside.tdi2.events.global.Render.class):add(C.Listener(function(_)
    local visible = C.MainMenuScreen:_isInstance(C.Game.i.screenManager:getCurrentScreen())
    table:setVisible(visible)
end))
table:bottom():right():padBottom(32):padRight(472):add(C.LabelButton.new("MOD设置",
    C.Game.i.assetManager:getLabelStyle(30), C.Runnable(function()
        for _, f in ipairs(pagesOpenedCallbacks) do
            f()
        end
        menu:setOffscreen(false)
        menu:getWrapper():getChild(1):setVisible(true)
        button:setVisible(true)
    end))):height(128):width(128)

function newPage(height)
    local table = C.Table.new()
    table:top():left()
    table:setBackground(C.Game.i.assetManager:getDrawable("blank"):tint(C.Color.new_i(0x252525FF)))
    content:add(table):size(960, height):row()
    -- table:getParent():getCell(table):height(height)
    return table
end

function onPagesOpened(f)
    pagesOpenedCallbacks[#pagesOpenedCallbacks + 1] = f
end

dofile("scripts/game/mods.lua")
