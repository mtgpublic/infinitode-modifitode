if newPage ~= nil then
    local button_game_sl = newToggle("允许存档读档", registerBool("enable_sl", true), "icon-floppy")
    local button_game_speed = newToggle("调节游戏速度", registerBool("set_game_speed", true), "icon-speed-high")
    local button_game_afk = newToggle("显示AFK检测", registerBool("show_afk_state", true), "icon-loot-rarity")
    local button_game_bounty = newToggle("显示赏金提示", registerBool("show_bounty_hint", true),
        "icon-modifier-bounty-research")
    local button_game_quest = newToggle("无限替换任务", registerBool("replace_quests", true), "icon-restart")
    local button_game_offline = newToggle("强制离线模式", registerBool("enforce_offline", true), "icon-times")

    local table = newPage(192)
    table:add(button_game_sl):width(390):padLeft(60):height(64)
    table:add(button_game_speed):width(390):padLeft(60):height(64)
    table:row()
    table:add(button_game_afk):width(390):padLeft(60):height(64)
    table:add(button_game_bounty):width(390):padLeft(60):height(64)
    table:row()
    table:add(button_game_quest):width(390):padLeft(60):height(64)
    table:add(button_game_offline):width(390):padLeft(60):height(64)

    local layer_sl = C.Game.i.uiManager:addLayer(C.MainUiLayer.SCREEN, 103, "layer_game_sl")
    local layer_sl_saves = C.Game.i.uiManager:addLayer(C.MainUiLayer.SCREEN, 104, "layer_game_sl_saves")
    __saved = {}
    C.Game.EVENTS:getListeners(C.SystemsPostSetup):add(C.Listener(function(_)
        __saved = {}
    end))

    local table = C.Table.new():top():left()
    table:setBackground(C.Game.i.assetManager:getDrawable("blank"):tint(C.Color.new_i(0x303030FF)))
    local scroll = C.ScrollPane.new_A(table)
    C.UiUtils:enableMouseMoveScrollFocus(scroll)
    scroll:setSize(1200, 800)
    local button_save = newButton("存档", function()
        local S = C.Game.i:getScreen().S
        local saved = {
            time = "时间：" .. (string.rep(" ", 12) ..
                tostring(
                    com.prineside.tdi2.utils.StringFormatter.class:digestTime(
                        S.statistics:getStatistic(C.StatisticsType.PT)))):sub(-12) .. string.rep(" ", 16),
            wave = "波次：" .. (string.rep(" ", 8) .. tostring(S.wave.wave.waveNumber)):sub(-8) ..
                string.rep(" ", 16),
            score = "分数：" .. (string.rep(" ", 8) .. tostring(S.gameState:getScore())):sub(-8) ..
                string.rep(" ", 16),
            state = S:deepCopy()
        }
        saved.state.gameState.gameStartTimestamp = S.gameState.gameStartTimestamp
        C.Notifications:i():addInfo("已存档：\n" .. saved.time .. "\n" .. saved.wave .. "\n" .. saved.score)
        _G.table.insert(__saved, 1, saved)
    end)
    local initScroll
    initScroll = function()
        if #__saved == 0 then
            C.Dialog:i():showConfirm("无可用存档", C.Runnable(function()
            end))
        else
            C.Game.i:getScreen().S.gameState:setGameSpeed(0)
            table:clear()
            table:left()
            local button_return = newButton("回到游戏", function()
                scroll:setVisible(false)
                table:clear()
            end)
            table:add(button_return):width(1000):height(64):padTop(48)
            for i, saved in ipairs(__saved) do
                local load = function()
                    C.Dialog:i():showConfirm("读取存档：\n" .. saved.time .. "\n" .. saved.wave .. "\n" ..
                                                 saved.score, C.Runnable(function()
                        scroll:setVisible(false)
                        table:clear()
                        local state = saved.state:deepCopy()
                        state:createAndSetupNonStateAffectingSystemsAfterDeserialization()
                        state.gameState.inUpdateStage = true
                        local screen = C.GameScreen.new_GSP_l(state, saved.state.gameState.gameStartTimestamp)
                        C.Game.i.screenManager:setScreen(screen)
                    end))
                end
                local button_load = newButton(saved.time .. saved.wave .. saved.score, load)
                local button_remove = newButton("X", function()
                    C.Dialog:i():showConfirm("删除存档：\n" .. s.tag, C.Runnable(function()
                        _G.table.remove(__saved, i)
                        initScroll()
                    end))
                end)
                table:row()
                table:add(button_load):width(1000):height(32):padTop(32)
                table:add(button_remove):width(200):height(32):padTop(32)
            end
            scroll:setVisible(true)
        end
    end
    local button_load = newButton("读档", initScroll)

    local table = layer_sl:getTable()
    table:bottom():left():padBottom(128):padLeft(384)
    table:add(button_save):width(64):padLeft(32):height(64)
    table:add(button_load):width(64):padLeft(32):height(64)
    table:setVisible(false)
    local table = layer_sl_saves:getTable()
    table:center():add(scroll)
    scroll:setVisible(false)
    return
