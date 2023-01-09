util.AddNetworkString("surf_rtvmaps")
util.AddNetworkString("surf_rtvsound")
util.AddNetworkString("surf_rtv_livejoin")

rtv_in_progress = false
rtv_selectedMaps = {}
rtv_allowed = false

function SurfRtvCheck()
    local rtvCount = 0
    local plyAll = player.GetAll()
    for k,v in pairs(plyAll) do
        if v.rtvd then
            rtvCount = rtvCount + 1
        end
    end
    
    if #plyAll == 1 and rtvCount == 1 then SurfRtvStart() end
    
    if #plyAll == 2 and rtvCount ~= 2 then return end
    
    if (rtvCount/#plyAll) > LUCTUS_SURF_RTV_PERCENT_NEEDED then
        SurfRtvStart()
    end
end

function SurfRtvStart()
    if rtv_in_progress then return end
    rtv_in_progress = true
    timer.Remove("surf_rtv_auto_timer")
    SetGlobal2Int("rtv_autotime",CurTime()+LUCTUS_SURF_RTV_VOTE_DURATION)
    local allMaps = {}
    local res = sql.Query( "SELECT map, tier, type FROM surf_map" )
    if res == false then
        print("[surf][db] ERROR DURING RTV MAP SELECT!")
        print(sql.LastError())
        return
    end
    for k,v in pairs(res) do
        if file.Exists("maps/"..v["map"]..".bsp","GAME") and v["map"] ~= game.GetMap() then
            table.insert(allMaps,v["map"])
        end
    end
    rtv_selectedMaps = {}
    for i=1,5 do
        if #allMaps > 0 then
            local rindex = math.random(1,#allMaps)
            rtv_selectedMaps[allMaps[rindex]] = 0
            SetGlobal2Int(allMaps[rindex],0)
            table.remove(allMaps,rindex)
        end
    end
    --add current map for extended duration too
    rtv_selectedMaps[game.GetMap()] = 0
    SetGlobal2Int(game.GetMap(),0)

    print("[surf][rtv] Selected maps for the next map:")
    PrintTable(rtv_selectedMaps)

    net.Start("surf_rtvmaps")
        net.WriteBool(false)
        net.WriteInt(table.Count(rtv_selectedMaps),6)
        for k,v in pairs(rtv_selectedMaps) do
            net.WriteString(k)
        end
    net.Broadcast()

    timer.Create("surf_rtv_end",LUCTUS_SURF_RTV_VOTE_DURATION,1,function()
        SurfRtvEnd()
    end)
    SurfNotify(nil,"[rtv]","A vote has started!",false,"combined/k_lab/k_lab_al_moveon01_cc.wav")
end

net.Receive("surf_rtvmaps", function(len,ply)
    if not ply.rtvCooldown then ply.rtvCooldown = 0 end
    if ply.rtvCooldown > CurTime() then return end
    ply.rtvCooldown = CurTime() + LUCTUS_SURF_RTV_VOTE_COOLDOWN
    local map = net.ReadString()
    if rtv_selectedMaps[map] then
        rtv_selectedMaps[map] = rtv_selectedMaps[map] + 1
        if ply.rtvMap then
            rtv_selectedMaps[ply.rtvMap] = rtv_selectedMaps[ply.rtvMap] - 1
            SetGlobal2Int(ply.rtvMap,rtv_selectedMaps[ply.rtvMap])
        end
        ply.rtvMap = map
        SetGlobal2Int(map,rtv_selectedMaps[map])
        net.Start("surf_rtvsound")
            net.WriteString("buttons/button14.wav")
        net.Send(ply)
    end
end)

function SurfRtvEnd()
    rtv_in_progress = false
    for k,v in pairs(player.GetAll()) do
        v.rtvMap = nil
        v.rtvd = nil
    end
    local nextMaps = {}
    local highestMap = ""
    local nextMultiple = {}
    for k,v in pairs(rtv_selectedMaps) do
        --get maps that have votes
        if GetGlobal2Int(k,0) > 0 then
            nextMaps[k] = GetGlobal2Int(k,0)
            highestMap = k --for no-nil later
        end
    end
    --get highest map
    for k,v in pairs(nextMaps) do
        if v > nextMaps[highestMap] then
            highestMap = k
        end
    end
    --check if its a draw
    for k,v in pairs(nextMaps) do
        if v == nextMaps[highestMap] then
            table.insert(nextMultiple,k)
        end
    end
    --select randomly from pool of highest maps
    highestMap = nextMultiple[math.random(1,#nextMultiple)]
    --if no one voted extend current map
    if (table.Count(nextMaps) == 0) then
        highestMap = game.GetMap()
    end
    print("[surf][rtv] Next map:",highestMap)
    if highestMap ~= game.GetMap() then
        SurfNotify(nil,"[rtv]","Next map is "..highestMap.."!")
        SurfNotify(nil,"[rtv]","Changing level in "..LUCTUS_SURF_RTV_MAPCHANGE_DELAY.." seconds!")
        SetGlobal2Int("rtv_autotime",CurTime()+LUCTUS_SURF_RTV_MAPCHANGE_DELAY)
        net.Start("surf_rtvmaps")
            net.WriteBool(true)
        net.Broadcast()
        timer.Simple(LUCTUS_SURF_RTV_MAPCHANGE_DELAY,function()
            RunConsoleCommand("changelevel",highestMap)
        end)
    else
        SurfNotify(nil,"[rtv]","The map will be extended by "..(LUCTUS_SURF_RTV_AUTO_TIME/60).."min!")
        timer.Create("surf_rtv_auto_timer",LUCTUS_SURF_RTV_AUTO_TIME,1,function() SurfRtvStart() end)
        SetGlobal2Int("rtv_autotime",CurTime()+LUCTUS_SURF_RTV_AUTO_TIME)
        --CleanUp
        for k,v in pairs(rtv_selectedMaps) do
            SetGlobal2Int(k,0)
        end
        rtv_selectedMaps = {}
        net.Start("surf_rtvmaps")
            net.WriteBool(true)
        net.Broadcast()
    end
end

hook.Add("PlayerSay","surf_rtv_chat",function(ply,text,team)
    if text ~= "!rtv" then return end
    local plyAll = player.GetAll()
    if rtv_in_progress then
        SurfNotify(ply,"[rtv]","A vote is already in progress!")
        return
    end
    if not rtv_allowed then
        SurfNotify(ply,"[rtv]","You aren't allowed to vote yet!")
        return
    end
    if not ply.rtvd then
        ply.rtvd = CurTime()
        SurfNotify(ply,"[rtv]","You rocked the vote!")
        SurfRtvCheck()
    else
        SurfNotify(ply,"[rtv]","You already rocked the vote!")
        SurfRtvCheck()
    end
end)

hook.Add("PlayerDisconnected","surf_rtv_recalculate",function(ply)
    timer.Simple(0.1,function()
        SurfRtvCheck()
    end)
end)

net.Receive("surf_rtv_livejoin",function(len,ply)
    if ply.rtvsynced then return end
    ply.rtvsynced = true
    if rtv_in_progress then
        net.Start("surf_rtvmaps")
            net.WriteBool(false)
            net.WriteInt(table.Count(rtv_selectedMaps),6)
            for k,v in pairs(rtv_selectedMaps) do
                net.WriteString(k)
            end
        net.Broadcast()
    end
end)


hook.Add("InitPostEntity", "surf_rtv_autovote_antispam", function()
    timer.Create("surf_rtv_antispam_mapchange",LUCTUS_SURF_RTV_AUTO_ANTISPAM,1,function()
        rtv_allowed = true
    end)
    if LUCTUS_SURF_RTV_AUTO_ANTISPAM < 10 then
        rtv_allowed = true
    end
    timer.Create("surf_rtv_auto_timer",LUCTUS_SURF_RTV_AUTO_TIME,1,function()
        SurfRtvStart()
    end)
    SetGlobal2Int("rtv_autotime",CurTime()+LUCTUS_SURF_RTV_AUTO_TIME)
end)
