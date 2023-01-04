
local function PrintError(lastError)
    print("[surf][db] Error during Database Query!")
    ErrorNoHaltWithStack(lastError)
end

function LuctusDbInit()
    local res = nil
    local insertDefaults = false
    if not sql.TableExists("surf_zones") then
        insertDefaults = true
    end
    res = sql.Query("CREATE TABLE IF NOT EXISTS surf_map (map TEXT, tier INTEGER, type INTEGER, runs INTEGER);")
    if res == false then PrintError(sql.LastError()) end
    res = sql.Query("CREATE TABLE IF NOT EXISTS surf_times (sid TEXT, nick TEXT, map TEXT, style INTEGER, time FLOAT, date DATETIME);")
    if res == false then PrintError(sql.LastError()) end
    res = sql.Query("CREATE TABLE IF NOT EXISTS surf_zones (map TEXT, type INTEGER, posone TEXT, postwo TEXT);")
    if res == false then PrintError(sql.LastError()) end
    res = sql.Query("CREATE TABLE IF NOT EXISTS surf_admins (sid TEXT, nick TEXT, role TEXT);")
    if res == false then PrintError(sql.LastError()) end
    res = sql.Query("CREATE TABLE IF NOT EXISTS gmod_bans (sid VARCHAR(255), nick TEXT, unbanTime TEXT, reason TEXT, sidadmin TEXT, nickadmin TEXT);")
    res = sql.Query("CREATE TABLE IF NOT EXISTS surf_playtime (steamid TEXT, playtime INTEGER )")
    if res == false then PrintError(sql.LastError()) end
    
    if insertDefaults then
        print("[surf][db] Inserting default values for maps...")
        LuctusDbInsertDefaultZones()
        print("[surf][db] Done inserting default values for maps!")
    end

    res = sql.Query("SELECT * FROM surf_map WHERE map = "..sql.SQLStr(game.GetMap()))
    if res == false then PrintError(sql.LastError()) end
    if not res or not res[1] then
        print("[surf][db] New map, inserting into surf_map!")
        res = sql.Query("INSERT INTO surf_map VALUES ("..sql.SQLStr(game.GetMap())..", 1, 1, 0);")
        if res == false then PrintError(sql.LastError()) end
    end
    print("[surf][db] Successfully setup database")
end


function LuctusDbLoadPlyRecord(ply)
    ply:SetNWInt( "style", 1 )
    ply:SetNWFloat( "record", 0 )
    local res = sql.QueryValue("SELECT time FROM surf_times WHERE sid = "..sql.SQLStr(ply:SteamID()).." AND map = "..sql.SQLStr(game.GetMap()))
    if res == false then
        print("[surf][db] ERROR DURING LOAD PLY RECORD!")
        ErrorNoHaltWithStack(sql.LastError())
        return
    end
    if res then
        ply:SetNWFloat("record",tonumber(res))
        print("[surf][db] Successfully loaded record time for player "..ply:Nick())
    end
end


