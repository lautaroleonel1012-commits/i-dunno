--@name VIOLADOR PRO MAX 9000
--@shared

local SOUND_URL = "https://raw.githubusercontent.com/lautaroleonel1012-commits/i-dunno/main/cracksound1.mp3"

if SERVER then

    util.addNetworkString("sf_play_sound")

    local ply = owner()
    local headMode = false
    local active = false

    -- comando
    hook.add("PlayerChat", "targetcommand", function(sender, text)

        if sender ~= owner() then return end

        local args = string.explode(" ", text)

        --por atras
        
        if string.lower(args[1] or "") == "!violar" then

            local targetName = args[2]

            if not targetName then return end

            local results = find.playersByName(
                targetName,
                false,
                false
            )

            local target = results[1]

            if target and target:isValid() then

                ply = target

                headMode = false
                active = true

                print("Target:", target:getName())

                net.start("sf_play_sound")
                net.writeEntity(ply)
                net.send()

            else

                print("Jugador no encontrado")

            end

            return

        end

--por adelante/cara

if string.lower(args[1] or "") == "!me"
and string.lower(args[2] or "") == "gomea" then

    local targetName = args[3]

    if not targetName then return end

    local results = find.playersByName(
        targetName,
        false,
        false
    )

    local target = results[1]

    if target and target:isValid() then

        ply = target

        headMode = true
        active = true

        print("Head target:", target:getName())

        net.start("sf_play_sound")
        net.writeEntity(ply)
        net.send()

    else

        print("Target invalido")

    end

    return

end

    end)

    local playerPelvis = "ValveBiped.Bip01_Pelvis"

    local holo = holograms.create(
        Vector(0,0,0),
        Angle(),
        "models/player/group01/male_04.mdl",
        Vector(1,1,1)
    )

    holo:setAnimation("ragdoll")

    --huesos
    local holoPelvis = holo:lookupBone("ValveBiped.Bip01_Pelvis")
    local spine = holo:lookupBone("ValveBiped.Bip01_Spine")

    local thighR = holo:lookupBone("ValveBiped.Bip01_R_Thigh")
    local thighL = holo:lookupBone("ValveBiped.Bip01_L_Thigh")

    local armR = holo:lookupBone("ValveBiped.Bip01_R_UpperArm")
    local armL = holo:lookupBone("ValveBiped.Bip01_L_UpperArm")

    --pose inicial
    timer.simple(0.1, function()

        if not holo:isValid() then return end

        holo:manipulateBoneAngles(
            armR,
            Angle(-20,-40,0)
        )

        holo:manipulateBoneAngles(
            armL,
            Angle(20,-40,0)
        )

    end)

    --animacion
    timer.create("hipmotion", 0.067, 0, function()

        if not active then
            holo:setPos(Vector(0,0,0))
            return
        end

        if not holo:isValid() then return end
        if not isValid(ply) then return end
        local boneid = ply:lookupBone(playerPelvis)
        if not boneid then return end
        local pos, ang = ply:getBonePosition(boneid)

        local forward = ang:getForward()

        forward = Vector(
            forward[1],
            forward[2],
            0
        )

        forward = forward:getNormalized()

        local fixedAng = forward:getAngle()

        --offset
        
        local offset = Vector(0,11,-40)

        --modo cabeza
        if headMode then

            local headBone = ply:lookupBone(
                "ValveBiped.Bip01_Head1"
            )

            if headBone then

                local headPos, headAng =
                    ply:getBonePosition(headBone)

                pos = headPos

                local forward = headAng:getForward()

                forward = Vector(
                    forward[1],
                    forward[2],
                    0
                )

                forward = forward:getNormalized()

                fixedAng = forward:getAngle() + Angle(0,-90,0)

                offset = Vector(0,10,-40)

            end

        end

        --offset local
        local worldPos = localToWorld(
            offset,
            Angle(),
            pos,
            fixedAng
        )

        holo:setPos(worldPos)
        holo:setAngles(fixedAng)

        local t = timer.curtime()

        local hip = math.sin(t * 15) * 51

        holo:manipulateBoneAngles(
            holoPelvis,
            Angle(-90,0,hip)
        )

        holo:manipulateBoneAngles(
            thighR,
            Angle(0,-hip,0)
        )

        holo:manipulateBoneAngles(
            thighL,
            Angle(0,-hip,0)
        )

        holo:manipulateBoneAngles(
            spine,
            Angle(0,-hip,0)
        )

    end)

    return
end

-- CLIENT

local currentSound

net.receive("sf_play_sound", function()

    local p = net.readEntity()

    if not p or not p:isValid() then
        return
    end

    if currentSound then
        currentSound:stop()
    end

    bass.loadURL(SOUND_URL, "3d noblock", function(sound, errId, errStr)

        if not sound or not sound:isValid() then
            print("[SF BASS ERROR]: NO CARG AUDIO -> " .. (errStr or "Fallo de red"))
            return
        end

        currentSound = sound

        currentSound:setVolume(1)
        currentSound:setLooping(true)
        currentSound:setPos(p:getPos())
        currentSound:play()

        hook.remove("think", "updatesound")

        hook.add("think", "updatesound", function()

            if not p:isValid() then return end
            if not currentSound or not currentSound:isValid() then return end

            currentSound:setPos(p:getPos())

        end)

    end)

end)