end

local layer = nil
local enabled = nil
local danger = false
S.events:getListeners(C.SystemsStateRestore):addStateAffecting(C.Listener(function(_)
    local function findUiLayer(name)
        for l = 1, 3 do
            local layers = C.Game.i.uiManager.layers[l]
            for i = 1, layers.size do
                local layer = layers:get(i - 1)
                if layer.name == name then
                    return layer:getTable()
                end
            end
        end
        return nil
    end
    layer = findUiLayer("layer_game_sl")
    if layer == nil then
        enabled = false
    else
        enabled = globalEnabled("enable_sl")
        layer:setVisible(false)
        S.events:getListeners(C.SystemsDispose):addStateAffecting(C.Listener(function(_)
            if layer ~= nil then
                layer:setVisible(false)
            end
        end))
    end
end))
S.events:getListeners(com.prineside.tdi2.events.game.Render.class):addStateAffecting(C.Listener(function(_)
    if enabled then
        layer:setVisible(true)
    end
end))
S.events:getListeners(C.GameStateTick):addStateAffecting(C.Listener(function(event)
    if not enabled then
        return
    end

    local health = S.gameState:getHealth()
    local enemies = S.map.spawnedEnemies
    local threshold = S.gameState:getGameSpeed() * 0.1
    for i = 1, enemies.size do
        local enemy = enemies:get(i - 1).enemy
        if enemy.graphPath ~= nil then
            if enemy.passedTiles + threshold >= enemy.graphPath:getLengthInTiles() then
                health = health - math.ceil(enemy:getBaseDamage())
            end
        end
    end

    if health <= 0 and not danger then
        C.Notifications:i():addFailure("基地即将摧毁，已自动暂停")
        S.gameState:setGameSpeed(0)
    end
    danger = health <= 0
end))

local layer = nil
local label
local slider
S.events:getListeners(C.SystemsStateRestore):addStateAffecting(C.Listener(function(_)
    if globalEnabled("set_game_speed") then
        layer = C.Game.i.uiManager:addLayer(C.MainUiLayer.SCREEN, 103, "set_game_speed")
        S.events:getListeners(C.SystemsDispose):addStateAffecting(C.Listener(function(_)
            if layer ~= nil then
                C.Game.i.uiManager:removeLayer(layer)
            end
        end))

        label = C.Label.new("游戏速度: " .. tostring(0.1 * math.ceil(1000 * S.gameState:getGameSpeed())) .. "%",
            C.Game.i.assetManager:getLabelStyle(30))
        label:setColor(C.Color.new_i(0xC0C0C0FF))
        slider = C.HorizontalSlider.new(400, math.log(S.gameState:getGameSpeed(), 2), math.log(1 / 30, 2),
            math.log(100, 2), C.ObjectConsumer(function(v)
                S.gameState:setGameSpeed(math.pow(2, v))
            end));
        slider:setValue(math.log(S.gameState:getGameSpeed(), 2))
        slider:setNotifyOnDrag(true)

        local table = layer:getTable()
        table:bottom():left():padBottom(250):padLeft(300)
        table:add(label)
        table:row()
        table:add(slider)
    end
end))
S.events:getListeners(C.GameSpeedChange):addStateAffecting(C.Listener(function(_)
    if layer == nil then
        return
    end
    local table = layer:getTable()
    label:setText("游戏速度: " .. tostring(0.1 * math.ceil(1000 * S.gameState:getGameSpeed())) .. "%")
    slider:setValue(math.log(S.gameState:getGameSpeed(), 2))
end))

