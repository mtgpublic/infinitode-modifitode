if newPage ~= nil then
    local button_random_core =
        newToggle("随机核心", registerBool("random_core"), "3d-sphere-basic", nil, 0x00C0EAFF)

    local table = newPage(64)
    table:add(button_random_core):width(840):padLeft(60):height(64)

    C.Game.EVENTS:getListeners(C.GameLoad):add(C.Listener(function(_)
        registerValue("val_random_core_pqr")(C.Game.i.statisticsManager:getAllTime(C.StatisticsType.PQR))
    end))
    return
end

if not gameEnabled("random_core") then
    return
end
if S.gameState.dailyQuestLevel ~= nil then
    return
end

recordGuard("随机核心")

registerValue("val_random_core_pqr")(C.Game.i.statisticsManager:getAllTime(C.StatisticsType.PQR))
refreshModSettings()

local reward_level = 50
local num_cores = 4
local game_values = {}
local seed = 0
function rand(min, max)
    local ret = min + S.gameState:randomIntIndependent(max - min + 1, seed)
    seed = seed + 1437
    return ret
end
function generateCore(index)
    if index > num_cores or index > 4 then
        return
    end
    local suffixs = {"X", "Y", "Z", "W"}
    local name =
        tostring(S.statistics:getStatistic(C.StatisticsType.PQR)) .. "." .. S.gameState.basicLevelName .. "." ..
            suffixs[index]
    local map = S.map:getMap()
    local values = {{{2, 1}, {2, 2}, {3, 1}, {3, 2}, {2, 3}, {2, 4}, {3, 3}, {3, 4}, {1, 1}, {1, 2}, {1, 3}, {1, 4},
                     {4, 1}, {4, 2}, {5, 1}, {5, 2}, {4, 3}, {4, 4}, {5, 3}, {5, 4}},
                    {{6, 1}, {6, 2}, {7, 1}, {7, 2}, {6, 3}, {6, 4}, {7, 3}, {7, 4}, {1, 5}, {1, 6}, {1, 7}, {1, 8},
                     {8, 1}, {8, 2}, {9, 1}, {9, 2}, {8, 3}, {8, 4}, {9, 3}, {9, 4}},
                    {{10, 1}, {10, 2}, {11, 1}, {11, 2}, {10, 3}, {10, 4}, {11, 3}, {11, 4}, {1, 9}, {1, 10}, {1, 11},
                     {1, 12}, {12, 1}, {12, 2}, {13, 1}, {13, 2}, {12, 3}, {12, 4}, {13, 3}, {13, 4}},
                    {{14, 1}, {14, 2}, {15, 1}, {15, 2}, {14, 3}, {14, 4}, {15, 3}, {15, 4}, {1, 13}, {1, 14}, {1, 15},
                     {1, 16}, {16, 1}, {16, 2}, {17, 1}, {17, 2}, {16, 3}, {16, 4}, {17, 3}, {17, 4}}}
    local value_idx = values[index]
    for y = 1, map:getHeight() do
        for x = 1, map:getWidth() do
            if map:getTile(x - 1, y - 1) == nil then
                local dummy_core_json = C.JsonReader.new():parse(
                    '{"type": "CORE", "d": {"n": "RANDOM", "t": "LEGENDARY", "eg": 5.0, "flx": false, "u": [ {"s": false, "l": 16, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 0, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}, {"d": 0, "p": 20}]}, {"s": false, "l": 16, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 0, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}, {"d": 0, "p": 20}]}, {"s": false, "l": 18, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 2, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 18, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 2, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": true, "l": 82, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 16, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 82, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 16, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}, {"d": 0, "p": 10}]}, {"s": false, "l": 80, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 64, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 80, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 64, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 16, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 0, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}, {"d": 0, "p": 20}]}, {"s": false, "l": 16, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}]}, {"s": false, "l": 0, "gv": "DUMMY", "ul": [ {"d": 0, "p": 1}, {"d": 0, "p": 2}, {"d": 0, "p": 20}]}]}}')
                local random_core = C.Game.i.tileManager.F.CORE:fromJson(dummy_core_json)
                random_core:setName(name)
                for i_upgrade = 1, random_core:getUpgrades().size do
                    local game_value = game_values[value_idx[i_upgrade][1]][value_idx[i_upgrade][2]]
                    local upgrade = random_core:getUpgrades():get(i_upgrade - 1)
                    upgrade:setGameValueType(game_value.type)
                    upgrade.upgradeLevels:get(0).delta = game_value.values[1]
                    upgrade.upgradeLevels:get(1).delta = game_value.values[2]
                    if #upgrade.upgradeLevels == 3 then
                        upgrade.upgradeLevels:get(2).delta = game_value.values[3]
                        if #game_value.values == 4 then
                            upgrade.upgradeLevels:get(2).price = upgrade.upgradeLevels:get(2).price / 2
                        end
                    end
                end
                S.map:setTile(x - 1, y - 1, random_core)
                S.events:getListeners(C.CoreTileLevelUp):addStateAffecting(C.Listener(function(event)
                    local core = event:getCoreTile()
                    if core:sameAs(random_core) and core:getLevel() == reward_level then
                        local stack = C.ItemStack.new_I_i(C.D.F_TILE:create(core), 1)
                        local v2 = C.Vector2.new_V2(core.center)
                        if S._input ~= nil then
                            S._input.cameraController:mapToStage(v2)
                        end
                        S.gameState:addLootIssuedPrizes(stack, v2.x, v2.y, 2)
                    end
                end))
                S.events:getListeners(C.CoreTileUpgradeInstall):addStateAffecting(C.Listener(function(event)
                    local core = event:getCoreTile()
                    if core:sameAs(random_core) and event:getCol() == 3 and event:getRow() == 2 and
                        core:getUpgradeInstallLevel(3, 2) == 1 then
                        generateCore(index + 1)
                    end
                end))
                return
            end
        end
    end
