if newPage ~= nil then
    local button_bonus_select = newToggle("任选序列", registerBool("enable_bonus_select"), "icon-turbo")
    local button_bonus_full = newToggle("快捷序列", registerBool("enable_bonus_full"), "icon-turbo")

    local table = newPage(64)
    table:add(button_bonus_select):width(390):padLeft(60):height(64)
    table:add(button_bonus_full):width(390):padLeft(60):height(64)
    return
end

if not S.bonus:isEnabled() then
    return
end

if gameEnabled("enable_bonus_full") then
    recordGuard("快捷序列")
    S.events:getListeners(C.SystemsPostSetup):add(C.Listener(function(_)
        S.bonus:addProgressPoints(1000000)
    end))
end

if gameEnabled("enable_bonus_select") then
    recordGuard("任选序列")
    local lastStage = nil
    local allBonus = function(event)
        local stage = S.bonus:getStageToChooseBonusFor()
        if stage == lastStage then
            return
        end
        lastStage = stage
        S.bonus.stageReRolls:clear()
        local arr = stage:getProbableBonuses()
        stage:getBonusesToChooseFrom():clear()
        for i = 1, arr.size do
            local bonus = arr:get(i - 1):getBonus()
            stage:getBonusesToChooseFrom():insert(i - 1, bonus)
        end
        local prior = {
            IncreaseSelectedBonusesPower = 0,
            AddRandomCoreTile = 1,
            AllAbilitiesForRandomTower = 2,

            ExtraDamagePerBuff = 10,
            TowersDamage = 11,
            LightningStrikeOnTowerLevelUp = 12,
            TowersAttackSpeed = 13,
            CriticalDamage = 14,
            DebuffsLastLonger = 15,

            GV_TowersMaxExpLevel = 20,
            GV_MinersMaxUpgradeLevel = 21,
            BuildRandomMiner = 22,
            DoubleMiningSpeed = 23,

            SpawnZombiesFromBase = 30,
            AddAllAbilityCharges = 31,
            FirstEnemiesInWaveExplode = 32,
            BaseExplodesOnEnemyPass = 33,
            LastEnemiesInWaveDealNoDamage = 34,
            LowHpEnemiesDealNoDamage = 35,
            MultiplyMdps = 36,
            NukeOnBonusStage = 37,

            IncreasedTowerToEnemyEfficiency_FREEZING_ARMORED = 41,
            IncreasedTowerToEnemyEfficiency_FREEZING_ICY = 42,
            IncreasedTowerToEnemyEfficiency_BASIC_ICY = 43,
            IncreasedTowerToEnemyEfficiency_BASIC_ARMORED = 44,
            IncreasedTowerToEnemyEfficiency_FLAMETHROWER_HEALER = 45,
            IncreasedTowerToEnemyEfficiency_FLAMETHROWER_ARMORED = 46,

            GV_BountiesNearby = 51,
            GV_DisableBountyModifierHarm = 52,
            GV_AbilitiesMaxEnergy = 53,
            TriggerRandomAbility = 54,
            SummonLootBoss = 55,
            DepositCoinsGeneration = 56,
            ReceiveCoins = 57,
            AddRandomPlatform = 58,

            IncreasedTowerToEnemyEfficiency_BLAST_ICY = 61,
            IncreasedTowerToEnemyEfficiency_AIR_ARMORED = 62,
            IncreasedTowerToEnemyEfficiency_AIR_HEALER = 63,
            IncreasedTowerToEnemyEfficiency_TESLA_ARMORED = 64,
            IncreasedTowerToEnemyEfficiency_MINIGUN_STRONG = 65,
            IncreasedTowerToEnemyEfficiency_SPLASH_REGULAR = 66,
            IncreasedTowerToEnemyEfficiency_SPLASH_ARMORED = 67,

            GV_AbilitiesEnesgy_FIREBALL = 71,
            GV_AbilitiesEnergy_SMOKE_BOMB = 72,
            GV_AbilitiesEnesgy_FIRESTORM = 73,

            Default = 1000,
            MinersSpawnEnemies = 1001,
            SellAllTowers = 1002,
            MoreBonusVariantsNextTime = 2000
        }
        local cmp = {
            compare = function(self, l, r)
                local lp = prior[l:getId()] or prior["Default"]
                local rp = prior[r:getId()] or prior["Default"]
                if lp < rp then
                    return -1
                elseif lp > rp then
                    return 1
                elseif l:getId() < r:getId() then
                    return -1
                elseif l:getId() > r:getId() then
                    return 1
                else
                    return 0
                end
            end,
            equals = function(self, x)
                return self == x
            end
        }
        stage:getBonusesToChooseFrom():sort(C.Comparator(cmp))
    end
    S.events:getListeners(C.BonusStageRequirementMet):addStateAffecting(C.Listener(allBonus))
    S.events:getListeners(com.prineside.tdi2.events.game.Render.class):addStateAffecting(C.Listener(allBonus))

    local tab = nil
    S.events:getListeners(com.prineside.tdi2.events.game.Render.class):addStateAffecting(C.Listener(function(event)
        if tab == nil then
            local function findUiLayers(name)
                local tables = {}
                for l = 1, 3 do
                    local layers = C.Game.i.uiManager.layers[l]
                    for i = 1, layers.size do
                        local layer = layers:get(i - 1)
                        if layer.name == name then
                            tables[#tables + 1] = layer:getTable()
                        end
                    end
                end
                return tables
            end
            local layers = findUiLayers("AbilitySelectionOverlay main")
            for _, l in ipairs(layers) do
                if l:getCells().size >= 4 then
                    tab = l
                    break
                end
            end
        end
        if tab == nil then
            return
        end
        local tab3 = tab:getCells():get(3):getActor()
        if C.ScrollPane:_isInstance(tab3) then
            return
        end
        local table = C.Table.new()
        local scroll = C.ScrollPane.new_A(table)
        C.UiUtils:enableMouseMoveScrollFocus(scroll)
        table:top():left():padTop(60):add(tab3)
        tab:getCells():get(3):setActor(scroll)
    end))
end
