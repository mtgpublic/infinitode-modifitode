if newPage == nil then
    return
end

local level_basic = false
local level_name = ""
local level_id = ""
local map = nil
local text_level = C.TextFieldXPlatform.new("", C.Game.i.assetManager:getTextFieldStyle(30))
local text_json = C.TextFieldXPlatform.new("", C.Game.i.assetManager:getTextFieldStyle(30))
local button_export = newButton("导出关卡", function()
    if level_name == "" then
        C.Notifications:i():addFailure("需输入合法关卡名")
        return
    end
    local diag_str = "将自定义地图：\n" .. level_name .. "\n导出为json字符串"
    if level_basic then
        diag_str = "将关卡：\n" .. level_name .. "\n的地图导出为json字符串"
    end
    C.Dialog:i():showConfirm(diag_str, C.Runnable(function()
        if level_basic then
            map = C.Game.i.basicLevelManager:getLevel(level_name):getMap()
        else
            map = C.Game.i.userMapManager:getUserMap(level_id).map
        end
        local json = C.Json.new()
        local str = C.StringWriter.new()
        json:setWriter(str)
        json:writeObjectStart()
        map:toJson(json)
        json:writeObjectEnd()
        text_json:setText(str)
        text_json:setColor(C.Color.new_i(0xA0FFA0FF))
        C.Gdx.app:getClipboard():setContents(str)
        C.Notifications:i():addSuccess("已将地图：\n" .. level_name .. "\n复制到剪贴板")
    end))
end)
local button_import = newButton("导入关卡", function()
    if map == nil then
        C.Notifications:i():addFailure("需输入合法json字符串")
        return
    end
    C.Dialog:i():showConfirm("从json字符串导入自定义地图：\n" .. level_name, C.Runnable(function()
        local name = text_level:getText()
        if name == "" then
            name = "unknown"
        end
        local user_map = C.Game.i.userMapManager:addUserMap(name)
        user_map.creationTimestamp = 0
        user_map.id = "M-" .. C.FastRandom:generateUniqueDistinguishableId()
        user_map.map = map
        C.Notifications:i():addSuccess("已将地图保存至：\n" .. name)
        C.Dialog:i():showConfirm("是否向背包添加一份地图图块，以确保地图保存完整？",
            C.Runnable(function()
                local tiles = map:getAllTiles()
                local gates = map:getAllGates()
                for i = 1, #tiles do
                    local tile = tiles:get(i - 1)
                    C.Game.i.progressManager:addItems(C.D.F_TILE:create(tile), 1)
                end
                for i = 1, #gates do
                    local gate = gates:get(i - 1)
                    C.Game.i.progressManager:addItems(C.D.F_TILE:create(gate), 1)
                end
                C.Notifications:i():addSuccess("已向背包添加地图图块")
            end))
    end))
end)
text_level:setTextFieldListener(C.TextFieldListener(function(_, _)
    level_name = text_level:getText()
    if C.Game.i.basicLevelManager:getLevel(level_name) ~= nil then
        level_basic = true
        text_level:setColor(C.Color.new_i(0xA0FFA0FF))
        return
    end
    local user_maps = C.Game.i.userMapManager:getUserMaps()
    for i = 1, user_maps.size do
        local user_map = user_maps:get(i - 1)
        if user_map.name == level_name then
            level_id = user_map.id
            level_basic = false
            text_level:setColor(C.Color.new_i(0xA0FFA0FF))
            return
        end
    end
    text_level:setColor(C.Color.new_i(0xFFFFFFFF))
    level_name = ""
end))
text_json:setTextFieldListener(C.TextFieldListener(function(_, _)
    local json = text_json:getText()
    map = nil
    text_json:setColor(C.Color.new_i(0xFFFFFFFF))
    map = com.prineside.tdi2.Map.class:fromJson(C.JsonReader.new():parse(json))
    if map ~= nil then
        text_json:setColor(C.Color.new_i(0xA0FFA0FF))
    end
end))
local table = newPage(64)
table:add(button_export):width(130):padLeft(60):height(64)
table:add(text_level):width(240):padLeft(20):height(40)
table:add(button_import):width(130):padLeft(60):height(64)
table:add(text_json):width(240):padLeft(20):height(40)
