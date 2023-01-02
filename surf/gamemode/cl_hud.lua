local fo, cl = string.format, math.Clamp


local Xo = 20
local Yo = 115
local color_white = Color(255,255,255)
local rtvStartX = ScrW()-220
local rtvStartY = 20
    
local rtvtime = 0
local localtime = 0
local mapname = ""

timer.Create("luctus_surf_rtv_time",1,0,function()
    mapname = game.GetMap()
    localtime = "Time: "..os.date("%H:%M:%S", os.time())
    rtvtime = "rtv:    "..ConvertRTVTime(GetGlobal2Int("rtv_autotime",0)-CurTime())
end)

function GM:HUDPaintBackground()
    local scrh = ScrH()
    local lpc = LocalPlayer()
    if not IsValid(lpc) then return end
    
    if lpc:GetObserverTarget() and IsValid(lpc:GetObserverTarget()) and lpc:GetObserverTarget():IsPlayer() then
        lpc = lpc:GetObserverTarget()
    end

    local ob = lpc:GetObserverTarget()
    surface.SetDrawColor( LUCTUS_SURF_COL_BG )
    surface.DrawRect( Xo, scrh - Yo, 230, 95 )
    surface.SetDrawColor( LUCTUS_SURF_COL_FG )
    surface.DrawRect( Xo + 5, scrh - Yo + 5, 220, 55 )
    surface.DrawRect( Xo + 5, scrh - Yo + 65, 220, 25 )

    draw.SimpleText( "Time:", "Trebuchet24", Xo + 12, scrh - Yo + 20, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    draw.SimpleText( "PB:", "Trebuchet24", Xo + 12, scrh - Yo + 45, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

    local nCurrent = lpc:GetNWFloat("starttime",0) ~= 0 and CurTime() - lpc:GetNWFloat("starttime",0) or 0
    local nSpeed = lpc:GetVelocity():Length2D()
    draw.SimpleText( PrettifyTime( nCurrent ), "Trebuchet24", Xo + 64 + 12, scrh - Yo + 20, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    draw.SimpleText( PrettifyTime( lpc:GetNWFloat("record",0) ), "Trebuchet24", Xo + 64 + 12, scrh - Yo + 45, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

    local cp = cl( nSpeed, 0, 5000 ) / 5000
    surface.SetDrawColor(LUCTUS_SURF_COL_ACCENT)
    surface.DrawRect(Xo + 5, scrh - Yo + 65, cp * 220, 25)

    draw.SimpleText( fo( "%.0f u/s", nSpeed ), "Trebuchet24", Xo + 115, scrh - Yo + 77, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    
    --Info
    surface.SetDrawColor( LUCTUS_SURF_COL_BG )
    surface.SetDrawColor( LUCTUS_SURF_COL_BG )
    surface.DrawRect( rtvStartX, rtvStartY, 200, 103 )
    surface.SetDrawColor( LUCTUS_SURF_COL_FG )
    surface.DrawRect( rtvStartX + 5, rtvStartY + 5, 190, 93 )
    draw.SimpleText(mapname, "Trebuchet24", rtvStartX+20, rtvStartY+20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(localtime, "Trebuchet24", rtvStartX+20, rtvStartY+50, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(rtvtime, "Trebuchet24", rtvStartX+20, rtvStartY+80, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end
