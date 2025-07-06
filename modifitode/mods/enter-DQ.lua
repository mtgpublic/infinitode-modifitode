if newPage == nil then
    return
end

local day = math.floor(os.time() / (24 * 60 * 60))

local digits = "Z123456789ABCDEFGHIJKLMNOPQRSTUV"
local digits1 = "z123456789abcdefghijklmnopqrstuv"
local digits2 = "0123456789ABCDEFGHIJKLMNOPQRSTUV"
local vals = {}
for i = 1, #digits do
    vals[digits:sub(i, i)] = i - 1
end
for i = 1, #digits1 do
    vals[digits1:sub(i, i)] = i - 1
end
for i = 1, #digits2 do
    vals[digits2:sub(i, i)] = i - 1
end
local timeBase = os.time({
    year = 1970,
    month = 1,
    day = 1,
    hour = 0,
    min = 0,
    sec = 0
})
function dayToCode(day)
    local code = ""
    for i = 1, 5 do
        code = digits:sub(day % 32 + 1, day % 32 + 1) .. code
        day = (day - day % 32) / 32
    end
    return code
end
function codeToDay(code)
    code = code:upper()
    local day = 0
    for i = 1, 5 do
        day = day * 32 + vals[code:sub(i, i)]
    end
    return day
end
function dayToDate(day)
    return os.date("%Y-%m-%d", day * 24 * 60 * 60)
end
function dateToDay(date)
    date = string.split(date, "-")
    return (os.time({
        year = date[1],
        month = date[2],
        day = date[3],
        hour = 0,
        min = 0,
        sec = 0
    }) - timeBase) / (24 * 60 * 60)
end

local labelCode = C.Label.new("DQ代码：", C.Game.i.assetManager:getLabelStyle(30))
labelCode:setColor(C.Color.new_i(0xC0C0C0FF))
local labelDate = C.Label.new("DQ日期：", C.Game.i.assetManager:getLabelStyle(30))
labelDate:setColor(C.Color.new_i(0xC0C0C0FF))
local textCode = C.TextFieldXPlatform.new(dayToCode(day), C.Game.i.assetManager:getTextFieldStyle(30))
local textDate = C.TextFieldXPlatform.new(dayToDate(day), C.Game.i.assetManager:getTextFieldStyle(30))
textCode:setMaxLength(5)
textDate:setMaxLength(11)
textCode:setTextFieldListener(C.TextFieldListener(function(_, _)
    local code = textCode:getText()
    if code == "" then
        local day = math.floor(os.time() / (24 * 60 * 60))
        code = dayToCode(day)
    end
    if not java.util.regex.Pattern.class:matches("[0-9a-vA-VzZ]{5}", code) then
        textCode:setColor(C.Color.new_i(0xFFA0A0FF))
        return
    end
    day = codeToDay(code) or day
    textDate:setText(dayToDate(day))
    textCode:setColor(C.Color.new_i(0xFFFFFFFF))
    textDate:setColor(C.Color.new_i(0xFFFFFFFF))
end))
textDate:setTextFieldListener(C.TextFieldListener(function(_, _)
    local date = textDate:getText()
    if date == "" then
        local day = math.floor(os.time() / (24 * 60 * 60))
        date = dayToDate(day)
    end
    if not java.util.regex.Pattern.class:matches("[0-9]+-[0-9]+-[0-9]+", date) then
        textDate:setColor(C.Color.new_i(0xFFA0A0FF))
        return
    end
    day = dateToDay(date) or day
    if day < 0 then
        textDate:setColor(C.Color.new_i(0xFFA0A0FF))
        return
    end
    textCode:setText(dayToCode(day))
    textCode:setColor(C.Color.new_i(0xFFFFFFFF))
    textDate:setColor(C.Color.new_i(0xFFFFFFFF))
end))

-- local dqs = {"DQ1", "DQ3", "DQ4", "DQ5", "DQ7", "DQ8", "DQ9", "DQ10", "DQ11", "DQ12"}

local proto = {{128, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0,
                1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, --
68, 81}, {},
               {1, 128, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 128, 1, 1, 0, 1, 128, 1, 1, 0, 1, 128, 1, 1, 0, 1, 128, 1, 1,
                0, 1, 128, 1, 1, 0, 1, 128, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}}

local function DQ(id)
    local name = "DQ" .. tostring(id)

    if id >= 10 then
        proto[2] = {48 + 1, 48 + id % 10 + 128}
    else
        proto[2] = {48 + id + 128}
    end
    local bytes = {}
    for _, seg in ipairs(proto) do
        for _, byte in ipairs(seg) do
            bytes[#bytes + 1] = byte
        end
    end
    local dqlevel = C.ReplayHeader:fromBytes(com.esotericsoftware.kryo.io.Input.class.new_byteArr(string.char(
        table.unpack(bytes, 1, #bytes)))).dailyQuestLevel
    dqlevel.isLocalFallback = true
    dqlevel.questId = id

    return newButton(name, function()
        C.Dialog:i():showConfirm("关卡： " .. name .. "\n日期： " .. dayToDate(day) .. "\n代码： " ..
                                     dayToCode(day), C.Runnable(function()
            local timestamp = day * 24 * 60 * 60 -- + 4294967296
            dqlevel.forDate = dayToDate(day)
            dqlevel.forDateTimestamp = timestamp
            dqlevel.endTimestamp = timestamp + 24 * 60 * 60

            local level = C.Game.i.basicLevelManager:getLevel(name)
            local screen = C.GameScreen.new_BL_DM_i_SAC_3b_l_PSFS_IS_DQL(level, C.DifficultyMode.NORMAL, 100,
                level:getMap():getMaxedAbilitiesConfiguration(), false, false, false, timestamp * 1000, nil, nil,
                dqlevel)
            C.Game.i.screenManager:setScreen(screen)
        end))
    end)
end

local table = newPage(64)
table:add(labelCode):width(130):padLeft(60):height(64)
table:add(textCode):width(240):padLeft(20):height(40)
table:add(labelDate):width(130):padLeft(60):height(64)
table:add(textDate):width(240):padLeft(20):height(40)
local table = newPage(128)
table:add(DQ(1)):width(120):padLeft(60):height(64)
table:add(DQ(3)):width(120):padLeft(60):height(64)
table:add(DQ(4)):width(120):padLeft(60):height(64)
table:add(DQ(5)):width(120):padLeft(60):height(64)
table:add(DQ(7)):width(120):padLeft(60):height(64)
table:row()
table:add(DQ(8)):width(120):padLeft(60):height(64)
table:add(DQ(9)):width(120):padLeft(60):height(64)
table:add(DQ(10)):width(120):padLeft(60):height(64)
table:add(DQ(11)):width(120):padLeft(60):height(64)
table:add(DQ(12)):width(120):padLeft(60):height(64)
