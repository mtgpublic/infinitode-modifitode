if C.Game.i.basicLevelManager:getLevel("mod settings") == nil then
    local level = C.BasicLevel:createNew("mod settings")
    level:setMap(com.prineside.tdi2.Map.class.new_2i(1, 1))
    C.Game.i.basicLevelManager:registerLevel(level)
end
if newPage == nil then
    if S.gameState.basicLevelName == nil then
        return
    end

    function gameEnabled(name)
        return S.gameState.gameStartProgressSnapshot:isQuestEverCompleted(name)
    end
    function gameValue(name, bits)
        bits = bits or 8
        local v = 0
        for i = bits, 1, -1 do
            v = v * 2
            if gameEnabled(name .. "_b_" .. tostring(i)) then
                v = v + 1
            end
        end
        return v
    end

    function refreshModSettings()
        S.gameState.gameStartProgressSnapshot = C.Game.i.progressManager:createProgressSnapshotForState()
    end

    local reasons = nil
    function recordGuard(reason)
        if reasons == nil then
            reasons = {"本次游戏不会提交排行榜："}
        end
        if reason ~= nil then
            reasons[#reasons + 1] = "\n" .. reason
        end
    end
    S.events:getListeners(C.SystemsPostSetup):addStateAffecting(C.Listener(function(_)
        if reasons == nil then
            return
        end
        local reason = table.concat(reasons)
        local level = S.gameState.basicLevelName
        local hasLeaderboards = C.Game.i.basicLevelManager:getLevel(level).hasLeaderboards
        S.events:getListeners(C.SystemsStateRestore):addStateAffecting(C.Listener(function(_)
            C.Notifications:i():addFailure(reason)
        end))
        S.events:getListeners(C.GameOver):addStateAffecting(C.Listener(function(_)
            C.Notifications:i():addFailure(reason)
            C.Game.i.basicLevelManager:getLevel(level).hasLeaderboards = false
        end))
        S.events:getListeners(C.SystemsDispose):addStateAffecting(C.Listener(function(_)
            C.Game.i.basicLevelManager:getLevel(level).hasLeaderboards = hasLeaderboards
        end))
    end))
end

function registerBool(name, global)
    global = global or false
    local q = C.WaveQuest.new(C.Game.i.basicLevelManager:getLevel("mod settings"), name, 0)
    if not global then
        q.prizes:add(C.ItemStack.new_I_i(C.D.F_GAME_VALUE_GLOBAL:create(C.GameValueType.DUMMY, 0), 1))
    end
    C.Game.i.basicLevelManager:getLevel("mod settings").waveQuests:add(q)
    return function(v)
        if v == nil then
            return q:isCompleted()
        end
        q:setCompleted(v)
        return v
    end
end
function registerValue(name, global, bits)
    global = global or false
    bits = bits or 8
    local qs = {}
    for i = 1, bits do
        local q = C.WaveQuest.new(C.Game.i.basicLevelManager:getLevel("mod settings"), name .. "_b_" .. tostring(i), 0)
        qs[#qs + 1] = q
        if not global then
            q.prizes:add(C.ItemStack.new_I_i(C.D.F_GAME_VALUE_GLOBAL:create(C.GameValueType.DUMMY, 0), 1))
        end
        C.Game.i.basicLevelManager:getLevel("mod settings").waveQuests:add(q)
    end
    return function(v)
        if v == nil then
            v = 0
            for i = bits, 1, -1 do
                v = v * 2
                if qs[i]:isCompleted() then
                    v = v + 1
                end
            end
            return v
        end
        v = math.floor(v)
        for i = 1, bits do
            v = v or q:isCompleted()
            qs[i]:setCompleted(v % 2 == 1)
            v = (v - v % 2) / 2
        end
        return v
    end
end

function globalEnabled(name)
    for i = 1, C.Game.i.basicLevelManager:getLevel("mod settings").waveQuests.size do
        local q = C.Game.i.basicLevelManager:getLevel("mod settings").waveQuests:get(i - 1)
        if q.id == name then
            return q:isCompleted()
        end
    end
    return false
end
function globalValue(name, bits)
    bits = bits or 8
    local v = 0
    for i = bits, 1, -1 do
        v = v * 2
        if globalEnabled(name .. "_b_" .. tostring(i)) then
            v = v + 1
        end
    end
    return v
end

function newButton(label, call, colorOff, colorOn)
    colorOn = colorOn or 0xffffffff
    colorOff = colorOff or 0x4fc3f7ff
    local button = C.LabelButton.new(label, C.Game.i.assetManager:getLabelStyle(30), C.Runnable(call))
    button:setColors(C.Color.new_i(colorOff), C.Color.new_i(colorOn))
    button:setAlignment(C.Align.center)
    return button
end

function newToggle(label, call, image, colorOff, colorOn)
    colorOn = colorOn or 0xD0D0D0FF
    colorOff = colorOff or 0x808080FF
    local toggle = C.LabelToggleButton.new()
    if image == nil then
        toggle:setup(label, false, 30, 40, false, C.ObjectConsumer(call))
    else
        toggle:setup(label, false, 30, 40, false, C.ObjectConsumer(function(v)
            call(v)
            toggle.toggleImage:setDrawable(C.Game.i.assetManager:getDrawable(image))
            if v then
                toggle.toggleImage:setColor(C.Color.new_i(colorOn))
            else
                toggle.toggleImage:setColor(C.Color.new_i(colorOff))
            end
        end))
        toggle.toggleImage:setScaling(com.badlogic.gdx.utils.Scaling.class.fit)
    end
    toggle.label:setAlignment(C.Align.center)
    onPagesOpened(function()
        local enabled = call(nil) or false
        toggle:setEnabled(enabled)
        toggle.onToggle:accept(enabled)
    end)
    return toggle
end

dofile("mods/enter-DQ.lua")
dofile("mods/game-helpers.lua")
dofile("mods/console-helpers.lua")
dofile("mods/research-mods.lua")
dofile("mods/user-map.lua")

dofile("mods/bonus-select.lua")
dofile("mods/game-config.lua")
dofile("mods/random-core.lua")
dofile("mods/random-map.lua")
if newPage == nil then
    S.events:getListeners(C.SystemsPostSetup):addStateAffectingWithPriority(C.Listener(function(_)
        S.events:getListeners(C.SystemsStateRestore):trigger(C.SystemsStateRestore:new())
    end), -9999)
end
