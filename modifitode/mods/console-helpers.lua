if newPage == nil then
    return
end

local button_state = newButton("参数控制台", function()
    if C.Game.i.researchManager:getInstalledLevel(C.ResearchType.DEVELOPER_MODE) ~= 0 then
        C.StateDebugger:i():show()
        return
    end
    C.Game.i.researchManager:setInstalledLevel(C.ResearchType.DEVELOPER_MODE, 1, false)
    C.StateDebugger:i():show()
    C.Game.i.researchManager:setInstalledLevel(C.ResearchType.DEVELOPER_MODE, 0, false)
end)
local button_inventory = newButton("物品控制台", function()
    if C.Game.i.researchManager:getInstalledLevel(C.ResearchType.DEVELOPER_MODE) ~= 0 then
        C.ItemCreationOverlay:i():show()
        return
    end
    C.Game.i.researchManager:setInstalledLevel(C.ResearchType.DEVELOPER_MODE, 1, false)
    C.ItemCreationOverlay:i():show()
    C.Game.i.researchManager:setInstalledLevel(C.ResearchType.DEVELOPER_MODE, 0, false)
end)

local show_console = registerBool("show_console", true)
local button_console = newToggle("命令行开关", function(v)
    v = show_console(v)
    if v then
        C.Game.i.uiManager:getComponent(C.DeveloperConsole)
    else
        C.Game.i.uiManager:disposeComponent(C.DeveloperConsole)
    end
    return v
end, "icon-terminal")

local table = newPage(64)
table:add(button_state):width(240):padLeft(60):height(64)
table:add(button_inventory):width(240):padLeft(60):height(64)
table:add(button_console):width(240):padLeft(60):height(64)
