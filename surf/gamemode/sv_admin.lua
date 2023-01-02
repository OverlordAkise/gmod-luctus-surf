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

hook.Add("PlayerSay","surf_admincommands",function(ply,text,team)
    if ply:IsAdmin() then
        local cmd = string.Split(text," ")[1]
        local firstArg = string.Split(text," ")[2]
        local secondArg = string.Split(text," ")[3]
        local thirdArg = string.Split(text," ")[4]
        local target = firstArg and getPlyByName(firstArg) or nil

        if cmd == "!kick" then
            if target then
                target:Kick("You have been kicked!")
            else
                ply:PrintMessage(HUD_PRINTTALK, "[admin] Can't find target player!")
            end
            return
        end
        
        if cmd == "!frtv" then
            rtvStart()
        end
        
        if cmd == "!mute" then
            if target then
                target.ismuted = true
                ply:PrintMessage(HUD_PRINTTALK, "[admin] Player is now muted for everyone!")
            end
        end
        
        if cmd == "!unmute" then
            if target then
                target.ismuted = false
                ply:PrintMessage(HUD_PRINTTALK, "[admin] Player is now unmuted for everyone!")
            end
        end

        if cmd == "!maprestart" then
            PrintMessage(HUD_PRINTTALK, "[admin] Map will be restarted in 10 seconds!")
            timer.Simple(10,function()
                RunConsoleCommand("changelevel", game.GetMap())
            end)
            return
        end

        if cmd == "!map" then
            if firstArg then
                if file.Exists("maps/"..firstArg..".bsp","GAME") then
                    PrintMessage(HUD_PRINTTALK, "[admin] Map will be changed to "..firstArg.." in 10 seconds!")
                    timer.Simple(10,function()
                        RunConsoleCommand("changelevel", firstArg)
                    end)
                else
                    ply:PrintMessage(HUD_PRINTTALK, "[admin] This map doesn't exist on this server!")
                end
                return
            else
                ply:PrintMessage(HUD_PRINTTALK, "[admin] Usage: !map <mapname>")
                return ""
            end
        end

        if cmd == "!ban" then
            if target then
                target:Ban(tonumber(secondArg) or 0,true)
                PrintMessage(HUD_PRINTTALK, "[admin] "..target:Nick().." has been banned for "..(tonumber(secondArg) or "infinite").." minutes!")
            else
                ply:PrintMessage(HUD_PRINTTALK, "[admin] Can't find target player!")
                return ""
            end
        end

        if cmd == "!banid" then
            if firstArg then
                --local res = sql.Query("INSERT INTO gmod_bans (sid, nick, reason, sidadmin, nickadmin) VALUES("..sql.SQLStr(firstArg)..",UNKNOWN,"..(thirdArg and sql.SQLStr(thirdArg) or "''")..",
                PrintMessage(HUD_PRINTTALK, "[admin] "..firstArg.." has been banned for "..(tonumber(secondArg) or "infinite").." minutes!")
            else
                ply:PrintMessage(HUD_PRINTTALK, "[admin] Usage: !banid <steamid> <time in minutes>")
                return ""
            end

        end

        if cmd == "!unban" then
            if firstArg then
                RunConsoleCommand("removeid", firstArg)
                RunConsoleCommand("writeid")
                PrintMessage(HUD_PRINTTALK, "[admin] "..firstArg.." has been unbanned!")
            else
                ply:PrintMessage(HUD_PRINTTALK, "[admin] Please provide a valid steamid!")
                return ""
            end
        end
    end
end)
