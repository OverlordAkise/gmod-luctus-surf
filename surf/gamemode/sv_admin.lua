local superadmins = {
    ["STEAM_0:0:55735858"] = true,
}

--InitialSpawn doesn't want to work with SetUserGroup
hook.Add("PlayerSpawn","surf_admin_check",function(ply)
    if not ply.adminChecked then
        CheckAdmin(ply)
        ply.adminChecked = true
    end
end)

hook.Add("PlayerSay","surf_setadmin",function(ply,text,team)
    if ply:IsSuperAdmin() and string.StartWith(text,"!setadmin") then
        local wantedName = string.lower(string.Split(text," ")[2])
        local wantedPly = nil
        for k,v in pairs(player.GetAll()) do
            if string.find(string.lower(v:Nick()),wantedName) then
                if wantedPly ~= nil then
                    ply:PrintMessage(HUD_PRINTTALK, "[admin] Found 2 people! Please set the name better!")
                    return
                end
                wantedPly = v
            end
        end
        AddAdmin(wantedPly)
    end
    if ply:IsSuperAdmin() and string.StartWith(text,"!removeadmin") then
        local wantedName = string.lower(string.Split(text," ")[2])
        local wantedPly = nil
        for k,v in pairs(player.GetAll()) do
            if string.find(string.lower(v:Nick()),wantedName) then
                if wantedPly ~= nil then
                    ply:PrintMessage(HUD_PRINTTALK, "[admin] Found 2 people! Please set the name better!")
                    return
                end
                wantedPly = v
            end
        end
        RemoveAdmin(wantedPly)
    end
end)

function CheckAdmin(ply)
    local res = sql.Query("SELECT * FROM surf_admins WHERE sid = "..sql.SQLStr(ply:SteamID()))
    --sid,nick,role
    if res == false then
        print("[surf][db] ERROR DURING CheckAdmin!")
        print(sql.LastError())
        return
    end
    
    if not res then return end
    
    if res and res[1] then
        ply:SetUserGroup(res[1]["role"])
        print("[surf][admin] Successfully set usergroup '"..res[1]["role"].."' for '"..ply:Nick().."'")
    end
    if superadmins[ply:SteamID()] and ply:GetUserGroup() ~= "superadmin" then
        local res = sql.Query("INSERT INTO surf_admins(sid,nick,role) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(ply:Nick())..",'superadmin')")
        if res == false then
            print("[surf][db] ERROR DURING SUPERADMIN ADD!")
            print(sql.LastError())
            return
        end
        print("[surf][admin] Successfully saved superadmin for "..ply:Nick())
        ply:SetUserGroup("superadmin")
    end
end

function AddAdmin(ply)
    local res = sql.Query("INSERT INTO surf_admins(sid,nick,role) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(ply:Nick())..",'admin')")
    if res == false then
        print("[surf][db] ERROR DURING AddAdmin!")
        print(sql.LastError())
        return
    end
    ply:SetUserGroup("admin")
    print("[surf][admin] Successfully added player as admin!",ply:Nick(),ply:SteamID())
    PrintMessage(HUD_PRINTTALK,"[admin] Added player "..ply:Nick().." as admin!")
end

function RemoveAdmin(ply)
    local res = sql.Query("DELETE FROM surf_admins WHERE sid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        print("[surf][db] ERROR DURING RemoveAdmin!")
        print(sql.LastError())
        return
    end
    print("[surf][admin] Successfully removed player from admins! ("..ply:Nick()..")")
    PrintMessage(HUD_PRINTTALK,"[admin] Removed player "..ply:Nick().." from admins!")
end

function getPlyByName(name)
    if not name then return nil end
    for k,v in pairs(player.GetAll()) do
        if string.find(string.lower(v:Nick()),string.lower(name)) then
            return v
        end
    end
    return nil
end

local admin_commands = {}

admin_commands["list"] = function(args)
    PrintTable(args)
end

concommand.Add("lsa",function(ply,cmd,args,argStr)
    if not ply:IsAdmin() then return end
    PrintTable(args)
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
            ply:PrintMessage(HUD_PRINTTALK, "[admin] Usage: !resethighscore <steamid>")
            return ""
        end
        LuctusDbResetHighscore(args)
        local target = player.GetBySteamID(args)
        target:SetNWFloat( "record", 0 )
        PrintMessage(HUD_PRINTTALK, "[admin] High Score of "..args.." successfully deleted!")
    end,
    ["kick"] = function(ply,args)
        local tply, reason = LuctusFindPlyByName(string.lower(args))
        if not tply or not IsValid(tply) then
            ply:PrintMessage(HUD_PRINTTALK, "[admin] Error: "..reason)
            return
        end
        tply:Kick("You have been kicked!")
    end,
    ["mute"] = function(ply,args)
        local tply, reason = LuctusFindPlyByName(string.lower(args))
        if not tply or not IsValid(tply) then
            ply:PrintMessage(HUD_PRINTTALK, "[admin] Error: "..reason)
            return
        end
        tplytarget.ismuted = true
        ply:PrintMessage(HUD_PRINTTALK, "[admin] Player is now muted for everyone!")
    end,
    ["unmute"] = function(ply,args)
        local tply, reason = LuctusFindPlyByName(string.lower(args))
        if not tply or not IsValid(tply) then
            ply:PrintMessage(HUD_PRINTTALK, "[admin] Error: "..reason)
            return
        end
        tplytarget.ismuted = false
        ply:PrintMessage(HUD_PRINTTALK, "[admin] Player is not muted anymore!")
    end,
    ["banply"] = function(adminPly,args)
        local tply, reason = LuctusFindPlyByName(string.lower(args))
        if not tply or not IsValid(tply) then
            adminPly:PrintMessage(HUD_PRINTTALK, "[admin] Error: "..reason)
            return ""
        end
        LuctusDbBanPly(tply,adminPly:SteamID(),adminPly:Nick())
    end,
    ["bansid"] = function(adminPly,args)
        if not args or not string.find(args,"STEAM_%d:%d:%d+") then
            ply:PrintMessage(HUD_PRINTTALK, "[admin] Usage: !bansid <steamid>")
            return ""
        end
        LuctusDbBanSteamid(args)
    end,
    ["unban"] = function(ply,args)
        if not args or not string.find(args,"STEAM_%d:%d:%d+") then
            ply:PrintMessage(HUD_PRINTTALK, "[admin] Usage: !unban <steamid>")
            return ""
        end
        LuctusDbUnban(args)
    end,
    ["maprestart"] = function()
        PrintMessage(HUD_PRINTTALK, "[admin] Map will be restarted in 10 seconds!")
        timer.Simple(10,function()
            RunConsoleCommand("changelevel", game.GetMap())
        end)
    end,
    ["map"] = function(ply,args)
        if file.Exists("maps/"..args..".bsp","GAME") then
            PrintMessage(HUD_PRINTTALK, "[admin] Map will be changed to "..args.." in 10 seconds!")
            timer.Simple(10,function()
                RunConsoleCommand("changelevel", args)
            end)
        else
            ply:PrintMessage(HUD_PRINTTALK, "[admin] This map doesn't exist on this server!")
        end
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
