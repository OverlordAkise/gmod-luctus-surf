util.AddNetworkString("surf_rtvmaps")
util.AddNetworkString("surf_rtvsound")

rtv_percentage = 0.5 --50% needed to !rtv for it to kick in

rtv_in_progress = false
rtv_ent = rtv_ent or nil
rtv_selectedMaps = {}


function rtvStart()
    if rtv_in_progress then return end
    rtv_in_progress = true
    timer.Remove("surf_rtv_auto_timer")
    SetGlobal2Int("rtv_autotime",CurTime()+30)
    local allMaps = {}
    local res = sql.Query( "SELECT map, tier, type FROM surf_map" )
    if res == false then
        print("[surfDB] ERROR DURING RTV MAP SELECT!")
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
    --add current one too
    rtv_selectedMaps[game.GetMap()] = 0
    SetGlobal2Int(game.GetMap(),0)

    print("[surfRTV] Selected maps for the next map:")
    PrintTable(rtv_selectedMaps)

    net.Start("surf_rtvmaps")
        net.WriteBool(false)
        net.WriteInt(table.Count(rtv_selectedMaps),6)
        for k,v in pairs(rtv_selectedMaps) do
            net.WriteString(k)
        end
    net.Broadcast()

    timer.Create("surf_rtv_end",30,1,function()
        rtvEnd()
    end)
end

net.Receive("surf_rtvmaps", function(len,ply)
    if not ply.rtvCooldown then ply.rtvCooldown = 0 end
    if ply.rtvCooldown > CurTime() then return end
    ply.rtvCooldown = CurTime() + 5
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

function rtvEnd()
    rtv_in_progress = false
    for k,v in pairs(player.GetAll()) do
        v.rtvMap = nil
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
    for k,v in pairs(nextMaps) do
        --get highest map
        if v > nextMaps[highestMap] then
            highestMap = k
        end
    end
    for k,v in pairs(nextMaps) do
        --check if double-win
        if v == nextMaps[highestMap] then
            table.insert(nextMultiple,k)
        end
    end
    --insert highest map
    table.insert(nextMultiple,highestMap)
    if (#nextMultiple == 1) then
        highestMap = nextMultiple[1]
    else
        highestMap = nextMultiple[math.random(1,#nextMultiple)]
    end
    --if no one voted on anything
    if (table.Count(nextMaps) == 0) then
        highestMap = game.GetMap()
    end
    print("DEBUG:")
    print("nextMaps:")
    PrintTable(nextMaps)
    print("highestMap:")
    print(highestMap)
    print("nextMultiple:")
    PrintTable(nextMultiple)
    print("#nextMaps")
    print(table.Count(nextMaps))
    if highestMap ~= game.GetMap() then
        PrintMessage(HUD_PRINTTALK, "[surf] Next map is "..highestMap.."!")
        PrintMessage(HUD_PRINTTALK, "[surf] Changing level in 5 seconds!")
        net.Start("surf_rtvmaps")
            net.WriteBool(true)
        net.Broadcast()
        timer.Simple(5,function()
        RunConsoleCommand("changelevel",highestMap)
        end)
    else
        PrintMessage(HUD_PRINTTALK, "[surf] The map will be extended by 30min!")
        timer.Create("surf_rtv_auto_timer",1800,1,function() rtvStart() end)
        SetGlobal2Int("rtv_autotime",CurTime()+1800)
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
    if text == "!rtv" then
        if rtv_in_progress then
            ply:PrintMessage(HUD_PRINTTALK, "[surf] A vote is already in progress!")
            return ""
        end
        if not ply.rtvd then
            ply.rtvd = 0
            ply:PrintMessage(HUD_PRINTTALK, "[surf] You rocked the vote!")
            if ply.rtvd < CurTime() then
                ply.rtvd = CurTime() + 5
                local rtvCount = 0
                for k,v in pairs(player.GetAll()) do
                    if ply.rtvd then
                        rtvCount = rtvCount + 1
                    end
                end
                if (rtvCount/#player.GetAll()) > rtv_percentage then
                    rtvStart()
                    for k,v in pairs(player.GetAll()) do
                        ply.rtvd = nil
                    end
                end
            end
        else
            ply:PrintMessage(HUD_PRINTTALK, "[surf] You already rocked the vote!")
        end
    end
end)

hook.Add("PlayerDisconnected","surf_rtv_recalculate",function(ply)
    timer.Simple(0.1,function()
        local rtvCount = 0
        for k,v in pairs(player.GetAll()) do
            if ply.rtvd then
                rtvCount = rtvCount + 1
            end
        end
        if (rtvCount/#player.GetAll()) > rtv_percentage then
            rtvStart()
        end
    end)
end)

hook.Add("PlayerInitialSpawn","surf_rtv_in_progress",function(ply)
    hook.Add("SetupMove", ply, function( self, ply, _, cmd )
        if self == ply and not cmd:IsForced() then
            if rtv_in_progress then
                net.Start("surf_rtvmaps")
                    net.WriteBool(false)
                    net.WriteInt(table.Count(rtv_selectedMaps),6)
                    for k,v in pairs(rtv_selectedMaps) do
                        net.WriteString(k)
                    end
                net.Broadcast()
            end
            hook.Remove( "SetupMove", self )
        end
    end)
end)


hook.Add("InitPostEntity", "surf_rtv_tilltime", function()
    timer.Create("surf_rtv_auto_timer",1800,1,function() rtvStart() end)
    rtv_ent = ents.GetAll()[1]
    SetGlobal2Int("rtv_autotime",CurTime()+1800)
end)
