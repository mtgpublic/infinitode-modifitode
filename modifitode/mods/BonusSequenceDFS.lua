-- arguments
-- local dqs = {"DQ1", "DQ3", "DQ4", "DQ5", "DQ7", "DQ8", "DQ9", "DQ10", "DQ11", "DQ12"}
local dqs = nil
local scoreRecordInit = 200
local scoreThreshhold = 30
local maxStage = nil
local dateBegin = nil
local dateEnd = nil
local useCachedSeq = false
-- environments
-- seqStorage = {}
weight = {}
keyWeight = {}
weightSpecal = function(state, stageIdx, modId, update)
    return 0
end
-- variables
local logger = C.TLog:forTag("Bonus-Sequence-DFS")
local coreType = {"紫", "橙", "青"}
local bonusName = {
    AddRandomCoreTile = "核",
    TowersDamage = "伤害",
    TowersAttackSpeed = "攻速",
    CriticalDamage = "暴击",
    ExtraDamagePerBuff = "易伤",
    DebuffsLastLonger = "时间",
    LightningStrikeOnTowerLevelUp = "雷电",
    AllAbilitiesForRandomTower = "全技能",
    SpawnZombiesFromBase = "策反",
    AddAllAbilityCharges = "技能",
    GV_TowersMaxExpLevel = "等级",
    GV_MinersMaxUpgradeLevel = "矿等",
    GV_BountiesNearby = "赏金邻近",
    GV_DisableBountyModifierHarm = "赏金塔",
    GV_AbilitiesMaxEnergy = "技能点",
    TriggerRandomAbility = "随机技能",
    DepositCoinsGeneration = "金币生成",
    ReceiveCoins = "立即金币",
    LastEnemiesInWaveDealNoDamage = "最后敌人",
    LowHpEnemiesDealNoDamage = "残血敌人",
    DoubleMiningSpeed = "双倍矿",
    FirstEnemiesInWaveExplode = "敌人爆炸",
    BaseExplodesOnEnemyPass = "基地爆炸",
    BuildRandomMiner = "随机矿",
    AddRandomPlatform = "平台",
    MultiplyMdps = "双倍秒伤",
    NukeOnBonusStage = "核弹",
    BoostExistingEnemiesWithLoot = "额外掉落",
    MultiplyLootedItems = "双倍物品",
    EnemiesDropResources = "掉矿",
    MineLegendaryItems = "挖青",
    MinedItemsTurnIntoDust = "挖尘",
    MinersSpawnEnemies = "挖怪",
    SellAllTowers = "卖塔",
    IncreasedTowerToEnemyEfficiency_FREEZING_ARMORED = "冰对甲",
    IncreasedTowerToEnemyEfficiency_FREEZING_ICY = "冰对冰",
    IncreasedTowerToEnemyEfficiency_BASIC_ICY = "基础对冰",
    IncreasedTowerToEnemyEfficiency_BASIC_ARMORED = "基础对甲",
    IncreasedTowerToEnemyEfficiency_BLAST_ICY = "爆破对冰",
    IncreasedTowerToEnemyEfficiency_AIR_ARMORED = "防空对甲",
    IncreasedTowerToEnemyEfficiency_AIR_HEALER = "防空对愈",
    IncreasedTowerToEnemyEfficiency_TESLA_ARMORED = "电对甲",
    IncreasedTowerToEnemyEfficiency_FLAMETHROWER_HEALER = "火对愈",
    IncreasedTowerToEnemyEfficiency_FLAMETHROWER_ARMORED = "火对甲",
    IncreasedTowerToEnemyEfficiency_MINIGUN_STRONG = "机枪对壮",
    IncreasedTowerToEnemyEfficiency_SPLASH_REGULAR = "散射对绿",
    IncreasedTowerToEnemyEfficiency_SPLASH_ARMORED = "散射对甲",
    GV_AbilitiesEnesgy_FIREBALL = "火球能量",
    GV_AbilitiesEnergy_SMOKE_BOMB = "毒气能量",
    GV_AbilitiesEnesgy_FIRESTORM = "烈焰能量",
    SummonLootBoss = "头目",
    MoreBonusVariantsNextTime = "加一",
    IncreaseSelectedBonusesPower = "序列升级"
}
local function SetWeight(name)
    local function score(v)
        if type(v) == "table" then
            local r = {}
            local a = 0
            for i, x in ipairs(v) do
                r[i] = 100 * math.log((x + a + 100) / (a + 100), 2)
                a = a + x
            end
            return r
        else
            return 100 * math.log((v + 100) / 100, 2)
        end
    end
    if name == "DQ1" then
        weight = {
            AddRandomCoreTile = score({90, 150}),
            TowersDamage = score({15, 15, 15}),
            TowersAttackSpeed = score({12, 12, 12}),
            CriticalDamage = score({10, 5, 5}),
            ExtraDamagePerBuff = score({25, 25, 25, 25, 25}),
            DebuffsLastLonger = score({7, 6, 5}),
            LightningStrikeOnTowerLevelUp = score({25, 19, 19}),
            AllAbilitiesForRandomTower = score({6, 6}),
            SpawnZombiesFromBase = score({5, 3}),
            AddAllAbilityCharges = score({4}),
            GV_TowersMaxExpLevel = score({30, 20, 18}),
            GV_MinersMaxUpgradeLevel = score({18, 19, 21}),
            DepositCoinsGeneration = score({2}),
            ReceiveCoins = score({1.5}),
            LastEnemiesInWaveDealNoDamage = score({0.15}),
            LowHpEnemiesDealNoDamage = score({0.07}),
            DoubleMiningSpeed = score({4}),
            FirstEnemiesInWaveExplode = score({2.5}),
            BaseExplodesOnEnemyPass = score({0.2}),
            BuildRandomMiner = score({3}),
            AddRandomPlatform = score({6, 2}),
            MinersSpawnEnemies = score({-50}),
            SellAllTowers = score({-0.1}),
            IncreasedTowerToEnemyEfficiency_FREEZING_ARMORED = score({6, 0.35}),
            GV_BountiesNearby = score({7}),
            GV_DisableBountyModifierHarm = score({4})
        }
        weightSpecal = function(special, stageIdx, modId, update)
            local bias = 0
            if modId == "AddRandomCoreTile" and stageIdx <= 5 then
                bias = bias + weight["AddRandomCoreTile"][1] * -0.4
            end
            if modId == "AddRandomPlatform" and stageIdx >= 4 and special.plat == nil then
                bias = bias + 10
            end
            if modId == "AddRandomPlatform" and update then
                special.plat = stageIdx
            end
            return bias
        end
    elseif name == "DQ3" then
        weight = {
            AddRandomCoreTile = score({80}),
            TowersDamage = score({15, 15, 15}),
            TowersAttackSpeed = score({10, 10, 10}),
            CriticalDamage = score({10, 5, 5}),
            ExtraDamagePerBuff = score({25, 25, 25, 25, 25}),
            DebuffsLastLonger = score({5, 5, 5}),
            LightningStrikeOnTowerLevelUp = score({8, 8, 7}),
            AllAbilitiesForRandomTower = score({7, 6}),
            SpawnZombiesFromBase = score({5, 3}),
            TriggerRandomAbility = score({5, 4, 3}),
            AddAllAbilityCharges = score({3}),
            GV_TowersMaxExpLevel = score({13, 9, 6}),
            GV_MinersMaxUpgradeLevel = score({11.5, 11.5, 11.5}),
            DepositCoinsGeneration = score({2}),
            ReceiveCoins = score({1.5}),
            GV_AbilitiesMaxEnergy = score({1}),
            LastEnemiesInWaveDealNoDamage = score({0.35}),
            LowHpEnemiesDealNoDamage = score({0.35}),
            DoubleMiningSpeed = score({3}),
            FirstEnemiesInWaveExplode = score({3}),
            BaseExplodesOnEnemyPass = score({0.35}),
            BuildRandomMiner = score({3}),
            MinersSpawnEnemies = score({-50}),
            SellAllTowers = score({-0.1}),
            SummonLootBoss = score({4}),
            NukeOnBonusStage = {0},
            addAbilityCharges = {0},
            MultiplyMdps = {0},
            GV_AbilitiesEnesgy_FIREBALL = {0},
            GV_AbilitiesEnergy_SMOKE_BOMB = {0},
            GV_AbilitiesEnesgy_FIRESTORM = {0}
        }
        weightSpecal = function(special, stageIdx, modId, update)
            local bias = 0
            if modId == "NukeOnBonusStage" and stageIdx == 10 then
                bias = bias + 11.1
            end
            if modId == "addAbilityCharges" and stageIdx == 10 then
                bias = bias + 11.1
            end
            if modId == "AddRandomCoreTile" and stageIdx <= 5 then
                bias = bias + weight["AddRandomCoreTile"][1] * -0.4
            end
            if modId == "MultiplyMdps" and stageIdx == 10 then
                bias = bias + 20
            end
            if modId == "GV_AbilitiesEnesgy_FIREBALL" or modId == "GV_AbilitiesEnergy_SMOKE_BOMB" or modId ==
                "GV_AbilitiesEnesgy_FIRESTORM" then
                bias = bias + 5.6
            end
            return bias
        end
    elseif name == "DQ4" then
        weight = {
            AddRandomCoreTile = score({90, 160}),
            TowersDamage = score({15, 15, 15}),
            TowersAttackSpeed = score({12, 12, 12}),
            CriticalDamage = score({10, 5, 5}),
            ExtraDamagePerBuff = score({25, 25, 25, 25, 25}),
            DebuffsLastLonger = score({6, 5, 4}),
            LightningStrikeOnTowerLevelUp = score({4, 3, 2}),
            AllAbilitiesForRandomTower = score({6, 5}),
            SpawnZombiesFromBase = score({5, 4}),
            TriggerRandomAbility = score({5, 5, 5}),
            AddAllAbilityCharges = score({12.5, 12.5, 10}),
            GV_TowersMaxExpLevel = score({25, 13, 9}),
            GV_MinersMaxUpgradeLevel = score({22, 24, 26}),
            DepositCoinsGeneration = score({2}),
            ReceiveCoins = score({1.5}),
            LastEnemiesInWaveDealNoDamage = score({0.07}),
            LowHpEnemiesDealNoDamage = score({0.07}),
            DoubleMiningSpeed = score({4}),
            FirstEnemiesInWaveExplode = score({2.5}),
            BuildRandomMiner = score({4}),
            AddRandomPlatform = score({5, 4}),
            MinersSpawnEnemies = score({-50}),
            SellAllTowers = score({-0.1}),
            IncreasedTowerToEnemyEfficiency_FREEZING_ARMORED = score({5, 4}),
            IncreasedTowerToEnemyEfficiency_FREEZING_ICY = score({5, 4}),
            IncreasedTowerToEnemyEfficiency_SPLASH_ARMORED = score({5, 4}),
            NukeOnBonusStage = {0}
        }
        weightSpecal = function(special, stageIdx, modId, update)
            local bias = 0
            if modId == "AddRandomCoreTile" and stageIdx <= 5 then
                bias = bias + weight["AddRandomCoreTile"][1] * (-0.4)
            end
            if modId == "NukeOnBonusStage" and stageIdx == 10 then
                bias = bias + 9.8
            end
            return bias
        end
    elseif name == "DQ5" then
        weight = {
            AddRandomCoreTile = {score(70), score(65)},
            TowersDamage = score({15, 15, 15}),
            TowersAttackSpeed = score({10, 10, 10}),
            CriticalDamage = score({10, 5, 5}),
            ExtraDamagePerBuff = score({30, 30, 30, 30, 30}),
            DebuffsLastLonger = score({7, 7, 7}),
            LightningStrikeOnTowerLevelUp = score({5, 4, 3}),
            AllAbilitiesForRandomTower = score({8, 8, 8}),
            SpawnZombiesFromBase = score({5, 5, 5}),
            TriggerRandomAbility = score({5, 5, 5}),
            AddAllAbilityCharges = score({0.35}),
            GV_TowersMaxExpLevel = score({50, 30, 18}),
            GV_MinersMaxUpgradeLevel = score({3, 2}),
            GV_AbilitiesMaxEnergy = score({5, 4}),
            DepositCoinsGeneration = score({2}),
            ReceiveCoins = score({1.5}),
            LastEnemiesInWaveDealNoDamage = score({0.35}),
            LowHpEnemiesDealNoDamage = score({0.5}),
            DoubleMiningSpeed = score({4}),
            FirstEnemiesInWaveExplode = score({4}),
            BaseExplodesOnEnemyPass = score({2}),
            BuildRandomMiner = score({4}),
            AddRandomPlatform = score({0.15}),
            MinersSpawnEnemies = score({-20}),
            SellAllTowers = score({-0.1}),
            IncreasedTowerToEnemyEfficiency_FREEZING_ARMORED = score({5, 4}),
            IncreasedTowerToEnemyEfficiency_FREEZING_ICY = score({4, 3}),
            IncreasedTowerToEnemyEfficiency_BLAST_ICY = score({5, 4}),
            IncreasedTowerToEnemyEfficiency_AIR_ARMORED = score({3, 2}),
            IncreasedTowerToEnemyEfficiency_AIR_HEALER = score({3, 2}),
            IncreasedTowerToEnemyEfficiency_TESLA_ARMORED = score({5, 4}),
            IncreasedTowerToEnemyEfficiency_FLAMETHROWER_HEALER = score({4, 3}),
            IncreasedTowerToEnemyEfficiency_FLAMETHROWER_ARMORED = score({6, 5}),
            NukeOnBonusStage = {0},
            GV_AbilitiesEnesgy_FIREBALL = {0},
            GV_AbilitiesEnergy_SMOKE_BOMB = {0},
            GV_AbilitiesEnesgy_FIRESTORM = {0}
        }
        weightSpecal = function(special, stageIdx, modId, update)
            local bias = 0
            if modId == "NukeOnBonusStage" and stageIdx == 10 then
                bias = bias + 9.8
            end
            if modId == "GV_AbilitiesEnesgy_FIREBALL" or modId == "GV_AbilitiesEnergy_SMOKE_BOMB" or modId ==
                "GV_AbilitiesEnesgy_FIRESTORM" then
                local k = (special.energy or 0) + 1 -- energy cost
                bias = bias + 7 / k
                if update then
                    special.energy = k
                end
            end
            return bias
        end
    elseif name == "DQ7" then
        weight = {
            AddRandomCoreTile = score({95, 165}),
            TowersDamage = score({15, 15, 15}),
            TowersAttackSpeed = score({10, 10, 10}),
            CriticalDamage = score({10, 5, 5}),
            ExtraDamagePerBuff = score({25, 25, 25, 25, 25}),
            DebuffsLastLonger = score({6, 5, 4}),
            LightningStrikeOnTowerLevelUp = score({6, 5, 4}),
            AllAbilitiesForRandomTower = score({7, 6, 5}),
            SpawnZombiesFromBase = score({6, 4}),
            AddAllAbilityCharges = score({5, 4, 0.1}),
            GV_TowersMaxExpLevel = score({3, 2, 1}),
            GV_MinersMaxUpgradeLevel = score({13, 13, 13}),
            DepositCoinsGeneration = score({2}),
            ReceiveCoins = score({1.5}),
            LastEnemiesInWaveDealNoDamage = score({0.15}),
            LowHpEnemiesDealNoDamage = score({0.07}),
            DoubleMiningSpeed = score({4}),
            FirstEnemiesInWaveExplode = score({2.5}),
            BaseExplodesOnEnemyPass = score({0.2}),
            BuildRandomMiner = score({4}),
            AddRandomPlatform = score({7, 4}),
            MinersSpawnEnemies = score({-50}),
            SellAllTowers = score({-0.1}),
            IncreasedTowerToEnemyEfficiency_FREEZING_ARMORED = score({4, 0.35}),
            IncreasedTowerToEnemyEfficiency_FLAMETHROWER_ARMORED = score({6, 5}),
            NukeOnBonusStage = {0}
        }
        weightSpecal = function(special, stageIdx, modId, update)
            local bias = 0
            if modId == "NukeOnBonusStage" and stageIdx == 10 then
                bias = bias + 7
            end
            if modId == "AddRandomCoreTile" and stageIdx <= 5 then
                bias = bias + weight["AddRandomCoreTile"][1] * (-0.3)
            end
            return bias
        end
    elseif name == "DQ8" then
        weight = {
            AddRandomCoreTile = score({75}),
            TowersDamage = score({15, 15, 15}),
            TowersAttackSpeed = score({6, 6, 6}),
            CriticalDamage = score({10, 5, 5}),
            ExtraDamagePerBuff = score({30, 30, 30, 30, 30}),
            DebuffsLastLonger = score({12, 12, 12}),
            LightningStrikeOnTowerLevelUp = score({6, 4, 2}),
            AllAbilitiesForRandomTower = score({7, 6}),
            SpawnZombiesFromBase = score({3, 2}),
            GV_TowersMaxExpLevel = score({20, 1, 0.1}),
            GV_MinersMaxUpgradeLevel = score({6, 1, 0.1}),
            DepositCoinsGeneration = score({2}),
            ReceiveCoins = score({1.5}),
            LastEnemiesInWaveDealNoDamage = score({0.35}),
            LowHpEnemiesDealNoDamage = score({0.35}),
            DoubleMiningSpeed = score({3}),
            FirstEnemiesInWaveExplode = score({4}),
            BaseExplodesOnEnemyPass = score({1.5}),
            BuildRandomMiner = score({3}),
            AddRandomPlatform = score({3}),
            MinersSpawnEnemies = score({-50}),
            SellAllTowers = score({-0.1}),
            NukeOnBonusStage = {0}
        }
        weightSpecal = function(special, stageIdx, modId, update)
            local bias = 0
            if modId == "AddRandomCoreTile" and stageIdx <= 5 then
                bias = bias + weight["AddRandomCoreTile"][1] * (-0.4) -- 40%
            end
            if modId == "NukeOnBonusStage" and stageIdx == 10 then
                bias = bias + 11.1 -- 8%
            end
            -- if modId == "SellAllTowers" and stageIdx == 1 then
            --     bias = bias + weight["SellAllTowers"][1] * (-0.9)
            -- end
            return bias
        end
    elseif name == "DQ9" then
        weight = {
            AddRandomCoreTile = score({75}),
            TowersDamage = score({15, 15, 15}),
            TowersAttackSpeed = score({12, 12, 12}),
            CriticalDamage = score({10, 5, 5}),
            ExtraDamagePerBuff = score({20, 20, 20, 20, 20}),
            DebuffsLastLonger = score({8, 8, 8}),
            LightningStrikeOnTowerLevelUp = score({3, 2, 1}),
            AllAbilitiesForRandomTower = score({18, 14, 5}),
            SpawnZombiesFromBase = score({9, 2, 7}),
            DepositCoinsGeneration = score({2}),
            ReceiveCoins = score({1.5}),
            LastEnemiesInWaveDealNoDamage = score({0.35}),
            LowHpEnemiesDealNoDamage = score({0.5}),
            DoubleMiningSpeed = score({4}),
            FirstEnemiesInWaveExplode = score({4}),
            BaseExplodesOnEnemyPass = score({2}),
            BuildRandomMiner = score({4}),
            AddRandomPlatform = score({0.15}),
            MinersSpawnEnemies = score({-50}),
            SellAllTowers = score({-0.1}),
            IncreasedTowerToEnemyEfficiency_SPLASH_REGULAR = score({6, 5, 4}),
            IncreasedTowerToEnemyEfficiency_SPLASH_ARMORED = score({8, 7, 6}),
            NukeOnBonusStage = {0},
            addAbilityCharges = {0},
            MultiplyMdps = {0}
        }
        weightSpecal = function(special, stageIdx, modId, update)
            local bias = 0
            if modId == "AddRandomCoreTile" and stageIdx <= 5 then
                bias = bias - score(75) + score(40)
            end
            if modId == "AddRandomCoreTile" then
                bias = bias + 10 - 2 * stageIdx -- 15%
            end
            if modId == "NukeOnBonusStage" and stageIdx == 10 then
                bias = bias + score(8)
            end
            if modId == "addAbilityCharges" and stageIdx >= 4 then
                bias = bias + 2 + stageIdx * 0.5 -- 3.5%
            end
            if modId == "MultiplyMdps" and stageIdx == 10 then
                bias = bias + score(11.5)
            end
            return bias
        end
    elseif name == "DQ10" then
        weight = {
            AddRandomCoreTile = score({80}),
            TowersDamage = score({15, 15, 15}),
            TowersAttackSpeed = score({15, 15, 15}),
            CriticalDamage = score({10, 5, 5}),
            ExtraDamagePerBuff = score({10, 10, 10, 10, 10}),
            DebuffsLastLonger = score({3, 2.5, 2}),
            LightningStrikeOnTowerLevelUp = score({4, 3, 2}),
            AllAbilitiesForRandomTower = score({10, 10}),
            SpawnZombiesFromBase = score({5, 3}),
            AddAllAbilityCharges = score({8}),
            DepositCoinsGeneration = score({2}),
            ReceiveCoins = score({1.5}),
            GV_AbilitiesMaxEnergy = score({0.07}),
            LastEnemiesInWaveDealNoDamage = score({0.35}),
            LowHpEnemiesDealNoDamage = score({0.35}),
            DoubleMiningSpeed = score({3}),
            FirstEnemiesInWaveExplode = score({3, 2}),
            BaseExplodesOnEnemyPass = score({8, 8, 8}),
            BuildRandomMiner = score({3}),
            AddRandomPlatform = score({0.07}),
            MultiplyMdps = score({0.07}),
            MinersSpawnEnemies = score({-50}),
            SellAllTowers = score({-0.1}),
            IncreasedTowerToEnemyEfficiency_BASIC_ICY = score({20, 7}),
            IncreasedTowerToEnemyEfficiency_BASIC_ARMORED = score({40, 11}),
            NukeOnBonusStage = {0}
        }
        weightSpecal = function(special, stageIdx, modId, update)
            local bias = 0
            if modId == "AddRandomCoreTile" and stageIdx <= 5 then
                bias = bias + weight["AddRandomCoreTile"][1] * (-0.2)
            end
            if modId == "AddRandomCoreTile" then
                bias = bias + 8 - 2 * stageIdx
            end
            if modId == "NukeOnBonusStage" and stageIdx == 10 then
                bias = bias + 5.7
            end
            return bias
        end
    elseif name == "DQ11" then
        weight = {
            AddRandomCoreTile = score({60}),
            TowersDamage = score({15, 15, 15}),
            TowersAttackSpeed = score({5, 5, 5}),
            CriticalDamage = score({10, 5, 5}),
            ExtraDamagePerBuff = score({12, 12, 12, 12, 12}),
            DebuffsLastLonger = score({7, 6, 5}),
            LightningStrikeOnTowerLevelUp = score({4, 3, 2}),
            AllAbilitiesForRandomTower = score({20, 7, 4}),
            SpawnZombiesFromBase = score({6, 5}),
            DepositCoinsGeneration = score({2, 1.5}),
            ReceiveCoins = score({1.5, 1}),
            LastEnemiesInWaveDealNoDamage = score({0.35}),
            LowHpEnemiesDealNoDamage = score({0.35}),
            DoubleMiningSpeed = score({3}),
            FirstEnemiesInWaveExplode = score({4}),
            BaseExplodesOnEnemyPass = score({4, 3, 2}),
            BuildRandomMiner = score({3}),
            AddRandomPlatform = score({0.15}),
            MinersSpawnEnemies = score({-50}),
            SellAllTowers = score({-0.1}),
            IncreasedTowerToEnemyEfficiency_MINIGUN_STRONG = score({8, 5, 2}),
            IncreasedTowerToEnemyEfficiency_FLAMETHROWER_HEALER = score({5, 3}),
            NukeOnBonusStage = {0}
        }
        weightSpecal = function(special, stageIdx, modId, update)
            local bias = 0
            if modId == "AddRandomCoreTile" and stageIdx <= 5 then
                bias = bias + weight["AddRandomCoreTile"][1] * (-0.1)
            end
            if modId == "AddRandomCoreTile" then
                bias = bias + 10 - 2.4 * stageIdx
            end
            if modId == "NukeOnBonusStage" and stageIdx == 10 then
                bias = bias + 11.1
            end
            if modId == "AllAbilitiesForRandomTower" and special.ability == nil then
                bias = bias + 3 - 0.6 * stageIdx
                if update then
                    special.ability = stageIdx
                end
            end
            -- if modId == "SellAllTowers" and stageIdx <= 2 then
            --     bias = bias + weight["SellAllTowers"][1] * (-1)
            -- end
            return bias
        end
    elseif name == "DQ12" then
        weight = {
            AddRandomCoreTile = score({70}),
            TowersDamage = score({15, 15, 15}),
            TowersAttackSpeed = score({10, 10, 10}),
            CriticalDamage = score({10, 5, 5}),
            ExtraDamagePerBuff = score({25, 25, 25, 25, 25}),
            DebuffsLastLonger = score({7, 7, 7}),
            LightningStrikeOnTowerLevelUp = score({30, 30, 30}),
            AllAbilitiesForRandomTower = score({4, 3, 2}),
            SpawnZombiesFromBase = score({6, 5, 4}),
            GV_TowersMaxExpLevel = score({2, 0.35}),
            GV_MinersMaxUpgradeLevel = score({10, 4, 1}),
            DepositCoinsGeneration = score({2}),
            ReceiveCoins = score({1.5}),
            LastEnemiesInWaveDealNoDamage = score({0.35}),
            LowHpEnemiesDealNoDamage = score({0.5}),
            DoubleMiningSpeed = score({3}),
            FirstEnemiesInWaveExplode = score({4, 3, 3}),
            BaseExplodesOnEnemyPass = score({4, 3, 3}),
            BuildRandomMiner = score({3}),
            AddRandomPlatform = score({0.15}),
            MinersSpawnEnemies = score({-50}),
            SellAllTowers = score({-0.1}),
            IncreasedTowerToEnemyEfficiency_FREEZING_ARMORED = score({4, 3}),
            IncreasedTowerToEnemyEfficiency_FREEZING_ICY = score({4, 3}),
            IncreasedTowerToEnemyEfficiency_FLAMETHROWER_HEALER = score({3, 2}),
            IncreasedTowerToEnemyEfficiency_FLAMETHROWER_ARMORED = score({5, 4}),
            NukeOnBonusStage = {0}
        }
        weightSpecal = function(special, stageIdx, modId, update)
            local bias = 0
            if modId == "AddRandomCoreTile" and stageIdx <= 5 then
                bias = bias + weight["AddRandomCoreTile"][1] * (-0.3)
            end
            if modId == "AddRandomCoreTile" then
                bias = bias + 8 - stageIdx * 1.8
            end
            if modId == "AllAbilitiesForRandomTower" and stageIdx == 10 then
                bias = bias + 16.3
            end
            if modId == "NukeOnBonusStage" and stageIdx == 10 then
                bias = bias + 11.1
            end
            return bias
        end
    else
    end
    local infos = {}
    for modId, info in pairs(weight) do
        for power, score in ipairs(info) do
            infos[#infos + 1] = {
                modId = modId,
                power = power,
                score = score
            }
        end
    end
    table.sort(infos, function(a, b)
        return a.score > b.score
    end)
    keyWeight = {}
    for i = 1, 16 do
        keyWeight[i] = infos[i]
    end
    local scoresAll = {}
    for i, info in ipairs(infos) do
        if #scoresAll >= 3 * 3 then
            break
        end
        if info.power > 1 and info.modId ~= "AddRandomCoreTile" then
            scoresAll[#scoresAll + 1] = info.score
        end
    end
    for i = 1, 3 do
        keyWeight[#keyWeight + 1] = {
            modId = "IncreaseSelectedBonusesPower",
            power = i,
            score = scoresAll[i * 3 - 2] + scoresAll[i * 3 - 1] + scoresAll[i * 3]
        }
    end
    table.sort(keyWeight, function(a, b)
        return a.score > b.score
    end)
    for i, info in ipairs(keyWeight) do
        if i > 10 then
            info.modId = nil
        end
    end
end

local function DFS(dqName, seed)
    local isDQ8 = dqName == "DQ8"
    local dqLevel = C.Game.i.basicLevelManager:getLevel(dqName)
    dqLevel.bonusStagesConfig.seed = seed
    dqLevel.bonusStagesConfig:setBonusesConfig(C.JsonReader.new():parse(
        '{"DoubleMiningSpeed": {"zeroProbabilityOnDuration": 1000},"AddAllAbilityCharges": {"maxCurrentCharges": 20},"AllAbilitiesForRandomTower": {"minSuitableTowersOnMap": 1},"BoostExistingEnemiesWithLoot": {"minEnemyCount": 0}}'))

    local S = C.GameSystemProvider.new(C.SystemsConfig.new(C.Setup.GAME, true):disableScripts())
    S:createSystems()
    C.GameScreen:configureSystemsBeforeSetup(S, dqLevel:getMap():getMaxedAbilitiesConfiguration(), false, false, false,
        C.Game:getTimestampMillis(), dqLevel, nil, C.DifficultyMode.NORMAL, 100, C.GameMode.BASIC_LEVELS, nil,
        C.Game.i.progressManager:createProgressSnapshotForState(), C.Game.i.progressManager:getInventoryStatistics(),
        nil)
    S:setupSystems()
    S:postSetupSystems()

    S.gameState.inUpdateStage = true
    S.damage:setTowersMaxDps(1)
    S.gameState:addMoney(100000, true)
    S.gameState:addHealth(10000)
    S.ability:addAbilityCharges(0, S.ability:getAvailableAbilities(0) * (-1) + 1)

    -- local map = S.map:getMap()
    -- for x = 0, map:getWidth() - 1 do
    --     for y = 0, map:getHeight() - 1 do
    --         local tile = map:getTile(x, y)
    --         if tile ~= nil and tile.type ~= C.TileType.CORE and tile.type ~= C.TileType.SPAWN and tile.type ~=
    --             C.TileType.TARGET then
    --             map:setTile(x, y, nil)
    --         end
    --     end
    -- end
    local musicTile = S.map:getMap():getMusicTile()
    if musicTile ~= nil then
        S.map:getMap():setTile(musicTile:getX(), musicTile:getY(), nil)
    end
    -- plat,mine
    local platFactory = C.PlatformTile.SpaceTileFactory.new()
    local sourceFactory = C.SourceTile.SourceTileFactory.new()
    for i = 0, 3 do
        local plat = platFactory:create()
        S.map:setTile(i, 0, plat)
        S.tower:buildTowerIgnorePrice(C.TowerType.BASIC, nil, i, 0, i ~= 0)
    end
    for i = 4, 7 do
        local source = sourceFactory:create()
        source:setResourcesCount(C.ResourceType.SCALAR, 100)
        S.map:setTile(i, 0, source)
    end
    S.miner:buildMiner(C.MinerType.SCALAR, 4, 0, false, false)
    S.bonus:addProgressPoints(2000)

    if (maxStage or 0) == 0 then
        maxStage = S.bonus:getStagesConfig():getMaxStages()
    end
    local scoreRecord = scoreRecordInit
    local stateProto = {
        currentStage = 1,
        currentSelectionCount = #S.bonus:getBonusStage(1):getBonusesToChooseFrom(),
        rerollChances = S.bonus:getStagesConfig():getMaxReRollsAllTime(),
        S = S,
        seqIdx = {},
        seqBonus = {},
        bonusPower = {},
        bonusScore = {},
        currentScore = 0,
        bonusBeforeReroll = {},
        special = {},
        bounty = maxStage
    }
    local function deepcopy(orig)
        local seen = {}
        local function copy(t)
            if type(t) ~= "table" then
                return t
            end
            if seen[t] then
                return seen[t]
            end
            local res = {}
            seen[t] = res
            for k, v in pairs(t) do
                res[copy(k)] = copy(v)
            end
            return setmetatable(res, getmetatable(t))
        end
        return copy(orig)
    end
    if not useCachedSeq or seqStorage == nil then
        seqStorage = {}
    end
    local function saveState(state, idx, bonus, score, scorePartition)
        if score > scoreRecord then
            scoreRecord = score
        end
        local power = deepcopy(state.bonusPower)
        local scores = deepcopy(state.bonusScore)
        for modId, score in pairs(scorePartition) do
            power[modId] = (power[modId] or 0) + 1
            scores[modId] = (scores[modId] or 0) + score
        end
        local summary = {}
        for modId, score in pairs(scores) do
            if modId ~= "AddRandomCoreTile" and bonusName[modId] ~= nil then
                summary[#summary + 1] = {
                    modId = modId,
                    score = score,
                    power = power[modId]
                }
            end
        end
        table.sort(summary, function(a, b)
            return a.score > b.score
        end)
        local coresInfo = {}
        for stageIdx, mods in pairs(state.seqBonus) do
            for _, modId in ipairs(mods) do
                if modId == "AddRandomCoreTile" then
                    if stageIdx <= 5 then
                        coresInfo[#coresInfo + 1] = 1
                    elseif stageIdx <= 10 then
                        coresInfo[#coresInfo + 1] = 2
                    else
                        coresInfo[#coresInfo + 1] = 3
                    end
                end
            end
        end
        for _, modId in ipairs(bonus) do
            if modId == "AddRandomCoreTile" then
                if state.currentStage <= 5 then
                    coresInfo[#coresInfo + 1] = 1
                elseif state.currentStage <= 10 then
                    coresInfo[#coresInfo + 1] = 2
                else
                    coresInfo[#coresInfo + 1] = 3
                end
            end
        end
        local seq = {
            idx = deepcopy(state.seqIdx),
            bonus = deepcopy(state.seqBonus),
            score = deepcopy(state.currentScore),
            bounty = deepcopy(state.bounty),
            summary = deepcopy(summary),
            power = deepcopy(power),
            coresInfo = deepcopy(coresInfo)
        }
        seq.idx[state.currentStage] = idx
        seq.bonus[state.currentStage] = bonus
        seq.score = score
        seqStorage[#seqStorage + 1] = seq
    end
    local function calculateSeqScore(seq)
        local score = 0
        local special = {}
        local power = {}
        for stageIdx, mods in ipairs(seq.bonus) do
            for _, modId in ipairs(mods) do
                if weight[modId] ~= nil then
                    power[modId] = (power[modId] or 0) + 1
                    score = score + weight[modId][math.min(power[modId], #weight[modId])] +
                                weightSpecal(special, stageIdx, modId, true)
                end
            end
        end
        if isDQ8 then
            if seq.bounty < 3 then
                score = score + seq.bounty - 3
            elseif seq.bounty > 7 then
                score = score + 7 - seq.bounty
            end
        end
        return score
    end
    local function outputSeqs()
        if useCachedSeq then
            scoreRecord = scoreRecordInit
            for _, seq in ipairs(seqStorage) do
                local score = calculateSeqScore(seq)
                seq.score = score
                if score > scoreRecord then
                    scoreRecord = score
                end
            end
        end
        table.sort(seqStorage, function(a, b)
            return a.score > b.score
        end)
        local file = C.SFileHandle.new("cache/script-data/" .. dqName .. os.date("_%m_%d", seed) .. ".txt")
        file:writeString("0\tIndex      \t  *\t  Score\tCode\tVar\tBounty\n", false)
        local stageStr = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "a"}
        local summaryThreshold = scoreRecord / (maxStage * 3)
        for rank = 1, #seqStorage do
            local seq = seqStorage[rank]

            local strIndex = table.concat(seq.idx)
            strIndex = strIndex:sub(1, 5) .. " " .. strIndex:sub(6, #strIndex)

            local strCovered = "*"
            for i = 1, rank - 1 do
                local x = seqStorage[i]
                local ok = false
                if not ok then
                    local cores = {0, 0}
                    for _, type in ipairs(seq.coresInfo) do
                        cores[type] = cores[type] + 1
                    end
                    for _, type in ipairs(x.coresInfo) do
                        cores[type] = cores[type] - 1
                    end
                    for _, i in ipairs(cores) do
                        if i > 0 then
                            ok = true
                            break
                        end
                    end
                end
                if not ok then
                    for _, summary in ipairs(seq.summary) do
                        if summary.score > summaryThreshold * 2 then
                            local modId = summary.modId
                            if modId ~= "IncreaseSelectedBonusesPower" and seq.power[modId] > (x.power[modId] or 0) then
                                ok = true
                                break
                            end
                        end
                    end
                end
                if not ok then
                    strCovered = " "
                    break
                end
            end

            local strSummary = ""
            for _, type in ipairs(seq.coresInfo) do
                strSummary = strSummary .. coreType[type]
            end
            for _, summary in ipairs(seq.summary) do
                if summary.score > summaryThreshold or summary.score < 0 then
                    strSummary = strSummary .. tostring(summary.power) .. bonusName[summary.modId]
                end
            end

            local strDetail = ""
            local selectLevels = {}
            for stageIdx, mods in pairs(seq.bonus) do
                for _, modId in ipairs(mods) do
                    selectLevels[modId] = (selectLevels[modId] or "") .. stageStr[stageIdx]
                end
            end
            for stageIdx, mods in pairs(seq.bonus) do
                for _, modId in ipairs(mods) do
                    if bonusName[modId] ~= nil and selectLevels[modId] ~= nil then
                        strDetail = strDetail .. selectLevels[modId] .. bonusName[modId]
                        selectLevels[modId] = nil
                    end
                end
            end

            local str = tostring(rank) .. "\t" .. strIndex .. "\t  " .. strCovered .. "\t  " ..
                            tostring(math.floor(seq.score * 10) / 10) .. "\t" .. strSummary .. "\t" .. strDetail
            if isDQ8 then
                str = str .. "\t" .. tostring(seq.bounty)
            end
            str = str .. "\n"

            file:writeString(str, true)

            if (not useCachedSeq) and seq.score + scoreThreshhold < scoreRecord then
                for i = #seqStorage, rank, -1 do
                    table.remove(seqStorage, i)
                end
                break
            end
        end
    end
    local function addBounty(state)
        state.bounty = state.currentStage
        local targetTile = state.S.map:getMap():getTargetTileOrThrow()
        targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MODIFIER_BOUNTY_COUNT, 3, true, true))
        state.S.gameValue:setGlobalSnapshot(nil)
        state.S.gameValue:recalculate()
    end
    local function canReroll(state)
        return state.rerollChances > 0 and next(state.bonusBeforeReroll) == nil
    end
    local function reroll(state)
        local stage = state.S.bonus:getBonusStage(state.currentStage)
        for i = 1, state.currentSelectionCount do
            state.bonusBeforeReroll[i] = stage:getBonusesToChooseFrom():get(i - 1):getId()
        end
        state.rerollChances = state.rerollChances - 1
        state.S.bonus:reRollBonuses()
    end
    local function select(state, i)
        local stageIdx = state.currentStage
        if next(state.bonusBeforeReroll) == nil then
            state.seqIdx[stageIdx] = i
        else
            state.seqIdx[stageIdx] = i + state.currentSelectionCount
        end

        local modId = state.S.bonus:getBonusStage(stageIdx):getBonusesToChooseFrom():get(i - 1):getId()
        state.bonusPower[modId] = (state.bonusPower[modId] or 0) + 1
        local seqBonus = {modId}
        if weight[modId] ~= nil then
            local score = weight[modId][math.min(state.bonusPower[modId], #weight[modId])] +
                              weightSpecal(state.special, stageIdx, modId, true)
            state.bonusScore[modId] = (state.bonusScore[modId] or 0) + score
            state.currentScore = state.currentScore + score
        end
        state.S.bonus:setSelectedBonus(stageIdx, i - 1)
        if modId == "SellAllTowers" then
            state.S.tower:buildTowerIgnorePrice(C.TowerType.BASIC, nil, 0, 0, false)
        elseif modId == "IncreaseSelectedBonusesPower" then
            for j = 0, #state.S.gameplayMod:getActiveMods() - 1 do
                local mod = state.S.gameplayMod:getActiveMods():get(j):getMod()
                if not mod.powerLevelsUpgradedByMods:isEmpty() then
                    local modId = mod:getId()
                    state.bonusPower[modId] = (state.bonusPower[modId] or 0) + 1
                    seqBonus[#seqBonus + 1] = modId
                    if weight[modId] ~= nil then
                        local score = weight[modId][math.min(state.bonusPower[modId], #weight[modId])] +
                                          weightSpecal(state.special, stageIdx, modId, true)
                        state.bonusScore[modId] = (state.bonusScore[modId] or 0) + score
                        state.currentScore = state.currentScore + score
                    end
                    mod.powerLevelsUpgradedByMods:clear()
                end
            end
        end
        state.seqBonus[stageIdx] = seqBonus
        state.currentStage = stageIdx + 1
        state.currentSelectionCount = #state.S.bonus:getBonusStage(state.currentStage):getBonusesToChooseFrom()
        state.bonusBeforeReroll = {}
    end
    local function zipState(x)
        local y = {
            seqIdx = deepcopy(x.seqIdx),
            rerolled = next(x.bonusBeforeReroll) ~= nil,
            bounty = deepcopy(x.bounty)
        }
        return y
    end
    local buffer = C.Output.new_i(65536)
    S:serialize(buffer)
    buffer = buffer:getBuffer()
    local bytes = {}
    for i = 1, #buffer do
        bytes[i] = (buffer[i] + 256) % 256
    end
    buffer = com.esotericsoftware.kryo.io.Input.class.new_byteArr(string.char(table.unpack(bytes, 1, #bytes)))
    local function unzipState(x)
        buffer:setPosition(0)
        local y = {
            currentStage = deepcopy(stateProto.currentStage),
            currentSelectionCount = deepcopy(stateProto.currentSelectionCount),
            rerollChances = deepcopy(stateProto.rerollChances),
            S = C.GameSystemProvider:unserialize(buffer),
            seqIdx = deepcopy(stateProto.seqIdx),
            seqBonus = deepcopy(stateProto.seqBonus),
            bonusPower = deepcopy(stateProto.bonusPower),
            bonusScore = deepcopy(stateProto.bonusScore),
            currentScore = deepcopy(stateProto.currentScore),
            bonusBeforeReroll = deepcopy(stateProto.bonusBeforeReroll),
            bounty = deepcopy(stateProto.bounty),
            special = deepcopy(stateProto.special)
        }
        y.S.gameState.inUpdateStage = true
        for stageIdx, i in ipairs(x.seqIdx) do
            if isDQ8 and stageIdx == x.bounty then
                if stageIdx < 3 then
                    local score = stageIdx - 3
                    y.currentScore = y.currentScore + score
                elseif stageIdx > 7 then
                    local score = 7 - stageIdx
                    y.currentScore = y.currentScore + score
                end
                addBounty(y)
            end
            if i > y.currentSelectionCount then
                reroll(y)
                select(y, i - y.currentSelectionCount)
            else
                select(y, i)
            end
        end
        if x.rerolled then
            reroll(y)
        end
        if isDQ8 and y.currentStage == x.bounty then
            if y.currentStage < 3 then
                local score = y.currentStage - 3
                y.currentScore = y.currentScore + score
            elseif y.currentStage > 7 then
                local score = 7 - y.currentStage
                y.currentScore = y.currentScore + score
            end
        end
        return y
    end
    local function copyState(x)
        -- local t = zipState(x)
        -- local y = unzipState(t)
        local y = {
            currentStage = deepcopy(x.currentStage),
            currentSelectionCount = deepcopy(x.currentSelectionCount),
            rerollChances = deepcopy(x.rerollChances),
            S = x.S:deepCopy(),
            seqIdx = deepcopy(x.seqIdx),
            seqBonus = deepcopy(x.seqBonus),
            bonusPower = deepcopy(x.bonusPower),
            bonusScore = deepcopy(x.bonusScore),
            currentScore = deepcopy(x.currentScore),
            bonusBeforeReroll = deepcopy(x.bonusBeforeReroll),
            bounty = deepcopy(x.bounty),
            special = deepcopy(x.special)
        }
        y.S.gameState.inUpdateStage = true
        return y
    end
    local function calculateScore(state)
        local stageIdx = state.currentStage
        local n = state.currentSelectionCount
        for i = 1, n do
            local bonuses = state.S.bonus:getBonusStage(stageIdx):getBonusesToChooseFrom()
            local mod = bonuses:get(i - 1)
            local modId = mod:getId()
            local duplicate = false
            for _, i in ipairs(state.bonusBeforeReroll) do
                if i == modId then
                    duplicate = true
                    break
                end
            end
            if not duplicate then
                local score = state.currentScore
                local seqBonus = {modId}
                local scores = {}
                if modId == "IncreaseSelectedBonusesPower" then
                    local backupALL = copyState(state)
                    state.S.bonus:setSelectedBonus(stageIdx, i - 1)
                    for j = 0, #state.S.gameplayMod:getActiveMods() - 1 do
                        local mod = state.S.gameplayMod:getActiveMods():get(j):getMod()
                        local modId = mod:getId()
                        if not mod.powerLevelsUpgradedByMods:isEmpty() then
                            seqBonus[#seqBonus + 1] = modId
                            if weight[modId] ~= nil then
                                local t = weight[modId][math.min(mod.power, #weight[modId])] +
                                              weightSpecal(state.special, stageIdx, modId, false)
                                score = score + t
                                scores[modId] = t
                            end
                        end
                    end
                    state = backupALL
                elseif weight[modId] ~= nil then
                    local power = 1
                    local aMod = state.S.gameplayMod:getActiveMod(mod:getClass())
                    if aMod ~= nil then
                        power = 1 + aMod:getMod().power
                    end
                    local t = weight[modId][math.min(power, #weight[modId])] +
                                  weightSpecal(state.special, stageIdx, modId, false)
                    score = score + t
                    scores[modId] = t
                end
                if score + scoreThreshhold >= scoreRecord then
                    if next(state.bonusBeforeReroll) == nil then
                        saveState(state, i, seqBonus, score, scores)
                    else
                        saveState(state, i + n, seqBonus, score, scores)
                    end
                end
            end
        end
    end
    local function calculatePotentials(state)
        local scores = {}
        local stageIdx = state.currentStage
        local n = state.currentSelectionCount
        local bonuses = state.S.bonus:getBonusStage(stageIdx):getBonusesToChooseFrom()
        for i = 1, n do
            local mod = bonuses:get(i - 1)
            local modId = mod:getId()
            local duplicate = false
            for _, i in ipairs(state.bonusBeforeReroll) do
                if i == modId then
                    duplicate = true
                    break
                end
            end
            if not duplicate then
                local score = state.currentScore
                if modId == "IncreaseSelectedBonusesPower" then
                    local stageI = stageIdx
                    for _, info in ipairs(keyWeight) do
                        local power = (state.bonusPower[info.modId] or 0)
                        if power < info.power then
                            score = score + info.score
                            if stageI == maxStage then
                                break
                            end
                            stageI = stageI + 1
                        end
                    end
                else
                    if weight[modId] ~= nil then
                        local power = 1
                        local aMod = state.S.gameplayMod:getActiveMod(mod:getClass())
                        if aMod ~= nil then
                            power = 1 + aMod:getMod().power
                        end
                        score = score + weight[modId][math.min(power, #weight[modId])]
                        score = score + weightSpecal(state.special, stageIdx, modId, false)
                    end
                    local stageI = stageIdx + 1
                    for _, info in ipairs(keyWeight) do
                        local power = (state.bonusPower[info.modId] or 0)
                        if modId == info.modId then
                            power = power + 1
                        end
                        if power < info.power then
                            score = score + info.score
                            if stageI == maxStage then
                                break
                            end
                            stageI = stageI + 1
                        end
                    end
                end
                if score + scoreThreshhold >= scoreRecord then
                    scores[i] = score
                end
            end
        end
        return scores
    end

    local function visitState(state)
        if state.currentStage == maxStage then
            if isDQ8 and state.bounty == maxStage then
                if state.currentStage < 3 then
                    local score = state.currentStage - 3
                    state.currentScore = state.currentScore + score
                elseif state.currentStage > 7 then
                    local score = 7 - state.currentStage
                    state.currentScore = state.currentScore + score
                end
            end
            if canReroll(state) then
                local stateTemp = copyState(state)
                calculateScore(stateTemp)
                reroll(state)
            end
            calculateScore(state)
            return
        end
        if state.currentStage == 3 then
            logger:e(tostring(scoreRecord), state.seqIdx[1], state.seqIdx[2])
            outputSeqs()
        end

        local potentials = calculatePotentials(state)
        if isDQ8 and state.bounty == maxStage then
            for i, _ in pairs(potentials) do
                local stateTemp = copyState(state)
                addBounty(stateTemp)
                if stateTemp.currentStage < 3 then
                    local score = stateTemp.currentStage - 3
                    state.currentScore = state.currentScore + score
                elseif stateTemp.currentStage > 7 then
                    local score = 7 - stateTemp.currentStage
                    state.currentScore = state.currentScore + score
                end
                select(stateTemp, i)
                visitState(stateTemp)
            end
        end
        if canReroll(state) then
            for i, _ in pairs(potentials) do
                local stateTemp = copyState(state)
                select(stateTemp, i)
                visitState(stateTemp)
            end
            reroll(state)
            potentials = calculatePotentials(state)
            if isDQ8 and state.bounty == maxStage then
                for i, _ in pairs(potentials) do
                    local stateTemp = copyState(state)
                    addBounty(stateTemp)
                    if stateTemp.currentStage < 3 then
                        local score = stateTemp.currentStage - 3
                        state.currentScore = state.currentScore + score
                    elseif stateTemp.currentStage > 7 then
                        local score = 7 - stateTemp.currentStage
                        state.currentScore = state.currentScore + score
                    end
                    select(stateTemp, i)
                    visitState(stateTemp)
                end
            end
        end
        if next(potentials) ~= nil then
            local count = 0
            for _ in pairs(potentials) do
                count = count + 1
            end
            for i, _ in pairs(potentials) do
                count = count - 1
                if count == 0 then
                    select(state, i)
                    visitState(state)
                else
                    local stateTemp = copyState(state)
                    select(stateTemp, i)
                    visitState(stateTemp)
                end
            end
        end
    end
    logger:e("--------------------------------------------------------------------------------")
    logger:e("Start running " .. dqName)
    if not useCachedSeq then
        local state = copyState(stateProto)
        visitState(state)
        logger:e("Top score of " .. dqName .. ": " .. tostring(scoreRecord))
    else
        logger:e("Recalculated scores of " .. dqName)
    end
    outputSeqs()
end

local mainThread = C.Thread.new_R(C.Runnable(function()
    local timestamp = nil
    -- timestamp = math.floor(os.time() / (24 * 60 * 60)) * (24 * 60 * 60)
    C.Game.i.dailyQuestManager:getCurrentDayLevel(C.ObjectConsumer(function(level)
        if timestamp == nil then
            timestamp = level.forDateTimestamp
        end
        if dqs == nil then
            dqs = {level:getLevelName()}
        end
    end))
    local logger = C.TLog:forTag("Astar-headless")
    local threadCount = C.Runtime:getRuntime():availableProcessors()
    if threadCount < #dqs then
        logger.e("ERROR: threadCount not enough")
    end
    if dateBegin == nil then
        dateBegin = 0
    end
    if dateEnd == nil then
        dateEnd = dateBegin
    end
    for date = dateBegin, dateEnd do
        for _, dq in ipairs(dqs) do
            SetWeight(dq)
            DFS(dq, (timestamp + date * 24 * 60 * 60))
        end
    end

end))

C.LogLevel:setCurrent(C.LogLevel.ERROR)
mainThread:start()
mainThread:join()
C.LogLevel:setCurrent(C.LogLevel.INFO)
