--@name loquendo voz
--@client
local sounds = {}

local FLEX = {

    BITE = 35,
    TIGHTENER = 37,
    PRESSER = 36,

    LPUCKER = 30,
    RPUCKER = 29,

    LFUNNEL = 32,
    RFUNNEL = 31,

    LSTRETCH = 34,
    RSTRETCH = 33,

    LPULL = 23,
    RPULL = 22,

    LDEPRESS = 25,
    RDEPRESS = 24,

    LOWERLIP = 43,

    CHIN = 26
}

local function resetFlexes(ent)

    for _, id in pairs(FLEX) do
        ent:setFlexWeight(id, 0)
    end

end

local function applyPhone(ent, phone)

    resetFlexes(ent)

    if phone == "b" or phone == "m" then

        ent:setFlexWeight(FLEX.BITE, 1)

    elseif phone == "p" then

        ent:setFlexWeight(FLEX.BITE, 1)
        ent:setFlexWeight(FLEX.TIGHTENER, 1)
        ent:setFlexWeight(FLEX.PRESSER, 1)

    elseif phone == "E" then

        ent:setFlexWeight(FLEX.LPUCKER, 1)
        ent:setFlexWeight(FLEX.RPUCKER, 1)

    elseif phone == "i" then

        ent:setFlexWeight(FLEX.LSTRETCH, 1)
        ent:setFlexWeight(FLEX.RSTRETCH, 1)

    elseif phone == "O"
        or phone == "o"
        or phone == "u"
        or phone == "w" then

        ent:setFlexWeight(FLEX.LFUNNEL, 1)
        ent:setFlexWeight(FLEX.RFUNNEL, 1)

    elseif phone == "s" then

        ent:setFlexWeight(FLEX.LSTRETCH, 0.5)
        ent:setFlexWeight(FLEX.RSTRETCH, 0.5)

    elseif phone == "l" then

        ent:setFlexWeight(FLEX.CHIN, 0.8)

elseif phone == "n" then

    ent:setFlexWeight(FLEX.CHIN, 0.2)

    elseif phone == "t" then

        ent:setFlexWeight(FLEX.LOWERLIP, 0.7)

    elseif phone == "!" then

        ent:setFlexWeight(FLEX.LOWERLIP, 1)

elseif phone == "^" then

    ent:setFlexWeight(FLEX.LOWERLIP, 1)

    elseif phone == "r" then

        ent:setFlexWeight(FLEX.LPUCKER, 0.5)
        ent:setFlexWeight(FLEX.RPUCKER, 0.5)

    end

end

hook.add("PlayerChat","oddcast_lipsync",function(sender,text)

    if sender ~= owner() then return end

    local encoded = string.gsub(text," ","%%20")

    local url =
    "https://cache-a.oddcast.com/tts/genC.php?EID=2&LID=2&VID=6&TXT="
    .. encoded ..
    "&EXT=mp3&FNAME=&ACC=9066743&SceneID=2770702&HTTP_ERR="

    http.get(url,function(body)

        local pos = string.find(
            body,
            "timed_phonemes = ",
            1,
            true
        )

        if not pos then
            print("no hay timed_phonknemes")
            return
        end

        local chunk = string.sub(body, pos)

local q1 = string.find(chunk, '"', 1, true)

if not q1 then
    print("no opening quote")
    return
end

local q2 = string.find(chunk, '"', q1 + 1, true)

if not q2 then
    print("no closing quote")
    return
end

local timed = string.sub(
    chunk,
    q1 + 1,
    q2 - 1
)

if timed == "" then
    print("timed_phonknemes vacios")
    return
end

        local queue = {}

        local startPos = 1

        while true do

            local tabPos =
                string.find(
                    timed,
                    "\t",
                    startPos,
                    true
                )

            local line

            if tabPos then
                line = string.sub(
                    timed,
                    startPos,
                    tabPos - 1
                )
            else
                line = string.sub(
                    timed,
                    startPos
                )
            end

            local parts =
                string.explode(
                    ",",
                    line
                )

            if #parts >= 5 then

                table.insert(queue,{
                    ms = tonumber(parts[2]),
                    phone = parts[5]
                })

            end

            if not tabPos then
                break
            end

            startPos = tabPos + 1

        end

if #queue == 0 then
    print("no phonknemes")
    return
end

        bass.loadURL(
            url,
            "3d noblock",
            function(sound)

                if not sound then
                    return
                end

                table.insert(sounds, sound)

                if #sounds > 5 then

                    local old = table.remove(sounds, 1)

                    pcall(function()

                        old:stop()
                        old:destroy()

                    end)

                end

                sound:play()

                local ent = owner()

                for _,v in ipairs(queue) do

                    timer.simple(
                        v.ms / 1000,
                        function()

                            if not ent then
                                return
                            end

                            applyPhone(ent, v.phone)

                        end
                    )

                end

                local last = queue[#queue]

                if last then

                    timer.simple(
                        (last.ms / 1000) + 0.15,
                        function()

                            if owner() then
                                resetFlexes(owner())
                            end

                        end
                    )

                end

            end
        )

    end)

end)
