--@name Kill everyones + synced audio
--@author TheArgentinianX
--@shared

local SOUND_URLS = {
    "https://raw.githubusercontent.com/lautaroleonel1012-commits/i-dunno/main/beso.mp3"
}

if SERVER then
    util.addNetworkString("sf_play_kill_sound")

    hook.add("PlayerChat", "command", function(ply, text)
        if ply ~= owner() then return end

        local args = string.explode(" ", text)
        if string.lower(args[1] or "") ~= "!besar" then return end

        local targetName = args[2]

        local function trigger(p)
            if not p or not p:isValid() then return end

            local index = math.random(#SOUND_URLS)
            local isSpecial = (index == #SOUND_URLS)

            net.start("sf_play_kill_sound")
            net.writeEntity(p)
            net.writeUInt(index, 3)
            net.send()

            local delay = isSpecial and 0.98 or 0

            timer.simple(delay, function()
                if p and p:isValid() then
                    p:applyDamage(699)
                end
            end)
        end

        -- sin nombre o "all"
        if not targetName or string.lower(targetName) == "all" then
            for _, p in pairs(find.allPlayers()) do
                trigger(p)
            end
            return
        end

        -- nombre especfico
        local results = find.playersByName(targetName, false, false)
        local target = results[1]

        if target then
            trigger(target)
        end
    end)

    return
end

-- CLIENT

net.receive("sf_play_kill_sound", function()
    local p = net.readEntity()
    local index = net.readUInt(3)

    if not p or not p:isValid() then return end

    local url = SOUND_URLS[index]
    if not url then return end

    bass.loadURL(url, "3d noblock", function(s)
        if not s then return end

        s:setVolume(3)
        s:setPos(p:getPos())
        s:play()
    end)
end)