local speed = S.gameState:getGameSpeed()
local isPause = false
local timeAcc = 0
S.events:getListeners(com.prineside.tdi2.events.game.Render.class):addStateAffectingWithPriority(C.Listener(function(
    event)
    speed = S.gameState:getGameSpeed()
    isPause = S.gameState:isPaused()
end), 9999)
S.events:getListeners(com.prineside.tdi2.events.game.Render.class):addStateAffectingWithPriority(C.Listener(function(
    event)
    if layer == nil or isPause then
        return
    end
    local keys = C.Game.i.settingsManager:getHotkeysJustPressed()
    for i = 1, keys.size do
        local key = keys:get(i - 1)
        if key == C.HotkeyAction.SPEED_UP then
            speed = speed * 2
            if speed == 0 and isPause == false then
                speed = 1
            end
        elseif key == C.HotkeyAction.SPEED_DOWN then
            speed = speed / 2
        elseif key == C.HotkeyAction.PAUSE_GAME then
            speed = 0
        end
    end
    if speed > 100 then
        speed = 100
    elseif speed ~= 0 and speed < 1 / 30 then
        speed = 1 / 30
    end
    S.gameState:setGameSpeed(speed)
end), 0)

S.events:getListeners(C.GameStateTick):addStateAffecting(C.Listener(function(event)
    speed = S.gameState:getGameSpeed()
    if speed > 4 then
        local time = event:getDeltaTime()
        timeAcc = timeAcc + time / 4 - time / speed
    end
    if timeAcc > 1 then
        timeAcc = timeAcc - 1
        S.statistics:addStatistic(C.StatisticsType.PRT, 1)
    end
end))

if globalEnabled("enforce_offline") then
    recordGuard("强制离线")
end

local layer = nil
local enemyKilledTime = 0
local label1
local label2
local label3
local label4
local label5
local label6
S.events:getListeners(C.SystemsStateRestore):addStateAffecting(C.Listener(function(_)
    if globalEnabled("show_afk_state") then
        S.events:getListeners(C.EnemyDie):addStateAffecting(C.Listener(function(event)
            enemyKilledTime = S.statistics:getStatistic(C.StatisticsType.PT)
        end))
        layer = C.Game.i.uiManager:addLayer(C.MainUiLayer.SCREEN, 103, "show_afk")
        S.events:getListeners(C.SystemsDispose):addStateAffecting(C.Listener(function(_)
            if layer ~= nil then
                C.Game.i.uiManager:removeLayer(layer)
            end
        end))

        label1 = C.Label.new("稀有度：", C.Game.i.assetManager:getLabelStyle(30))
        label2 = C.Label.new("-", C.Game.i.assetManager:getLabelStyle(30))
        label3 = C.Label.new("杀敌间隔：", C.Game.i.assetManager:getLabelStyle(30))
        label4 = C.Label.new("-", C.Game.i.assetManager:getLabelStyle(30))
        label5 = C.Label.new("操作间隔：", C.Game.i.assetManager:getLabelStyle(30))
        label6 = C.Label.new("-", C.Game.i.assetManager:getLabelStyle(30))

        local left = 480
        if globalEnabled("show_bounty_hint") then
            left = left + 360
        end
        local table = layer:getTable()
        table:top():left():padTop(120):padLeft(left)
        table:add(label1)
        table:add(label2)
        table:row()
        table:add(label3)
        table:add(label4)
        table:row()
        table:add(label5)
        table:add(label6)
    end
end))
S.events:getListeners(com.prineside.tdi2.events.game.Render.class):addStateAffecting(C.Listener(function(_)
    if layer == nil then
        return
    end
    local difficulty = S.gameState.averageDifficulty
    if difficulty < 100 then
        difficulty = difficulty * 0.01
    else
        if difficulty > 2000 then
            difficulty = 2000 + (270.91 * (1 - (1 / (((difficulty - 2000) * 0.00375) + 1))))
        end
        difficulty = (1 + (((difficulty - 100) / 400) * 0.85)) - (math.pow(difficulty * 2.5E-4, 3.5) * 10)
    end
    local colorTime = C.Color.new_i(0xC0C0C0FF)
    local colorKill = C.Color.new_i(0xC0C0C0FF)
    local colorAct = C.Color.new_i(0xC0C0C0FF)
    local timePlayed = S.loot:getActiveSecondsPlayed()
    local timeMax = 3600 / 1.25 / S.loot:getRewardingAdsLootMultiplier() / difficulty
    local intervalKilled = S.statistics:getStatistic(C.StatisticsType.PT) - enemyKilledTime
    local intervalAct = S.gameState.updateNumber - S.gameState:getPxpLastActionFrame()

    if timePlayed > timeMax then
        label1:setColor(C.Color.new_i(0x80FF80FF))
        label2:setColor(C.Color.new_i(0x80FF80FF))
    else
        label1:setColor(C.Color.new_i(0xC0C0C0FF))
        label2:setColor(C.Color.new_i(0xC0C0C0FF))
    end
    if intervalKilled > 30 then
        label3:setColor(C.Color.new_i(0xFF8080FF))
        label4:setColor(C.Color.new_i(0xFF8080FF))
    else
        label3:setColor(C.Color.new_i(0xC0C0C0FF))
        label4:setColor(C.Color.new_i(0xC0C0C0FF))
    end
    if intervalAct > 3600 then
        label5:setColor(C.Color.new_i(0xFF8080FF))
        label6:setColor(C.Color.new_i(0xFF8080FF))
    else
        label5:setColor(C.Color.new_i(0xC0C0C0FF))
        label6:setColor(C.Color.new_i(0xC0C0C0FF))
    end

    local time = function(t)
        return tostring(com.prineside.tdi2.utils.StringFormatter.class:digestTime(t))
    end
    label2:setText(time(timePlayed) .. " / " .. time(timeMax))
    label4:setText(time(intervalKilled) .. " / " .. time(30))
    label6:setText(time(intervalAct / 30) .. " / " .. time(3600 / 30))
end))