function LuctusDbSavePlyRecord(ply, newtime, oldtime)
    local res = sql.Query( "DELETE FROM surf_times WHERE map = "..sql.SQLStr(game.GetMap()).." AND sid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        print("[surf][db] ERROR DURING SAVE PLAYER RECORD DELETE OLD!")
        ErrorNoHaltWithStack(sql.LastError())
    end
    res = sql.Query("INSERT INTO surf_times(sid, nick, map, style, time, date) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(ply:Nick())..","..sql.SQLStr(game.GetMap())..",1,"..newtime..",datetime('now'))")
    if res == false then
        print("[surf][db] ERROR DURING SAVE PLAYER RECORD ADD NEW!")
        ErrorNoHaltWithStack(sql.LastError())
        return
    end
    ply:PrintMessage(HUD_PRINTTALK, "You completed the map in a new personal record time!")
    slower_times_count = sql.QueryValue("SELECT COUNT(*) AS c FROM surf_times WHERE time > "..newtime.." AND map = "..sql.SQLStr(game.GetMap()))
    all_times_count = sql.QueryValue("SELECT COUNT(*) AS c FROM surf_times WHERE map = "..sql.SQLStr(game.GetMap()))
    if slower_times_count == false or all_times_count == false then
        print("[surf][db] ERROR DURING PLACEMENT COUNTING!")
        ErrorNoHaltWithStack(sql.LastError())
        return
    end
    ply:PrintMessage(HUD_PRINTTALK, "Your time is place "..(1-slower_times_count).."/"..all_times_count.." on this map!")
end


function LuctusDbDeleteZone(action)
    local res = sql.Query("DELETE FROM surf_zones WHERE map = "..sql.SQLStr(game.GetMap()).." AND type = "..action)
    if res == false then
        print("[surf][db] ERROR DURING DELETE ZONE!")
        ErrorNoHaltWithStack(sql.LastError())
    end
end


function LuctusDbInsertZone(zoneType, firVec, secVec)
    local res = sql.Query("INSERT INTO surf_zones VALUES ("..sql.SQLStr(game.GetMap())..","..zoneType..", "..sql.SQLStr(firVec)..", "..sql.SQLStr(secVec)..")")
        if res == false then
            print("[surf][db] ERROR DURING INSERT ZONE!")
            ErrorNoHaltWithStack(sql.LastError())
            return false
        end
    return true
end


function LuctusDbCheckAdmin(steamid)
    local res = sql.QueryValue("SELECT nick FROM surf_admins WHERE sid = "..sql.SQLStr(steamid))
    if res == false then
        print("[surf][db] ERROR DURING CHECK ADMIN!")
        ErrorNoHaltWithStack(sql.LastError())
        return false
    end
    if not res then
        return false
    end
    return true
end


function LuctusDbAddAdmin(steamid,nick)
    local res = sql.Query("INSERT INTO surf_admins(sid,nick,role) VALUES("..sql.SQLStr(steamid)..","..sql.SQLStr(nick)..",'admin')")
    if res == false then
        print("[surf][db] ERROR DURING AddAdmin!")
        ErrorNoHaltWithStack(sql.LastError())
        return
    end
end

function LuctusDbRemoveAdmin(steamid)
    local res = sql.Query("DELETE FROM surf_admins WHERE sid = "..sql.SQLStr(steamid))
    if res == false then
        print("[surf][db] ERROR DURING ADMIN REMOVE!")
        ErrorNoHaltWithStack(sql.LastError())
        return
    end
end


function LuctusDbBanPly(ply,adminId,adminName)
    local res = sql.Query(string.format("INSERT INTO gmod_bans(sid, nick, unbanTime, reason, sidadmin, nickadmin) VALUES(%s,%s,%s,%s,%s,%s)", sql.SQLStr(ply:SteamID()), sql.SQLStr(ply:Nick()), "-1", "'unknown'", sql.SQLStr(adminId), sql.SQLStr(adminName)))
    if res == false then
        print("[surf][db] ERROR DURING BAN PLY!")
        ErrorNoHaltWithStack(sql.LastError())
    end
    ply:Kick("You have been banned!")
end


function LuctusDbBanSteamid(steamid)
    local res = sql.Query("INSERT INTO gmod_bans(sid,unbanTime) VALUES("..sql.SQLStr(steamid)..",'-1')")
    if res == false then
        print("[surf][db] ERROR DURING BAN STEAMID!")
        ErrorNoHaltWithStack(sql.LastError())
    end
    local target = player.GetBySteamID(steamid)
    if target then
        target:Kick("You have been banned!")
    end
end


function LuctusDbUnban(steamid)
    local res = sql.Query("DELETE FROM gmod_bans WHERE sid = "..sql.SQLStr(steamid))
    if res == false then
        print("[surf][db] ERROR DURING UNBAN!")
        ErrorNoHaltWithStack(sql.LastError())
    end
end


function LuctusDbIsPlyBanned(steamid)
    local res = sql.QueryValue("SELECT unbanTime FROM gmod_bans WHERE sid = "..sql.SQLStr(steamid))
    if res then
        return true
    end
    return false
end

function LuctusDbResetHighscore(steamid)
    local res = sql.Query("DELETE FROM surf_times WHERE map = "..sql.SQLStr(game.GetMap()).." AND sid = "..sql.SQLStr(args))
    if res == false then
        print("[surf][db] ERROR DURING RESETHIGHSCORE")
        ErrorNoHaltWithStack(sql.LastError())
    end
end


function LuctusDbPlaytimeLoad(ply)
    local playtime = sql.QueryValue("SELECT playtime FROM surf_playtime WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if playtime == false then
        print("[surf][db] ERROR DURING PLAYTIME LOAD")
        ErrorNoHaltWithStack(sql.LastError())
    end
    if not playtime then
        sql.Query("INSERT INTO surf_playtime(steamid, playtime) VALUES("..sql.SQLStr(ply:SteamID())..",0)")
        return
    end
    ply:SetNWInt("playtime",tonumber(playtime))
end


function LuctusDbPlaytimeSave(steamid,playtime)
    local res = sql.Query("UPDATE surf_playtime SET playtime = "..playtime.." WHERE steamid = "..sql.SQLStr(steamid))
    if res == false then
        print("[surf][db] ERROR DURING PLAYTIME SAVE")
        ErrorNoHaltWithStack(sql.LastError())
    end
end

function LuctusDbAddMapPlay()
    sql.Query("UPDATE surf_map SET runs = runs + 1 WHERE map = "..sql.SQLStr(game.GetMap()))
end
