if newPage == nil then
    return
end

local button_refresh_wheel = newButton("刷新转盘", function()
    C.Dialog:i():showConfirm("即将刷新幸运一击转盘", C.Runnable(function()
        C.Game.i.progressManager:generateNewLuckyWheel()
    end))
end)
local button_refresh_shop = newButton("刷新商店", function()
    C.Dialog:i():showConfirm("即将刷新商店物品", C.Runnable(function()
        C.Game.i.progressManager:generateNewShopOffers()
    end))
end)
local button_double_gain = newButton("双倍收益", function()
    C.Dialog:i():showConfirm("即将获取双倍收益碎片", C.Runnable(function()
        C.Game.i.progressManager:addItems(C.D.F_DOUBLE_GAIN_SHARD:createDefault(), 1)
    end))
end)

local button_resource = newButton("资源全满", function()
    C.Dialog:i():showConfirm("[#ff2020]即将修改全部资源数量至上限[]", C.Runnable(function()
        local list = { --
        C.D.RESOURCE_SCALAR, C.D.RESOURCE_VECTOR, C.D.RESOURCE_MATRIX, C.D.RESOURCE_TENSOR, C.D.RESOURCE_INFIAR, --
        C.D.BLUEPRINT_AGILITY, C.D.BLUEPRINT_EXPERIENCE, C.D.BLUEPRINT_POWER, -- 
        C.D.BLUEPRINT_SPECIAL_I, C.D.BLUEPRINT_SPECIAL_II, C.D.BLUEPRINT_SPECIAL_III, C.D.BLUEPRINT_SPECIAL_IV, --
        C.D.GREEN_PAPER, C.D.BIT_DUST, C.D.ACCELERATOR, --
        C.D.ABILITY_TOKEN, C.D.PRESTIGE_TOKEN, C.D.LUCKY_SHOT_TOKEN, C.D.RESEARCH_TOKEN --
        }
        for _, t in ipairs(list) do
            C.Game.i.progressManager:addItems(t, 999999999)
        end
    end))
end, 0xFF2020FF)
local button_research = newButton("科技全满", function()
    C.Dialog:i():showConfirm("[#ff2020]即将修改全部科技等级至上限[]", C.Runnable(function()
        local dev = C.Game.i.researchManager:getInstalledLevel(C.ResearchType.DEVELOPER_MODE)
        C.Game.i.researchManager:installAllEndlessResearches()
        C.Game.i.researchManager:setInstalledLevel(C.ResearchType.DEVELOPER_MODE, dev, false)
    end))
end, 0xFF2020FF)
local button_research_clear = newButton("清空科技", function()
    C.Dialog:i():showConfirm("[#ff2020]即将清空全部科技[]", C.Runnable(function()
        for i = 1, #C.ResearchType.values do
            local research = C.ResearchType.values[i]
            C.Game.i.researchManager:setInstalledLevel(research, 0, false)
        end
    end))
end, 0xFF2020FF)

local button_unlock = newButton("解锁关卡", function()
    C.Dialog:i():showConfirm("[#ff2020]即将解锁全部关卡[]", C.Runnable(function()
        local double = C.Game.i.progressManager:isDoubleGainEnabled()
        for i = 1, C.Game.i.basicLevelManager.levelsOrdered.size do
            local level = C.Game.i.basicLevelManager.levelsOrdered:get(i - 1)
            if level.name ~= "mod settings" then
                C.Game.i.basicLevelManager:setPurchased(level)
            end
        end
    end))
end, 0xFF2020FF)
local button_star = newButton("全部三星", function()
    C.Dialog:i():showConfirm("[#ff2020]即将获取全关卡星奖励[]", C.Runnable(function()
        local double = C.Game.i.progressManager:isDoubleGainEnabled()
        for i = 1, C.Game.i.basicLevelManager.levelsOrdered.size do
            local level = C.Game.i.basicLevelManager.levelsOrdered:get(i - 1)
            if level.name ~= "mod settings" then
                C.Game.i.basicLevelManager:setPurchased(level)
                for j = 1, level.quests.size do
                    local quest = level.quests:get(j - 1)
                    if not quest:isCompleted() then
                        for k = 1, quest.prizes.size do
                            local stack = quest.prizes:get(k - 1)
                            if stack:getItem():sameAs(C.D.STAR) then
                                quest:setCompleted(true)
                                for l = 1, quest.prizes.size do
                                    local stack = quest.prizes:get(l - 1)
                                    stack:markDoubled(double)
                                    C.Game.i.progressManager:addItemStack(stack)
                                end
                                break
                            end
                        end
                    end
                end
                for j = 1, level.waveQuests.size do
                    local quest = level.waveQuests:get(j - 1)
                    if not quest:isCompleted() then
                        for k = 1, quest.prizes.size do
                            local stack = quest.prizes:get(k - 1)
                            if stack:getItem():sameAs(C.D.STAR) then
                                quest:setCompleted(true)
                                for l = 1, quest.prizes.size do
                                    local stack = quest.prizes:get(l - 1)
                                    stack:markDoubled(double)
                                    C.Game.i.progressManager:addItemStack(stack)
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end))
end, 0xFF2020FF)
local button_master = newButton("任务全满", function()
    C.Dialog:i():showConfirm("[#ff2020]即将完成全部任务[]", C.Runnable(function()
        local double = C.Game.i.progressManager:isDoubleGainEnabled()
        for i = 1, C.Game.i.basicLevelManager.levelsOrdered.size do
            local level = C.Game.i.basicLevelManager.levelsOrdered:get(i - 1)
            if level.name ~= "mod settings" then
                C.Game.i.basicLevelManager:setPurchased(level)
                for j = 1, level.quests.size do
                    local quest = level.quests:get(j - 1)
                    if not quest:isCompleted() then
                        quest:setCompleted(true)
                        for k = 1, quest.prizes.size do
                            local stack = quest.prizes:get(k - 1)
                            stack:markDoubled(double)
                            C.Game.i.progressManager:addItemStack(stack)
                        end
                    end
                end
                for j = 1, level.waveQuests.size do
                    local quest = level.waveQuests:get(j - 1)
                    if not quest:isCompleted() then
                        quest:setCompleted(true)
                        for k = 1, quest.prizes.size do
                            local stack = quest.prizes:get(k - 1)
                            stack:markDoubled(double)
                            C.Game.i.progressManager:addItemStack(stack)
                        end
                    end
                end
            end
        end
        C.Game.i.progressManager:addItems(C.D.F_TROPHY:create(C.TrophyType.SPECIAL_MILLION), 1)
    end))
end, 0xFF2020FF)

local table = newPage(192)
table:add(button_refresh_wheel):width(240):padLeft(60):height(64)
table:add(button_refresh_shop):width(240):padLeft(60):height(64)
table:add(button_double_gain):width(240):padLeft(60):height(64)
table:row()
table:add(button_resource):width(240):padLeft(60):height(64)
table:add(button_research):width(240):padLeft(60):height(64)
table:add(button_research_clear):width(240):padLeft(60):height(64)
table:row()
table:add(button_unlock):width(240):padLeft(60):height(64)
table:add(button_star):width(240):padLeft(60):height(64)
table:add(button_master):width(240):padLeft(60):height(64)
