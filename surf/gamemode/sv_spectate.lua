util.AddNetworkString("spec_keys")

local spectatorKeys = spectatorKeys or {}

hook.Add("PlayerInitialSpawn","surf_keys_init",function(ply)
    if not spectatorKeys[ply] then spectatorKeys[ply] = 0 end
end)

hook.Add("PlayerSay","surf_spectate_chat",function(ply,text,team)
    if text == "!spec" then
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

hook.Add( "KeyPress", "surf_spectate_modes", function( ply, key )
    --Spectator Keybinds
    if ply.spectating then
        if not ply.spectarget then ply.spectarget = 1 end
        if (key == IN_RELOAD) then
            if ply.specmode == OBS_MODE_IN_EYE then
                ply.specmode = OBS_MODE_CHASE
            elseif ply.specmode == OBS_MODE_ROAMING then
                ply.specmode = OBS_MODE_IN_EYE
            elseif ply.specmode == OBS_MODE_CHASE then
                ply.specmode = OBS_MODE_ROAMING
            end
            ply:Spectate(ply.specmode)
        end
        if (key == IN_ATTACK) then
            if IsValid(player.GetAll()[ply.spectarget]) then
                spectatorKeys[player.GetAll()[ply.spectarget]] = math.max(spectatorKeys[player.GetAll()[ply.spectarget]]-1,0)
            end
            ply.spectarget = ply.spectarget+1
            if ply.spectarget > #player.GetAll() then
                ply.spectarget = 1
            end
            if player.GetAll()[ply.spectarget] == ply then
                ply.spectarget = ply.spectarget+1
                if ply.spectarget > #player.GetAll() then
                    ply.spectarget = 1
                end
            end
            ply:SpectateEntity(player.GetAll()[ply.spectarget])
            spectatorKeys[player.GetAll()[ply.spectarget]] = spectatorKeys[player.GetAll()[ply.spectarget]]+1
        end
        if (key == IN_ATTACK2) then
            if IsValid(player.GetAll()[ply.spectarget]) then
                spectatorKeys[player.GetAll()[ply.spectarget]] = math.max(spectatorKeys[player.GetAll()[ply.spectarget]]-1,0)
            end
            ply.spectarget = ply.spectarget-1
            if ply.spectarget < 1 then
                ply.spectarget = #player.GetAll()
            end
            if player.GetAll()[ply.spectarget] == ply then
                ply.spectarget = ply.spectarget-1
                if ply.spectarget < 1 then
                    ply.spectarget = #player.GetAll()
                end
            end
            ply:SpectateEntity(player.GetAll()[ply.spectarget])
            spectatorKeys[player.GetAll()[ply.spectarget]] = spectatorKeys[player.GetAll()[ply.spectarget]]+1
        end
    end
  
    --Spectator Key Sync Display
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