end
S.events:getListeners(C.SystemsPostSetup):addStateAffecting(C.Listener(function(_)
    game_values = {{ -- 全局加成目标：伤害x1.5
    {
        type = C.GameValueType.FORCED_WAVE_BONUS,
        values = {50, 125, 600} -- 需求占比0.1，偏后期，x1.5
    }, {
        type = C.GameValueType.WAVE_INTERVAL,
        values = {2, 5, 20} -- 需求出怪时间25，偏前期，x1.5
    }, {
        type = C.GameValueType.COINS_GENERATION,
        values = {30, 75, 300} -- 需求每波600，偏前期，x1.5
    }, {
        type = C.GameValueType.ENEMIES_SPEED,
        values = {-10, -20, -50} -- 需求群伤，x2
    }, {
        type = C.GameValueType.EXPLOSIONS_PIERCING,
        values = {5, 11, 28, 0} -- 需求穿2打3，上限
    }, {
        type = C.GameValueType.MINERS_SPEED,
        values = {10, 25, 100} -- 需求占比0.7，需求3过载，偏前期，x1.5
    }, {
        type = C.GameValueType.MINERS_MAX_UPGRADE_LEVEL,
        values = {0, 1, 7} -- 需求金币，x3.5
    }, {
        type = C.GameValueType.ABILITIES_MAX_ENERGY,
        values = {2, 5, 20} -- 需求技能次数，x3
    }, {
        type = C.GameValueType.ABILITIES_ENERGY_GENERATION_INTERVAL,
        values = {-5, -10, -30} -- 需求20秒1能量，持续时间x2
    }, {
        type = C.GameValueType.MODIFIER_SEARCH_RANGE_VALUE,
        values = {5, 13, 44} -- 需求圆形塔，x2
    }, {
        type = C.GameValueType.MODIFIER_ATTACK_SPEED_VALUE,
        values = {6, 14, 52} -- 需求2层，需求攻速，x1.8
    }, {
        type = C.GameValueType.MODIFIER_DAMAGE_VALUE,
        values = {4, 9, 35} -- 需求2层，x1.5
    }, {
        type = C.GameValueType.MODIFIER_BOUNTY_VALUE,
        values = {5, 13, 50} -- 需求占比0.5，偏前期，x1.5
    }, {
        type = C.GameValueType.MODIFIER_BOUNTY_PERCENT,
        values = {0.6, 1.5, 6, 0} -- 有上限，x4
    }, {
        type = C.GameValueType.MODIFIER_EXPERIENCE_VALUE,
        values = {1, 3, 10} -- 需求占比0.7，偏前期，x1.5
    }, {
        type = C.GameValueType.MODIFIER_MINING_SPEED_VALUE,
        values = {6, 15, 65} -- 需求占比0.7，需求1.5层，偏前期，x1.5
    }, {
        type = C.GameValueType.MODIFIER_POWER_VALUE,
        values = {3, 7, 35} -- 需求40功率，需求2层，偏前期，x1.5
    }, {
        type = C.GameValueType.TOWERS_STARTING_LEVEL,
        values = {3, 6, 19} -- 偏前期
    }, {
        type = C.GameValueType.TOWERS_EXPERIENCE_GENERATION,
        values = {0.8, 2, 10} -- 需求每秒20经验，偏前期，x1.5
    }, {
        type = C.GameValueType.TOWERS_UPGRADE_PRICE,
        values = {-5, -11, -33} -- x1.5
    }, {
        type = C.GameValueType.TOWERS_POWER_PER_LEVEL_AFTER_10,
        values = {0.08, 0.2, 0.8} -- 需求50级，偏后期，x1.5
    }, {
        type = C.GameValueType.TOWERS_POWERFUL_ABILITY_PWR,
        values = {7, 11, 30} -- 需求放弃大招1.33倍，x1.5
    }, {
        type = C.GameValueType.TOWERS_RANGE,
        values = {5, 13, 50} -- 需求圆形塔，x2.25
    }, {
        type = C.GameValueType.TOWERS_DAMAGE,
        values = {5, 13, 50} -- x1.5
    }, {
        type = C.GameValueType.TOWERS_ATTACK_SPEED,
        values = {8, 20, 80} -- 需求攻速，x1.8
    }}, { -- 塔加成目标：单塔直接伤害x10/全塔最终伤害x2
    {
        type = C.GameValueType.TOWER_BASIC_A_FOUNDATION_RICOCHET_CHANCE,
        values = {7, 16, 79} -- 需求子弹速度10.6，偏后期，x10
    }, {
        type = C.GameValueType.TOWER_BASIC_A_FOUNDATION_RICOCHET_SPEED,
        values = {4, 7, 65, 0} -- 有上限
    }, {
        type = C.GameValueType.TOWER_BASIC_A_SPECIAL_PWR_SHARE,
        values = {7, 18, 180} -- 需求等级50，需求3塔，偏后期，全局x2
    }, {
        type = C.GameValueType.TOWER_BASIC_A_COPY_COUNT,
        values = {1, 2, 7, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_BASIC_A_COPY_UPGRADE_LEVEL,
        values = {60, 160, 960, 0} -- 上限
    }}, {{
        type = C.GameValueType.TOWER_SNIPER_CRIT_MULTIPLIER,
        values = {20, 50, 1900} -- 需求暴击占比0.5，偏后期，x10
    }, {
        type = C.GameValueType.TOWER_SNIPER_A_PENETRATION_DAMAGE,
        values = {20, 50, 1940} -- 需求命中率0.7，x10
    }, {
        type = C.GameValueType.TOWER_SNIPER_A_SHORT_RANGE,
        values = {20, 50, 325, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_SNIPER_A_SHORT_CRIT_MULTIPLIER,
        values = {29, 69, 1200, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_SNIPER_A_KILLSHOT_HP,
        values = {10, 26, 76, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_SNIPER_A_KILLSHOT_INTERVAL,
        values = {-1, -2, -3, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_SNIPER_A_ULTIMATE_DAMAGE,
        values = {15, 35, 1360} -- 需求远距离，x15
    }, {
        type = C.GameValueType.TOWER_SNIPER_A_ULTIMATE_EXPL_DAMAGE,
        values = {6, 14.5, 84.5} -- 自爆统一100血
    }}, {{
        type = C.GameValueType.TOWER_CANNON_A_SHRAPNEL_COUNT,
        values = {2, 5, 97} -- 需求破片伤害占比0.27，x10
    }, {
        type = C.GameValueType.TOWER_CANNON_A_SHRAPNEL_DAMAGE,
        values = {40, 100, 1940} -- 需求破片伤害占比0.27，x10
    }, {
        type = C.GameValueType.TOWER_CANNON_A_LONG_BARREL_RANGE,
        values = {20, 50, 980, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_CANNON_A_LONG_EXPLOSION_RANGE,
        values = {20, 50, 380, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_CANNON_A_FOUNDATION_DAMAGE_PER_DEG,
        values = {0.4, 1, 9.5} -- 需求旋转速度+不断旋转，x15
    }, {
        type = C.GameValueType.TOWER_CANNON_A_MINE_DAMAGE,
        values = {200, 450, 14750} -- 需求1.33倍效果，x10
    }, {
        type = C.GameValueType.TOWER_CANNON_A_MINE_INTERVAL,
        values = {-5, -10, -19.5} -- 需求1.33倍效果，有击退，x6.67
    }}, {{
        type = C.GameValueType.TOWER_FREEZING_RANGE,
        values = {10, 25, 400, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_FREEZING_A_EVAPORATION_DAMAGE,
        values = {1, 2.5, 18} -- 需求3层，成本低，全局x1.5
    }, {
        type = C.GameValueType.TOWER_FREEZING_A_EVAPORATION_STACK,
        values = {2, 5, 97} -- 需求40层，全局x2
    }, {
        type = C.GameValueType.TOWER_FREEZING_A_SLOW_SPEED,
        values = {20, 50, 950, 0} -- 有上限
    }, {
        type = C.GameValueType.TOWER_FREEZING_A_SLOW_PERCENT,
        values = {8, 20, 200, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_FREEZING_A_MONITORING_XP,
        values = {100, 200, 4800} -- 需求每秒100经验，需求每秒1.5怪，偏前期，全局x2
    }, {
        type = C.GameValueType.TOWER_FREEZING_A_SNOWBALL_MAX_DURATION,
        values = {2, 5, 25} -- 3怪100s
    }, {
        type = C.GameValueType.TOWER_FREEZING_A_ULTIMATE_SNOW_BONUS,
        values = {30, 80, 2980} -- 全怪20s
    }}, {{
        type = C.GameValueType.TOWER_VENOM_A_CONCENTRATE_DAMAGE,
        values = {12, 32, 1082} -- x10
    }, {
        type = C.GameValueType.TOWER_VENOM_A_HARD_DAMAGE,
        values = {100, 260, 24760} -- 需求占比0.1，偏前期，x10
    }, {
        type = C.GameValueType.TOWER_VENOM_A_FAST_DAMAGE_PER_STACK,
        values = {10, 24, 1170} -- 需求2层，x10
    }, {
        type = C.GameValueType.TOWER_VENOM_A_FAST_MAX_DEBUFFS,
        values = {2, 5, 147} -- 需求50层，x10
    }, {
        type = C.GameValueType.TOWER_VENOM_A_CLOUD_RANGE,
        values = {1, 2.5, 30, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_VENOM_A_CLOUD_DAMAGE_COEFF,
        values = {8, 20, 1490} -- 需求占比0.08，偏前期，x10
    }, {
        type = C.GameValueType.TOWER_VENOM_A_CHAIN_RANGE,
        values = {1, 2, 30, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_VENOM_A_CHAIN_PROLONG,
        values = {15, 35, 985} -- debuff有效时间x10
    }}, {{
        type = C.GameValueType.TOWER_SPLASH_A_PENETRATING_DAMAGE_CHAIN,
        values = {15, 30, 130, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_SPLASH_A_FAST_BULLETS_BONUS_XP,
        values = {20, 50, 750} -- 需求占比0.3，需求塔有输出能力，偏后期，全局x3
    }, {
        type = C.GameValueType.TOWER_SPLASH_A_RIFFLED_DAMAGE,
        values = {12, 30, 1080} -- x10
    }, {
        type = C.GameValueType.TOWER_SPLASH_A_ULTIMATE_SPLINTERS,
        values = {2, 5, 27} -- ???
    }, {
        type = C.GameValueType.TOWER_SPLASH_A_ULTIMATE_ON_HIT_CHANCE,
        values = {1.2, 3, 16.75} -- ???
    }, {
        type = C.GameValueType.TOWER_SPLASH_A_ULTIMATE_MAX_CHAIN_LENGTH,
        values = {1, 2, 7} -- ???
    }}, {{
        type = C.GameValueType.TOWER_BLAST_QUAKE_CHARGE_SPEED,
        values = {40, 100, 1110, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_BLAST_A_HEAVY_SHELL_SPEED,
        values = {8, 20, 720} -- x10
    }, {
        type = C.GameValueType.TOWER_BLAST_A_HEAVY_SHELL_CHANCE,
        values = {20, 50, 640, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_BLAST_A_SONIC_WAVE_DURATION,
        values = {16, 40, 280} -- 全怪20s
    }, {
        type = C.GameValueType.TOWER_BLAST_A_SONIC_WAVE_QUAKE_ENEMIES,
        values = {1, 2, 100, 0} -- 有上限
    }, {
        type = C.GameValueType.TOWER_BLAST_A_STOPPING_FORCE_CHANCE,
        values = {6, 15, 90, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_BLAST_A_STOPPING_FORCE_ULTIMATE_MAX,
        values = {50, 130, 830} -- 需求覆盖率20%，全局x2
    }}, {{
        type = C.GameValueType.TOWER_MULTISHOT_PROJECTILE_COUNT,
        values = {10, 25, 900} -- x10
    }, {
        type = C.GameValueType.TOWER_MULTISHOT_A_PENETRATING_DAMAGE,
        values = {20, 50, 1930} -- 需求命中率0.7，x10
    }, {
        type = C.GameValueType.TOWER_MULTISHOT_A_BUCKSHOT_DAMAGE,
        values = {15, 40, 1680} -- 需求近距离，x15
    }, {
        type = C.GameValueType.TOWER_MULTISHOT_A_BUCKSHOT_COINS,
        values = {12, 30, 320} -- 需求占比0.5，需求别人击杀，偏后期，x2
    }, {
        type = C.GameValueType.TOWER_MULTISHOT_A_COMPACT_DAMAGE_PER_HIT,
        values = {0.8, 2, 99} -- 需求10层，x10
    }, {
        type = C.GameValueType.TOWER_MULTISHOT_A_COMPACT_MAX_HIT_COUNT,
        values = {30, 70, 2970} -- 需求1200层，x10
    }}, {{
        type = C.GameValueType.TOWER_MINIGUN_A_HEAVY_WEAPONS_VULNERABILITY_MAX,
        values = {15, 40, 1170} -- 覆盖率低，不考虑辅助，x10
    }, {
        type = C.GameValueType.TOWER_MINIGUN_A_HEAVY_MECH_MAGAZINE,
        values = {30, 70, 9870, 0} -- 有上限
    }, {
        type = C.GameValueType.TOWER_MINIGUN_A_FOUNDATION_SPECIAL_BONUS,
        values = {7, 18, 333} -- 需求维持5层，x10
    }, {
        type = C.GameValueType.TOWER_MINIGUN_A_HOT_DURATION,
        values = {3, 7, 77} -- 需求每秒1层，x10
    }, {
        type = C.GameValueType.TOWER_MINIGUN_A_MICROGUN_COUNT,
        values = {1, 2, 98} -- 需求占比0.375，占地方，x20
    }, {
        type = C.GameValueType.TOWER_MINIGUN_A_MICROGUN_RANGE,
        values = {10, 25, 155, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_MINIGUN_A_MICROGUN_ATTACK_SPEED,
        values = {8, 20, 970} -- 需求占比0.28，x10
    }}, {{
        type = C.GameValueType.TOWER_AIR_BURNING_TIME,
        values = {20, 50, 900} -- 偏后期，x10
    }, {
        type = C.GameValueType.TOWER_AIR_A_FAST_MECHANISM_IGNITION_CHANCE,
        values = {30, 80, 1880, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_AIR_A_FOUNDATION_BURN_DAMAGE,
        values = {20, 50, 1350} -- 偏后期，x10
    }, {
        type = C.GameValueType.TOWER_AIR_A_AIMED_DROP_DAMAGE,
        values = {7, 16, 80} -- 自爆统一100血
    }, {
        type = C.GameValueType.TOWER_AIR_A_ULTIMATE_EXPL_RANGE,
        values = {1, 2.5, 29.5, 0} -- 上限
    }}, {{
        type = C.GameValueType.TOWER_TESLA_CHAIN_LIGHTNING_DAMAGE,
        values = {8, 20, 100, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_TESLA_A_BATTERIES_SPEED,
        values = {8, 20, 620} -- 需求大招占比0.1，偏后期，x10
    }, {
        type = C.GameValueType.TOWER_TESLA_A_VOLTAGE_LENGTH,
        values = {16, 40, 2380} -- 需求占比0.6，需求长度16，偏前期，x10
    }, {
        type = C.GameValueType.TOWER_TESLA_A_VOLTAGE_MIN_DAMAGE,
        values = {10, 25, 470} -- 需求占比0.6，需求长度16，偏前期，x10
    }, {
        type = C.GameValueType.TOWER_TESLA_A_BALL_DAMAGE,
        values = {120, 300, 9650} -- 需求占比0.3，偏前期，不稳定，x15
    }, {
        type = C.GameValueType.TOWER_TESLA_A_ULTIMATE_SHOT_INTERVAL,
        values = {-10, -20, -39} -- 需求大招占比0.1，攻速额外收益，偏后期，x4
    }, {
        type = C.GameValueType.TOWER_TESLA_A_ULTIMATE_DAMAGE,
        values = {80, 210, 7810} -- 需求大招占比0.1，攻速额外收益，偏后期，x4
    }, {
        type = C.GameValueType.TOWER_TESLA_A_ULTIMATE_DURATION,
        values = {4, 10, 390} -- 需求大招占比0.1，攻速额外收益，偏后期，x4
    }}, {{
        type = C.GameValueType.TOWER_MISSILE_A_VERTICAL_LRM_RATE,
        values = {10, 25, 950} -- 需求占比0.5，x10
    }, {
        type = C.GameValueType.TOWER_MISSILE_A_COMPACT_COUNT,
        values = {0, 1, 27} -- x10
    }, {
        type = C.GameValueType.TOWER_MISSILE_A_COMPACT_DAMAGE,
        values = {4, 12, 342} -- x10
    }, {
        type = C.GameValueType.TOWER_MISSILE_A_ANTI_AIR_LRM_DAMAGE,
        values = {160, 400, 7600} -- 需求占比0.5，x10
    }, {
        type = C.GameValueType.TOWER_MISSILE_A_ULTIMATE_DAMAGE,
        values = {60, 150, 2850} -- 打溢出伤害，偏前期，x30
    }}, {{
        type = C.GameValueType.TOWER_FLAMETHROWER_TIME_TO_IGNITE,
        values = {-0.1, -0.2, -0.5, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_FLAMETHROWER_A_NAPALM_DIRECT_DAMAGE,
        values = {8, 20, 720} -- x10
    }, {
        type = C.GameValueType.TOWER_FLAMETHROWER_A_NAPALM_DURATION,
        values = {24, 60, 1260} -- x10
    }, {
        type = C.GameValueType.TOWER_FLAMETHROWER_A_NAPALM_FREEZING,
        values = {15, 22, 40} -- 需求群伤，全局x3.5
    }, {
        type = C.GameValueType.TOWER_FLAMETHROWER_A_COLD_DAMAGE,
        values = {8, 20, 720} -- x10
    }, {
        type = C.GameValueType.TOWER_FLAMETHROWER_A_SUPPLY_RANGE,
        values = {12, 30, 1190, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_FLAMETHROWER_A_SUPPLY_ARC,
        values = {60, 100, 1650, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_FLAMETHROWER_A_INSTAKILL_HP_MAX,
        values = {2, 6, 36} -- 成本低，全局x1.7
    }}, {{
        type = C.GameValueType.TOWER_LASER_DAMAGE_PER_SECOND_SHOOTING,
        values = {5, 13, 488} -- 需求5秒，偏后期，x10
    }, {
        type = C.GameValueType.TOWER_LASER_A_MIRRORS_BEAM_COUNT,
        values = {1, 2, 27} -- x10
    }, {
        type = C.GameValueType.TOWER_LASER_A_MIRRORS_DAMAGE,
        values = {5, 11, 405} -- x10
    }, {
        type = C.GameValueType.TOWER_LASER_A_LARGE_DURATION,
        values = {65, 160, 3860} -- 需求5秒，偏前期，x10
    }, {
        type = C.GameValueType.TOWER_LASER_A_LARGE_ROTATION_SPEED,
        values = {5, 10, 90, 0} -- 有上限
    }, {
        type = C.GameValueType.TOWER_LASER_A_IONIZATION_COINS,
        values = {12, 30, 320} -- 需求别人击杀，偏前期，x10
    }, {
        type = C.GameValueType.TOWER_LASER_A_ULTIMATE_DAMAGE_BONUS,
        values = {0.7, 1.7, 58.2} -- 需求1秒击杀，x10
    }, {
        type = C.GameValueType.TOWER_LASER_A_ULTIMATE_DURATION,
        values = {8, 20, 6980} -- 需求1秒击杀，x10
    }}, {{
        type = C.GameValueType.TOWER_GAUSS_ATTACK_RAY_WIDTH,
        values = {0.1, 0.3, 4.8, 0} -- 有上限
    }, {
        type = C.GameValueType.TOWER_GAUSS_A_NANO_HP,
        values = {-5, -11, 25} -- 配合喷火斩杀
    }, {
        type = C.GameValueType.TOWER_GAUSS_A_IMPROVEMENT_DAMAGE,
        values = {0.5, 1.2, 39} -- 需求30级，偏后期，x10
    }, {
        type = C.GameValueType.TOWER_GAUSS_A_IMPROVEMENT_XP,
        values = {-1000, -2500, -2999.88} -- 需求基础养1300级，偏前期，x10
    }, {
        type = C.GameValueType.TOWER_GAUSS_A_IMPROVEMENT_XP_PER_LEVEL,
        values = {-50, -75, -100, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_GAUSS_A_CONDUCTORS_RESOURCE_CONSUMPTION,
        values = {-7, -16, -80, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_GAUSS_A_OVERLOAD_SHOTS,
        values = {-1, -2, -4, 0} -- 上限
    }, {
        type = C.GameValueType.TOWER_GAUSS_A_OVERLOAD_DAMAGE,
        values = {8, 18, 90} -- 自爆统一100血
    }}, {{
        type = C.GameValueType.TOWER_CRUSHER_DURATION,
        values = {20, 50, 900} -- 3怪100s
    }, {
        type = C.GameValueType.TOWER_CRUSHER_A_HEAVY_VICE,
        values = {15, 30, 470} -- 需求占比0.45，x10
    }, {
        type = C.GameValueType.TOWER_CRUSHER_A_INCREASED_CAPACITY,
        values = {0, 1, 47} -- 需求占比0.55，x10
    }, {
        type = C.GameValueType.TOWER_CRUSHER_A_CAREFUL_PROCESSING,
        values = {80, 180, 1480} -- 需求占比0.3，需求覆盖率0.5，全局x3
    }, {
        type = C.GameValueType.TOWER_CRUSHER_A_DISORIENTATION_CHANCE_MAX,
        values = {2, 5, 50} -- 需求全覆盖，全局x3
    }, {
        type = C.GameValueType.TOWER_CRUSHER_A_ULTIMATE_UNIT_HP,
        values = {100, 220, 3700} -- 需求全覆盖，全局x3
    }}}
    local targetTile = S.map:getMap():getTargetTileOrThrow()
    targetTile:getGameValues():clear()
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MDPS_COUNTER, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.EXTENDED_STATISTICS, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_BASIC, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_SNIPER, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_CANNON, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_FREEZING, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_AIR, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_SPLASH, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_BLAST, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_MULTISHOT, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_MINIGUN, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_VENOM, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_TESLA, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_MISSILE, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_FLAMETHROWER, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_LASER, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_GAUSS, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TYPE_CRUSHER, 1, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MINER_COUNT_SCALAR, 2, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MINER_COUNT_VECTOR, 2, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MINER_COUNT_MATRIX, 2, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MINER_COUNT_TENSOR, 2, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MINER_COUNT_INFIAR, 2, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MODIFIER_BALANCE_COUNT, 5, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MODIFIER_SEARCH_COUNT, 5, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MODIFIER_ATTACK_SPEED_COUNT, 5, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MODIFIER_DAMAGE_COUNT, 5, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MODIFIER_BOUNTY_COUNT, 5, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MODIFIER_EXPERIENCE_COUNT, 5, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MODIFIER_MINING_SPEED_COUNT, 5, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MODIFIER_POWER_COUNT, 5, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWERS_MAX_EXP_LEVEL, 100, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWERS_MAX_UPGRADE_LEVEL, 10, true, true))
    -- 关卡间平衡
    S.gameState:setMoney(S.gameState.averageDifficulty / 100 * S.gameState:getMoney())
    -- S.gameState:setHealth(S.gameState.averageDifficulty / 100 * S.gameState:getHealth())
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.CORES_LEVEL_UP_SPEED, S.gameState.averageDifficulty,
        true, true))
    -- 确保技能有用
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_CANNON_A_MINE_COUNT, 50, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_MINIGUN_A_MICROGUN_BUILD_DELAY, 1, true, true))
    -- 防溢出
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_CANNON_A_MINE_INTERVAL, 20, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TESLA_A_ULTIMATE_SHOT_INTERVAL, 40, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_GAUSS_A_IMPROVEMENT_XP, 3000, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_GAUSS_A_IMPROVEMENT_XP_PER_LEVEL, 100, true,
        true))
    -- 塔间平衡
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWERS_DAMAGE, 0, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_BASIC_DAMAGE, 100, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_SNIPER_DAMAGE, 130, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_CANNON_DAMAGE, 100, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_AIR_DAMAGE, 100, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_SPLASH_DAMAGE, 30, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_SPLASH_PROJECTILE_COUNT, 150, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_BLAST_DAMAGE, 100, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_MULTISHOT_DAMAGE, 100, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_MINIGUN_DAMAGE, 100, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_MINIGUN_MAGAZINE_SIZE, 75, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_MINIGUN_RELOAD_DURATION, 3, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_VENOM_DAMAGE, 100, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_TESLA_DAMAGE, 140, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_MISSILE_DAMAGE, 33, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_MISSILE_EXPLOSION_RANGE, 200, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_FLAMETHROWER_DAMAGE, 50, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_FLAMETHROWER_DIRECT_FIRE_DAMAGE, 50, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_LASER_DAMAGE, 40, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_LASER_CHARGING_SPEED, 400, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_GAUSS_DAMAGE, 100, true, true))
    targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_CRUSHER_DAMAGE, 10, true, true))
    -- S.gameState:setMoney(1000000, true)
    -- S.gameState:setHealth(1000000)
    -- targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWERS_STARTING_LEVEL, 50, true, true))
    -- targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.WAVE_INTERVAL, 100, true, true))
    -- targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.MINERS_SPEED, 10000, true, true))
    -- targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.ENEMIES_VULNERABILITY, 10, true, true))
    -- targetTile:addGameValue(C.GameValueConfig.new(C.GameValueType.TOWER_SNIPER_CRIT_CHANCE, 0, true, true))
    -- S.gameState:setGameSpeed(30)
    targetTile:setUseStockGameValues(true)
    S.gameValue:setGlobalSnapshot(nil)
    S.gameValue:recalculate()
    seed = S.gameState.basicLevelName:hashCode() + gameValue("val_random_core_pqr") * 42
    for i = 2, #game_values do
        local j = rand(2, #game_values)
        if i ~= j then
            local t = game_values[i]
            game_values[i] = game_values[j]
            game_values[j] = t
        end
    end
    for n = 1, #game_values do
        local tower_values = game_values[n]
        for i = 1, #tower_values do
            local j = rand(1, #tower_values)
            if i ~= j then
                local t = tower_values[i]
                tower_values[i] = tower_values[j]
                tower_values[j] = t
            end
        end
    end
    generateCore(1)
end))
