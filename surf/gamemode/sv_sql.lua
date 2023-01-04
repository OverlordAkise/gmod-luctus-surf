
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
