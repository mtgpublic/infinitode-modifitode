if newPage ~= nil then

    local button_coin = newToggle("无限金币", registerBool("inf_coin"), "icon-coins")
    local button_health = newToggle("无限血量", registerBool("inf_health"), "icon-heart")
    local init_wave = registerBool("init_wave")
    local init_level = registerBool("init_level")
    local val_init_wave = registerValue("val_init_wave", false, 20)
    local val_init_level = registerValue("val_init_level", false, 10)

    local label_wave = C.Label.new("初始波次：", C.Game.i.assetManager:getLabelStyle(30))
    label_wave:setColor(C.Color.new_i(0xC0C0C0FF))
    local label_level = C.Label.new("初始等级：", C.Game.i.assetManager:getLabelStyle(30))
    label_level:setColor(C.Color.new_i(0xC0C0C0FF))
    local str_wave = ""
    if globalEnabled("init_wave") and globalValue("val_init_wave", 20) > 0 then
        str_wave = tostring(globalValue("val_init_wave", 20))
    end
    local str_level = ""
    if globalEnabled("init_level") and globalValue("val_init_level", 10) > 0 then
        str_level = tostring(globalValue("val_init_level", 10))
    end
    local text_wave = C.TextFieldXPlatform.new(str_wave, C.Game.i.assetManager:getTextFieldStyle(30))
    local text_level = C.TextFieldXPlatform.new(str_level, C.Game.i.assetManager:getTextFieldStyle(30))
    if str_wave ~= "" then
        text_wave:setColor(C.Color.new_i(0xA0FFA0FF))
    end
    if str_level ~= "" then
        text_level:setColor(C.Color.new_i(0xA0FFA0FF))
    end
    text_wave:setMaxLength(6)
    text_level:setMaxLength(3)
    text_wave:setTextFieldListener(C.TextFieldListener(function(_, _)
        local wave = text_wave:getText()
        if wave == "" or wave == "0" then
            text_wave:setColor(C.Color.new_i(0xFFFFFFFF))
            init_wave(false)
            return
        end
        if not java.util.regex.Pattern.class:matches("[1-9][0-9]*", wave) then
            text_wave:setColor(C.Color.new_i(0xFFA0A0FF))
            init_wave(false)
            return
        end
        init_wave(true)
        val_init_wave(tonumber(wave))
        text_wave:setColor(C.Color.new_i(0xA0FFA0FF))
    end))
    text_level:setTextFieldListener(C.TextFieldListener(function(_, _)
        local level = text_level:getText()
        if level == "" or level == "0" then
            text_level:setColor(C.Color.new_i(0xFFFFFFFF))
            init_level(false)
            return
        end
        if not java.util.regex.Pattern.class:matches("[1-9][0-9]*", level) then
            text_level:setColor(C.Color.new_i(0xFFA0A0FF))
            init_level(false)
            return
        end
        init_level(true)
        val_init_level(tonumber(level))
        text_level:setColor(C.Color.new_i(0xA0FFA0FF))
    end))
    local table = newPage(64)
    table:add(button_coin):width(390):padLeft(60):height(64)
    table:add(button_health):width(390):padLeft(60):height(64)
    local table = newPage(64)
    table:add(label_wave):width(130):padLeft(60):height(64)
    table:add(text_wave):width(240):padLeft(20):height(40)
    table:add(label_level):width(130):padLeft(60):height(64)
    table:add(text_level):width(240):padLeft(20):height(40)

    return
end

if gameEnabled("inf_coin") then
    recordGuard("无限金币")
    S.events:getListeners(C.SystemsPostSetup):add(C.Listener(function(_)
        S.gameState:setMoney(999999999)
    end))
    S.events:getListeners(C.CoinsChange):add(C.Listener(function(e)
        if e:getOldValue() == 999999999 and S.gameState:getMoney() ~= 999999999 then
            S.gameState:setMoney(999999999)
        end
    end))
end
if gameEnabled("inf_health") then
    recordGuard("无限血量")
    S.events:getListeners(C.SystemsPostSetup):add(C.Listener(function(_)
        S.gameState:setHealth(999)
    end))
    S.events:getListeners(C.BaseHealthChange):add(C.Listener(function(e)
        if e:getOldValue() == 999 and S.gameState:getHealth() ~= 999 then
            S.gameState:setHealth(999)
        end
    end))
end
if gameEnabled("init_wave") then
    recordGuard("初始波次")
    S.events:getListeners(C.SystemsPostSetup):add(C.Listener(function(_)
        local val_init_wave = gameValue("val_init_wave", 20)
        if val_init_wave >= 1 then
            S.wave:startNextWave()
            S.wave.wave.waveNumber = val_init_wave - 1
            S.wave:startNextWave()
            S.gameState:setGameSpeed(0)
        end
    end))
end
if gameEnabled("init_level") then
    recordGuard("初始等级")
    S.events:getListeners(C.SystemsPostSetup):add(C.Listener(function(_)
        local val_init_level = gameValue("val_init_level", 10)
        if val_init_level >= 1 then
            S.gameValue:addCustomGameValue(C.GameValueConfig.new(C.GameValueType.TOWERS_STARTING_LEVEL,
                val_init_level - 1, false, true))
            S.gameValue:recalculate()
        end
    end))
end
