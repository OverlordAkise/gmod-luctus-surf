local superadmins = {
    ["STEAM_0:0:55735858"] = true,
}

--InitialSpawn doesn't want to work with SetUserGroup
hook.Add("PlayerSpawn","surf_admin_check",function(ply)
    if ply.adminChecked then return end
    ply.adminChecked = true
    if LuctusDbCheckAdmin(ply:SteamID()) then
        ply:SetUserGroup("admin")
    end
    if superadmins[ply:SteamID()] then
        ply:SetUserGroup("superadmin")
    end
end)

surf_admincmds = {
    ["zonegun"] = function(ply)
        ply:Give("weapon_crowbar")
        ply:Give("zone_gun")
        return ""
    end,
    ["frtv"] = function()
        SurfRtvStart()
        return ""
    end,
    ["resethighscore"] = function(ply,args)
        if not args or not string.find(args,"STEAM_%d:%d:%d+") then
            SurfNotify(ply,"[admin]","Usage: !resethighscore <steamid>")
            return ""
        end
        LuctusDbResetHighscore(args)
        local target = player.GetBySteamID(args)
        target:SetNWFloat( "record", 0 )
        SurfNotify(ply,"[admin]","High Score of "..args.." successfully deleted!")
    end,
    ["kick"] = function(ply,args)
        local tply, reason = LuctusFindPlyByName(string.lower(args))
        if not tply or not IsValid(tply) then
            SurfNotify(ply,"[admin]","Error: "..reason)
            return
        end
        tply:Kick("You have been kicked!")
    end,
    ["mute"] = function(ply,args)
        local tply, reason = LuctusFindPlyByName(string.lower(args))
        if not tply or not IsValid(tply) then
            SurfNotify(ply,"[admin]","Error: "..reason)
            return
        end
        tplytarget.ismuted = true
        SurfNotify(ply,"[admin]","Player is now muted for everyone!")
    end,
    ["unmute"] = function(ply,args)
        local tply, reason = LuctusFindPlyByName(string.lower(args))
        if not tply or not IsValid(tply) then
            SurfNotify(ply,"[admin]","Error: "..reason)
            return
        end
        tplytarget.ismuted = false
        SurfNotify(ply,"[admin]","Player is not muted anymore!")
    end,
    ["banply"] = function(adminPly,args)
        local tply, reason = LuctusFindPlyByName(string.lower(args))
        if not tply or not IsValid(tply) then
            SurfNotify(adminPly,"[admin]","Error: "..reason)
            return ""
        end
        LuctusDbBanPly(tply,adminPly:SteamID(),adminPly:Nick())
    end,
    ["bansid"] = function(adminPly,args)
        if not args or not string.find(args,"STEAM_%d:%d:%d+") then
            SurfNotify(adminPly,"[admin]","Usage: !bansid <steamid>")
            return ""
        end
        LuctusDbBanSteamid(args)
    end,
    ["unban"] = function(ply,args)
        if not args or not string.find(args,"STEAM_%d:%d:%d+") then
            SurfNotify(ply,"[admin]","Usage: !unban <steamid>")
            return ""
        end
        LuctusDbUnban(args)
    end,
    ["maprestart"] = function()
        SurfNotify(nil,"[admin]","Map will be restarted in 10 seconds!")
        timer.Simple(10,function()
            RunConsoleCommand("changelevel", game.GetMap())
        end)
    end,
    ["maplist"] = function(ply,args)
        SurfNotify(ply,"[admin]","Check your console!")
        local maps = file.Find("maps/surf_*.bsp","GAME")
        ply:PrintMessage(HUD_PRINTCONSOLE,"------------")
        ply:PrintMessage(HUD_PRINTCONSOLE,"Maps:")
        for k,v in pairs(maps) do
            ply:PrintMessage(HUD_PRINTCONSOLE,v)
        end
        ply:PrintMessage(HUD_PRINTCONSOLE,"------------")
    end,
    ["map"] = function(ply,args)
        if file.Exists("maps/"..args..".bsp","GAME") then
            SurfNotify(nil,"[admin]","Map will be changed to "..args.." in 10 seconds!")
            timer.Simple(10,function()
                RunConsoleCommand("changelevel", args)
            end)
        else
            SurfNotify(ply,"[admin]","This map doesn't exist on this server!")
        end
    end,
    ["setadmin"] = function(ply,args)
        local wantedPly, reason = LuctusFindPlyByName(args)
        if not IsValid(wantedPly) then
            SurfNotify(ply,"[admin]","Error: "..reason)
            return
        end
        wantedPly:SetUserGroup("admin")
        LuctusDbAddAdmin(wantedPly:SteamID(),wantedPly:Nick())
    end,
    ["removeadmin"] = function(ply,args)
        local wantedPly, reason = LuctusFindPlyByName(args)
        if not IsValid(wantedPly) then
            SurfNotify(ply,"[admin]","Error: "..reason)
            return
        end
        wantedPly:SetUserGroup("user")
        LuctusDbRemoveAdmin(wantedPly:SteamID())
    end,
    ["kill"] = function(admin,args)
        for k,v in pairs(player.GetAll()) do
            if v:Nick() == args then
                v:Kill()
            end
        end
    end,
}

function LuctusFindPlyByName(name)
    local ret = nil
    for k,v in pairs(player.GetAll()) do
        if string.find(string.lower(v:Nick()),name) then
            if ret ~= nil then
                return nil, "Too many players found!"
            end
            ret = v
        end
    end
    if ret == nil then
        return nil, "No players found!"
    end
    return ret, ""
end

hook.Add("PlayerSay","surf_admincommands",function(ply,text,team)
    if not ply:IsAdmin() then return end
    if string.StartWith(text,"/") or string.StartWith(text,"!") then
        local cmd = string.Right(text,string.len(text)-1)
        local argStr = cmd
        if string.find(cmd," ") then
            cmd = string.Split(argStr," ")[1]
            argStr = string.Split(text,cmd.." ")[2]
        end
        if surf_admincmds[cmd] then
            return surf_admincmds[cmd](ply,argStr)
        end
    end
end)
