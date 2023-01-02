rtv_maps = {}
rtv_ent = rtv_ent or nil

net.Receive("surf_rtvmaps",function()
    rtv_ent = ents.GetAll()[1]
    local done = net.ReadBool()
    if done then
        rtv_maps = {}
        hook.Remove("HUDPaint","surf_rtv_votemaps")
        return
    end
    local mapNr = net.ReadInt(6)
    rtv_maps = {}
    for i=1,mapNr do
        local map = net.ReadString()
        table.insert(rtv_maps,map)
    end
    print("[surfRTV] Maps received!")
    PrintTable(rtv_maps)
    hook.Add("HUDPaint","surf_rtv_votemaps",drawRTV)
end)

function drawRTV()
    local rtime = math.Clamp(math.Round(rtv_ent:GetNWInt("rtv_autotime",0) - CurTime()),0,30)
    draw.SimpleTextOutlined("RTV Mapvote ("..rtime.."s)", "DermaDefault", 10, (ScrH()/2-50), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.3, Color(0, 0, 0))
    for k,v in pairs(rtv_maps) do
        local text = "["..rtv_ent:GetNWInt(v,0).."] "..k..". "..v
        if v == game.GetMap() then
            text = "["..rtv_ent:GetNWInt(v,0).."] "..k..". ".."Extend current map"
        end
        draw.SimpleTextOutlined(text, "DermaDefault", 10, (ScrH()/2-50)+15*(k), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.3, Color(0, 0, 0))
    end
end

function ConvertRTVTime(ns)
    if ns < 0 then return "NOW" end
    if ns > 3600 then
        return string.format( "%d:%.2d:%.2d", math.floor( ns / 3600 ), math.floor( ns / 60 % 60 ), math.floor( ns % 60 ))
    else
        return string.format( "%.2d:%.2d", math.floor( ns / 60 % 60 ), math.floor( ns % 60 ))
    end
end


hook.Add("HUDPaint","surf_rtv_till_time", function()
    if not IsValid(rtv_ent) then return end
    local text = "Time till mapchange:   "..ConvertRTVTime(rtv_ent:GetNWInt("rtv_autotime",0)-CurTime())
    surface.SetDrawColor( Color(35, 35, 35) )
    surface.DrawRect( 20, ScrH() - 150, 230, 30 )
    draw.SimpleText(text, "HudHintTextLarge", 20+12, ScrH() - 155 + 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end)

hook.Add("PlayerBindPress", "surf_rtv_voting", function(ply, bind, pressed)
    if (string.find( bind, "slot")) then
        local nr = string.Split(bind,"slot")[2]
        if nr and tonumber(nr) and rtv_maps[tonumber(nr)] then
            net.Start("surf_rtvmaps")
                net.WriteString(rtv_maps[tonumber(nr)])
            net.SendToServer()
        end
        end
end)

hook.Add("InitPostEntity", "surf_rtv_ent", function()
    rtv_ent = ents.GetAll()[1]
end)


net.Receive("surf_rtvsound",function()
    LocalPlayer():EmitSound(net.ReadString())
end)
