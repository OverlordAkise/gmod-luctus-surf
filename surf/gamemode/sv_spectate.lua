spectatorKeys = spectatorKeys or {}

hook.Add("PlayerInitialSpawn","surf_keys_init",function(ply)
    if not spectatorKeys[ply] then spectatorKeys[ply] = 0 end
end)

hook.Add("PlayerSay","surf_spectate_chat",function(ply,text,team)
    if text == "!spec" or spec == "!spectate" then
        if ply.spectating == nil then ply.spectating = false end
        ply.spectating = not ply.spectating
        if ply.spectating then
            ply:ResetTimer()
            --start spectating
            ply.specmode = OBS_MODE_ROAMING
            ply:Spectate(ply.specmode)
            for k,v in pairs(player.GetAll()) do
                if v ~= ply then
                    ply:SpectateEntity(v)
                    spectatorKeys[v] = spectatorKeys[v]+1
                end
            end
            ply:StripWeapons()
            ply:SetNWBool("spectating",true)
        else
            --stop spectating
            ply:UnSpectate()
            ply:Spawn()
            ply:SetNWBool("spectating",false)
            if IsValid(player.GetAll()[ply.spectarget]) then
                spectatorKeys[player.GetAll()[ply.spectarget]] = math.max(spectatorKeys[player.GetAll()[ply.spectarget]]-1,0)
            end
            ply.spectarget = nil
            ply.specmode = nil
        end
        return ""
    end
end)

local specmodes = {
    OBS_MODE_IN_EYE,
    OBS_MODE_CHASE,
    OBS_MODE_ROAMING
}

hook.Add( "KeyPress", "surf_spectate_modes", function( ply, key )
    --Spectator Keybinds
    if ply.spectating then
        if not ply.spectarget then ply.spectarget = 1 end
        if (key == IN_RELOAD) then
            ply.specmode = (ply.specmode+1)%(#specmodes)
            ply:Spectate(specmodes[ply.specmode+1])
        end
        local PlusOrMinus = 0
        PrintMessage(3,ply.spectarget)
        if (key == IN_ATTACK) then
            PlusOrMinus = PlusOrMinus + 1
        end
        if (key == IN_ATTACK2) then
            PlusOrMinus = PlusOrMinus - 1
        end
        if (key == IN_ATTACK2 or key == IN_ATTACK) then
            local allPly = player.GetAll()
            if IsValid(allPly[ply.spectarget+1]) then
                spectatorKeys[allPly[ply.spectarget+1]] = math.max(spectatorKeys[allPly[ply.spectarget+1]]-1,0)
            end
            ply.spectarget = (ply.spectarget+PlusOrMinus)%(#allPly)
            if allPly[ply.spectarget+1] == ply then
                ply.spectarget = (ply.spectarget+PlusOrMinus)%(#allPly)
            end
            ply:SpectateEntity(allPly[ply.spectarget+1])
            spectatorKeys[allPly[ply.spectarget+1]] = spectatorKeys[allPly[ply.spectarget+1]]+1
        end
        PrintMessage(3,ply.spectarget)
    end

    --Spectator Key Sync Display
    --Only set if player is being spectated
    if spectatorKeys[ply] and spectatorKeys[ply] > 0 then
        if key == IN_FORWARD then
            ply:SetNWBool("spec_w",true)
        end
        if key == IN_MOVELEFT then
            ply:SetNWBool("spec_a",true)
        end
        if key == IN_BACK then
            ply:SetNWBool("spec_s",true)
        end
        if key == IN_MOVERIGHT then
            ply:SetNWBool("spec_d",true)
        end
        if key == IN_DUCK then
            ply:SetNWBool("spec_ctrl",true)
        end
    end
end)

hook.Add( "KeyRelease", "surf_spectate_modes", function( ply, key )
    if spectatorKeys[ply] and spectatorKeys[ply] > 0 then
        if key == IN_FORWARD then
            ply:SetNWBool("spec_w",false)
        end
        if key == IN_MOVELEFT then
            ply:SetNWBool("spec_a",false)
        end
        if key == IN_BACK then
            ply:SetNWBool("spec_s",false)
        end
        if key == IN_MOVERIGHT then
            ply:SetNWBool("spec_d",false)
        end
        if key == IN_DUCK then
            ply:SetNWBool("spec_ctrl",false)
        end
    end
end)
