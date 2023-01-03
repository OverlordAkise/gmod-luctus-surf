rtv_maps = {}

local color_white = Color(255, 255, 255)
local color_black = Color(0, 0, 0)

net.Receive("surf_rtvmaps",function()
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
    print("[surf][rtv] Map vote started, maps received!")
    PrintTable(rtv_maps)
    hook.Add("HUDPaint","surf_rtv_votemaps",SurfDrawRtv)
end)

function SurfDrawRtv()
    local rtime = math.Clamp(math.Round(GetGlobal2Int("rtv_autotime",0) - CurTime()),0,30)
    draw.SimpleTextOutlined("RTV Mapvote ("..rtime.."s)", "DermaDefault", 10, (ScrH()/2-50), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.3, color_black)
    for k,v in pairs(rtv_maps) do
        local text = "["..GetGlobal2Int(v,0).."] "..k..". "..v
        if v == game.GetMap() then
            text = "["..GetGlobal2Int(v,0).."] "..k..". ".."Extend current map"
        end
        draw.SimpleTextOutlined(text, "DermaDefault", 10, (ScrH()/2-50)+15*(k), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.3, color_black)
    end
end

hook.Add("PlayerBindPress", "surf_rtv_voting", function(ply, bind, pressed)
    if (string.StartWith( bind, "slot")) then
        local nr = string.Split(bind,"slot")[2]
        if nr and tonumber(nr) and rtv_maps[tonumber(nr)] then
            net.Start("surf_rtvmaps")
                net.WriteString(rtv_maps[tonumber(nr)])
            net.SendToServer()
        end
    end
end)

net.Receive("surf_rtvsound",function()
    surface.PlaySound(net.ReadString())
end)