local layer = nil
local label1
local label2
local label3
local label4
local label5
local label6
local label7
local label8
local infs = {}
local sups = {}
local function getBountyRange(i)
    if infs[i] == nil then
        local limit = S.gameValue:getIntValue(C.GameValueType.MODIFIER_BOUNTY_VALUE)
        local rate = S.gameValue:getPercentValueAsMultiplier(C.GameValueType.MODIFIER_BOUNTY_PERCENT)
        local price = C.BountyModifierFactory.new():getBuildPrice(S, i)
        local income = 0
        while income <= limit do
            local coins = math.ceil(income / rate) + price
            if income * (i + 1) >= math.min(limit, math.floor(coins * rate)) * i then
                infs[i] = coins
                break
            end
            income = income + 1
        end
        while income <= limit do
            local coins = math.ceil(income / rate) + price
            if (income - 1) * (i + 1) >= math.min(limit, math.floor((coins - 1) * rate)) * i then
                sups[i] = coins
                break
            end
            income = income + 1
        end
    end
    return infs[i], sups[i]
end
S.events:getListeners(C.SystemsStateRestore):addStateAffecting(C.Listener(function(_)
    if globalEnabled("show_bounty_hint") then
        layer = C.Game.i.uiManager:addLayer(C.MainUiLayer.SCREEN, 103, "show_bounty")
        S.events:getListeners(C.SystemsDispose):addStateAffecting(C.Listener(function(_)
            if layer ~= nil then
                C.Game.i.uiManager:removeLayer(layer)
            end
        end))

        label1 = C.Label.new("持有：   ", C.Game.i.assetManager:getLabelStyle(30))
        label2 = C.Label.new("------", C.Game.i.assetManager:getLabelStyle(30))
        label3 = C.Label.new(" ~ ", C.Game.i.assetManager:getLabelStyle(30))
        label4 = C.Label.new("------", C.Game.i.assetManager:getLabelStyle(30))
        label5 = C.Label.new("目标：   ", C.Game.i.assetManager:getLabelStyle(30))
        label6 = C.Label.new("------", C.Game.i.assetManager:getLabelStyle(30))
        label7 = C.Label.new(" ~ ", C.Game.i.assetManager:getLabelStyle(30))
        label8 = C.Label.new("------", C.Game.i.assetManager:getLabelStyle(30))

        label1:setColor(C.Color.new_i(0xC0C0C0FF))
        label2:setColor(C.Color.new_i(0xC0C0C0FF))
        label3:setColor(C.Color.new_i(0xC0C0C0FF))
        label4:setColor(C.Color.new_i(0xC0C0C0FF))
        label5:setColor(C.Color.new_i(0xC0C0C0FF))
        label6:setColor(C.Color.new_i(0xC0C0C0FF))
        label7:setColor(C.Color.new_i(0xC0C0C0FF))
        label8:setColor(C.Color.new_i(0xC0C0C0FF))

        local table = layer:getTable()
        table:top():left():padTop(120):padLeft(480)
        table:add(label1)
        table:add(label2)
        table:add(label3)
        table:add(label4)
        table:row()
        table:add(label5)
        table:add(label6)
        table:add(label7)
        table:add(label8)
    end
end))
S.events:getListeners(C.GameValuesRecalculate):addStateAffecting(C.Listener(function(_)
    infs = {}
    sups = {}
end))
S.events:getListeners(com.prineside.tdi2.events.game.Render.class):addStateAffecting(C.Listener(function(_)
    if layer == nil then
        return
    end

    local current = S.gameState:getMoney()
    local potential = current
    local cons = 0
    local opti = 0

    local k_rate = S.gameValue:getPercentValueAsMultiplier(C.GameValueType.FORCED_WAVE_BONUS)
    if S.wave.wave ~= nil then
        if C.WaveSystem.Status.SPAWNING:equals(S.wave.status) then
            cons = (S.wave.wave.killedEnemiesBountySum * 0.8 + S.wave.wave.enemiesSumBounty * 0.2) * k_rate
            potential = potential - S.wave.wave.killedEnemiesBountySum + S.wave.wave.enemiesSumBounty
            opti = S.wave.wave.enemiesSumBounty * k_rate
        elseif C.WaveSystem.Status.SPAWNED:equals(S.wave.status) then
            local k_time = S.wave:getTimeToNextWave() / S.wave:getWaveStartInterval()
            local k_kill = S.wave.wave.killedEnemiesBountySum * 0.8 + S.wave.wave.enemiesSumBounty * 0.2
            cons = k_time * k_kill * k_rate
            for i = 1, #S.map.spawnedEnemies do
                local enemy = S.map.spawnedEnemies:get(i - 1).enemy
                if enemy.wave ~= nil then
                    if S.wave.wave.waveNumber == enemy.wave.waveNumber and not enemy.notAffectsWaveKillCounter:isTrue() then
                        k_kill = k_kill + enemy.bounty * 0.8
                        potential = potential + enemy.bounty
                    end
                end
            end
            opti = k_time * k_kill * k_rate
        end
    end
    if potential < current then
        potential = current
    end
    if cons < opti then
        cons = opti
    end
    if S.wave:isForceWaveDoubleBonus() then
        cons = cons * 2
        opti = opti * 2
    end

    cons = math.ceil(current) + math.ceil(cons)
    opti = math.ceil(potential) + math.ceil(opti)

    local count = S.modifier:getMaxModifiersCount(C.ModifierType.BOUNTY) -
                      S.modifier:getBuildableModifiersCount(C.ModifierType.BOUNTY)
    local inf, sup = getBountyRange(count)

    if cons < inf then
        label2:setColor(C.Color.new_i(0xC0C0C0FF))
    elseif cons >= sup then
        label2:setColor(C.Color.new_i(0x80FF80FF))
    else
        label2:setColor(C.Color.new_i(0xFFFF80FF))
    end
    if opti < inf then
        label4:setColor(C.Color.new_i(0xC0C0C0FF))
    elseif opti >= sup then
        label4:setColor(C.Color.new_i(0x80FF80FF))
    else
        label4:setColor(C.Color.new_i(0xFFFF80FF))
    end

    label2:setText(tostring(cons))
    label4:setText(tostring(opti))
    label6:setText(tostring(inf))
    label8:setText(tostring(sup))
end))

local gv = C.GameValueConfig.new(C.GameValueType.REGULAR_QUESTS_REPLACES, 0, false, true)
S.gameValue:addCustomGameValue(gv)
S.events:getListeners(C.SystemsStateRestore):addStateAffecting(C.Listener(function(_)
    if globalEnabled("replace_quests") then
        gv:setValue(10000)
    else
        gv:setValue(0)
    end
    S.gameState.inUpdateStage = true
    S.gameValue:recalculate()
    S.gameState.inUpdateStage = false
end))
