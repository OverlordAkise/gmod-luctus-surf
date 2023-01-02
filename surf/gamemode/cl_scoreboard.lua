--Luctus Scoreboard
--Made by OverlordAkise

local sboard_Score_ServerName = "Luctus Surf"
local sboard_Score_WebsiteLink = "https://luctus.at/"

--------------------------
-- End of configuration --
--------------------------

surface.CreateFont("sboardScoreFontBig", { font = "Montserrat", size = 35, weight = 800, antialias = true, bold = true })
surface.CreateFont("sboardScoreFontSmall", { font = "Montserrat", size = 20, weight = 700, antialias = true, bold = true })


function lucidDrawRect(x, y, w, h, col)
    surface.SetDrawColor(col)
    surface.DrawRect(x, y, w, h)
end



function LEnableClicker(ply,key)
    if not ply == LocalPlayer() then return end
    if key ~= IN_USE then return end
    gui.EnableScreenClicker(true)
end

local sboard = nil
function GM:ScoreboardShow()
    if IsValid(sboard) then return end
    hook.Add("KeyPress", "luctus_surf_scoreboardclick", LEnableClicker)
    sboard = vgui.Create("DFrame")
    sboard:SetSize(800, 600)
    sboard:SetTitle("")
    sboard:SetDraggable(false)
    sboard:SetVisible(true)
    sboard:ShowCloseButton(false)
    sboard:Center()
    sboard.Paint = function( me, w, h )
        lucidDrawRect(0, 0, w, h, Color(8, 8, 8, 253))
        lucidDrawRect(0, 0, w, h / 2, Color(14, 14, 14, 100))
        lucidDrawRect(10, 73, w - 20, 30, Color(34, 34, 34, 150))
        draw.DrawText("Name", "sboardScoreFontSmall", 51, 77, COLOR_WHITE)
        draw.DrawText("Playtime", "sboardScoreFontSmall", 250, 77, COLOR_WHITE, TEXT_ALIGN_LEFT)
        --draw.DrawText("Level", "sboardScoreFontSmall", 370, 77, COLOR_WHITE)
        draw.DrawText("Time", "sboardScoreFontSmall", 450, 77, COLOR_WHITE)
        draw.DrawText("Record", "sboardScoreFontSmall", 570, 77, COLOR_WHITE)
        draw.DrawText("Ping", "sboardScoreFontSmall", 700, 77, COLOR_WHITE)
        draw.DrawText(sboard_Score_ServerName, "sboardScoreFontBig", w / 2, 5, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER)
        draw.DrawText("There are currently " .. #player.GetAll() .. " player(s) online.", "sboardScoreFontSmall", w / 2, h - 19, Color(3,169,244,255), TEXT_ALIGN_CENTER)
    end

    local website = vgui.Create( 'DLabel', sboard )
    surface.SetFont("sboardScoreFontSmall")
    local offsetX, offsetY = surface.GetTextSize(sboard_Score_WebsiteLink)
    website:SetPos(sboard:GetWide() / 2 - (offsetX/2), 45)
    website:SetSize(offsetX, offsetY)
    website:SetFont("sboardScoreFontSmall")
    website:SetTextColor(Color(3,169,244,255))
    website:SetText(sboard_Score_WebsiteLink)
    website:SetCursor("hand")
    website:SetMouseInputEnabled( true )
    website.OnMousePressed = function()
        gui.OpenURL(sboard_Score_WebsiteLink)
    end

    sboard.PlayerList = vgui.Create("DPanelList", sboard)
    sboard.PlayerList:SetSize(sboard:GetWide() - 20, sboard:GetTall() - 130)
    sboard.PlayerList:SetPos(10, 110)
    sboard.PlayerList:SetSpacing(2)
    sboard.PlayerList:EnableVerticalScrollbar(true)

    sboard.PlayerList.Paint = function(self, w, h)
        lucidDrawRect(0, 0, w, h, Color(26, 26, 26, 200))
    end

    local sbar = sboard.PlayerList.VBar
    function sbar:Paint(w, h)
        lucidDrawRect(0, 0, w, h, Color(0, 0, 0, 100))
    end
    function sbar.btnUp:Paint(w, h)
        lucidDrawRect(0, 0, w, h, Color(44, 44, 44))
    end
    function sbar.btnDown:Paint(w, h)
        lucidDrawRect(0, 0, w, h, Color(44, 44, 44))
    end
    function sbar.btnGrip:Paint(w, h)
        lucidDrawRect(0, 0, w, h, Color(56, 56, 56))
    end

    for k, v in pairs( player.GetAll() ) do
        local item = vgui.Create("DLabel", sboard.PlayerList)
        item:SetSize(sboard.PlayerList:GetWide() - 70, 30)

        item.Paint = function( me, w, h )
            if not IsValid(v) then item:Remove() return end
            if k % 2 == 0 then
                lucidDrawRect( 0, 0, w, h, Color( 44, 44, 44, 200 ) )
            else
                lucidDrawRect( 0, 0, w, h, Color( 32, 32, 32, 200 ) )
            end
            local ugrp = v:GetUserGroup()
            draw.DrawText(v:Nick(), "sboardScoreFontSmall", 40, 4, COLOR_WHITE)
            draw.DrawText(string.NiceTime(v:GetNWInt("playtime",0)), "sboardScoreFontSmall", 240, 4, COLOR_WHITE,TEXT_ALIGN_LEFT)
            --draw.DrawText(v:GetNWInt("level",1), "sboardScoreFontSmall", 370, 3, COLOR_WHITE)
            local ctime = PrettifyTime(v:GetNWFloat("starttime",0) ~= 0 and CurTime() - v:GetNWFloat("starttime",0) or 0)
            if v:GetNWBool("spectating",false) then
                ctime = "SPECTATING"
            end
            draw.DrawText(ctime, "sboardScoreFontSmall", 440, 4, COLOR_WHITE)
            draw.DrawText(PrettifyTime(v:GetNWFloat("record",0)), "sboardScoreFontSmall", 560, 4, COLOR_WHITE)
            draw.DrawText(v:Ping(), "sboardScoreFontSmall", 690, 4, COLOR_WHITE)
        end

        local image = vgui.Create("AvatarImage", item)
        image:SetSize(28, 28)
        image:SetPos(1, 1)
        image:SetPlayer(v, 32)

        local mute = vgui.Create("DImageButton", item)
        mute:SetSize(16, 16)
        mute:SetPos(item:GetWide() + 35, 7)
        mute:SetImage(v:IsMuted() and "icon16/sound_mute.png" or "icon16/sound.png")

        mute.DoClick = function()
            if not v:IsMuted() then v:SetMuted( true ) else v:SetMuted( false ) end
            mute:SetImage(v:IsMuted() and "icon16/sound_mute.png" or "icon16/sound.png")
        end

        sboard.PlayerList:AddItem(item)
    end
end

function GM:ScoreboardHide()
    if IsValid(sboard) then
        hook.Remove("KeyPress", "luctus_surf_scoreboardclick")
        gui.EnableScreenClicker(false)
        sboard:Close()
    end
end
function GM:HUDDrawScoreBoard() end
