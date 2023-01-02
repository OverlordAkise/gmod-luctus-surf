SQL = {}

local function PrintError(lastError)
    print("[surf][db] Error during Database Query!")
    print(lastError)
end

function SQL:InitDB()
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
    res = sql.Query("CREATE TABLE IF NOT EXISTS gmod_bans (sid INTEGER, nick TEXT, unbanTime TEXT, reason TEXT, sidadmin TEXT, nickadmin TEXT);")
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
