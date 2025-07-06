if newPage ~= nil then
    local button_random_map = newToggle("随机地图", registerBool("random_map"), "icon-dijkstras", nil, 0xEAC000FF)

    local table = newPage(64)
    table:add(button_random_map):width(840):padLeft(60):height(64)

    return
end

if not gameEnabled("random_map") then
    return
end
if S.gameState.dailyQuestLevel ~= nil then
    return
end

recordGuard("随机地图")

S.events:getListeners(C.SystemsSetup):add(C.Listener(function(_)
    math.randomseed(S.gameState.gameStartTimestamp)

    local padding = 16
    local n = math.random(16, 47)
    n = math.random(16, n)
    n = padding + n

    local val_ud = {}
    local val_lr = {}
    local val_t = {}
    for row = 1, n do
        local row_ud = {}
        local row_lr = {}
        local row_c = {}
        for col = 1, n do
            row_ud[col] = 0
            row_lr[col] = 0
            row_c[col] = 6
        end
        val_ud[row] = row_ud
        val_lr[row] = row_lr
        val_t[row] = row_c
    end

    local function fillRowImpl(row, a)
        if a < 0.5 then
            return
        elseif a < 2 then
            local acc = 0
            for col = 1, n do
                acc = acc + a
                local r = acc % 1
                local v = acc - r
                acc = r
                val_ud[row][col] = v
            end
        else
            return
        end
    end

    local function fillRow(row, a)
        if a < 0.5 then
            return 0
        elseif a < 1 then
            local a1 = a * 2
            fillRowImpl(row, a1)
            local acc = 1
            for col = 1, n do
                val_lr[row - 1][col] = acc
                local u = val_ud[row - 1][col]
                local d = val_ud[row][col]
                acc = acc + u * 2 - d
            end
            return a1
        elseif a <= 2 then
            local a1 = a * 2 / 3
            fillRowImpl(row, a1)
            local acc = 3
            for col = 1, n do
                val_lr[row - 1][col] = acc
                local u = val_ud[row - 1][col]
                local d = val_ud[row][col]
                acc = acc + u * 2 - d * 3
            end
            return a1
        else
            return 0
        end
    end

    local tiles = {}
    tiles[1200] = 1
    tiles[1101] = 2
    tiles[0110] = 3
    tiles[1211] = 4

    tiles[2123] = 1
    tiles[2134] = 2
    tiles[2145] = 3
    tiles[2242] = 4
    tiles[2253] = 5

    tiles[1154] = 1
    tiles[1143] = 2
    tiles[1132] = 3
    tiles[1024] = 4
    tiles[1035] = 5
    local function getTile(row, col)
        if row == n or col == n then
            return " "
        end
        local u = val_ud[row][col]
        local d = val_ud[row + 1][col]
        local l = val_lr[row][col]
        local r = val_lr[row][col + 1]
        return tiles[u * 1000 + d * 100 + l * 10 + r * 1] or 6
    end

    local a = math.random(500000, 2000000)
    while a > 2 do
        a = a / 3
    end
    fillRowImpl(1, a)
    for row = 2, n do
        a = fillRow(row, a)
    end
    for row = 1, n do
        for col = 1, n do
            val_t[row][col] = getTile(row, col)
        end
    end

    local map = S.map:getMap()
    local target = C.TargetTile.TargetTileFactory.new()
    local spawn = C.SpawnTile.SpawnTileFactory.new()
    local road = C.RoadTile.RoadTileFactory.new()
    local plat = C.PlatformTile.SpaceTileFactory.new()
    local mine = C.SourceTile.SourceTileFactory.new()
    map:setSize(n - padding, n - padding)
    for row = padding, n - 1 do
        for col = padding, n - 1 do
            local tile = val_t[row][col]
            if tile == 1 then
                tile = road:create()
            elseif tile == 2 then
                tile = plat:create()
            elseif tile == 3 then
                tile = mine:create()
            else
                tile = nil
            end
            map:setTile(col - padding, row - padding, tile)
        end
    end
    n = n - padding

    local poss = {}
    for i = 1, 20 do
        local x = math.random(2, n - 3)
        local y = math.random(2, n - 3)
        local conflict = false
        for _, pos in ipairs(poss) do
            if pos[1] == x and pos[2] == y then
                conflict = true
            end
        end
        if not conflict then
            poss[#poss + 1] = {x, y}
        end
    end
    S.pathfinding:rebuildPathfinding()
    local paths = {}
    for i = 1, #poss do
        paths[i] = {}
        for j = 1, #poss do
            local path = S.pathfinding:findPathBetweenXY(poss[i][1], poss[i][2], poss[j][1], poss[j][2])
            paths[i][j] = path:getNodes()
        end
    end
    for _, paths in ipairs(paths) do
        table.sort(paths, function(a, b)
            return #a > #b
        end)
    end

    local k = math.random(1, 2)
    local numPaths = (n - n % 16) / 16 + k
    local numEnemies = (n - n % 16) / 16 + 3 - k
    table.sort(paths, function(a, b)
        return #a[numPaths] > #b[numPaths]
    end)

    for row = 0, n - 1 do
        for col = 0, n - 1 do
            map:setTile(col, row, nil)
        end
    end

    for i = 1, numPaths do
        local path = paths[1][i]
        for i = 1, #path do
            local pos = path[i]
            for i = 1, 5, 2 do
                local x = pos:getX() + math.random(-i, i)
                local y = pos:getY() + math.random(-i, i)
                if x >= 0 and x < n and y >= 0 and y < n then
                    local tile = val_t[x + padding][y + padding]
                    if tile == 1 or tile == 2 or tile == 4 then
                        tile = plat:create()
                    elseif tile == 3 then
                        tile = plat:create()
                        tile.bonusType = C.SpaceTileBonusType.values[math.random(1, #C.SpaceTileBonusType.values)]
                        tile.bonusLevel = math.random(1, 5)
                    elseif tile == 5 then
                        tile = mine:create()
                        tile:setResourcesCount(C.ResourceType.values[math.random(1, #C.ResourceType.values)], 100)
                    else
                        tile = nil
                    end
                    map:setTile(x, y, tile)
                end
            end
        end
    end
    local pos = paths[1][1][1]
    map:setTile(pos:getX(), pos:getY(), target:create())
    for i = 1, numPaths do
        local path = paths[1][i]
        local pos = path[#path]
        local tile = spawn:create()
        tile.difficulty = n * 5 + math.random(4, 53) * 5
        if i == 1 then
            tile:addAllowedEnemy(C.EnemyType.REGULAR, 1, 0)
            tile:addAllowedEnemy(C.EnemyType.BOSS, 1, 0)
        end
        for i = 1, #C.EnemyType.mainEnemyTypes - 1 do
            if math.random(1, #C.EnemyType.mainEnemyTypes - 1) <= numEnemies then
                local wave = math.random(1, 50)
                if i == 1 then
                    wave = 1
                end
                tile:addAllowedEnemy(C.EnemyType.mainEnemyTypes[i], wave, 0)
            end
        end
        if #tile:getAllowedEnemies() == 0 then
            tile:addAllowedEnemy(C.EnemyType.REGULAR, 1, 0)
        end
        map:setTile(pos:getX(), pos:getY(), tile)
        for i = 2, #path - 1 do
            local pos = path[i]
            map:setTile(pos:getX(), pos:getY(), road:create())
        end
    end

    map:multiplyPortalsDifficulty(S.gameState.modeDifficultyMultiplier / 100);
    S.map:setMap(map)

    S.pathfinding:rebuildPathfinding()
    S._mapRendering:forceTilesRedraw(true)
    S._input:setup()

    S.events:getListeners(C.WaveComplete):addStateAffecting(C.Listener(function(event)
        local wave = event:getWave().waveNumber
        if S.gameState:randomInt(wave + 1000) < wave then
            local pos = C.Vector2.new_V2(map:getTargetTileOrThrow().center)
            if S._input ~= nil then
                S._input.cameraController:mapToStage(pos)
            end
            local stack = C.ItemStack.new_I_i(C.D.F_ACCELERATOR:create(), 1)
            S.gameState:addLootIssuedPrizes(stack, pos.x, pos.y, 2)
        end
    end))
end))
