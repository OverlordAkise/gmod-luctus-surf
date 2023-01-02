
local ViewSpec = CreateClientConVar( "ls_showspec", "1", true, false )

local fo, cl, ct = string.format, math.Clamp, CurTime


local Xo = 20
local Yo = 115
local colwhite = Color(255,255,255)

function GM:HUDPaintBackground()
    local scrh = ScrH()
    local lpc = LocalPlayer()
    if not IsValid( lpc ) then return end
    
    if lpc:GetObserverTarget() and IsValid( lpc:GetObserverTarget() ) and lpc:GetObserverTarget():IsPlayer() then
        lpc = lpc:GetObserverTarget()
    end

    local ob = lpc:GetObserverTarget()
    surface.SetDrawColor( Color(35, 35, 35) )
    surface.DrawRect( Xo, scrh - Yo, 230, 95 )
    surface.SetDrawColor( Color(42, 42, 42) )
    surface.DrawRect( Xo + 5, scrh - Yo + 5, 220, 55 )
    surface.DrawRect( Xo + 5, scrh - Yo + 65, 220, 25 )

    draw.SimpleText( "Time:", "HudHintTextLarge", Xo + 12, scrh - Yo + 20, colwhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    draw.SimpleText( "PB:", "HudHintTextLarge", Xo + 12, scrh - Yo + 45, colwhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

    local nCurrent = lpc:GetNWFloat("starttime",0) ~= 0 and CurTime() - lpc:GetNWFloat("starttime",0) or 0
    local nSpeed = lpc:GetVelocity():Length2D()
    draw.SimpleText( PrettifyTime( nCurrent ), "HudHintTextLarge", Xo + 64 + 12, scrh - Yo + 20, colwhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    draw.SimpleText( PrettifyTime( lpc:GetNWFloat("record",0) ), "HudHintTextLarge", Xo + 64 + 12, scrh - Yo + 45, colwhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

    local cp = cl( nSpeed, 0, 5000 ) / 5000
    surface.SetDrawColor( Color( 100, 100, 200, 255 ) )
    surface.DrawRect( Xo + 5, scrh - Yo + 65, cp * 220, 25 )

    draw.SimpleText( fo( "%.0f u/s", nSpeed ), "HudHintTextLarge", Xo + 115, scrh - Yo + 77, colwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    --if lpc:GetObserverTarget() then
    --draw.SimpleText( "SPECTATING "..lpc:GetObserverTarget():Nick(), "Default", ScrW(), scrh - 100, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    --end

    if ViewSpec:GetBool() then
    --TODO: Add a list of spectators to the right
    end
end
