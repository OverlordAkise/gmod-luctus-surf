
hook.Add("OnPlayerChat","surf_cl_cmds",function(ply,text,team,dead)
    if not ply == LocalPlayer() then return end
    if text == "!cfg" or text == "!settings" then
        SurfOpenSettings()
    end
end)

surf_clcmds = {
    --"ls_showothers", "1",
    {"Speed beneath crosshair","ls_crossspeed","0"},
    {"Volume of chat sounds","ls_chatvolume","1"},
    {"Mute all custom sounds","ls_mutesounds", "0"},
    {"Show crosshair","ls_crosshair", "1"},
    {"Show playernames","ls_targetids", "0"},
    {"Enable thirdperson","ls_thirdperson", "0"},
    {"Switch thirdperson camera","ls_thirdpersonright", "0"},
    {"Show keypresses in HUD","ls_showinputs", "0"},
    {"Show who's spectating you","ls_showspec", "1"}
}

function SurfOpenSettings()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("luctus surf | settings")
    frame:SetSize(300, 300)
    frame:SetPos(ScrW()/2-150, ScrH()/2-250)
    frame:MakePopup()
    frame:ShowCloseButton(true)
    function frame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0,195,165))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
    --createCloseButton(frame)
    local lliste = vgui.Create("DScrollPanel", frame)
    lliste:Dock(FILL)
    for k,v in pairs(surf_clcmds) do
        local item = lliste:Add("DButton")
        item:Dock(TOP)
        item:DockMargin(10,10,10,0)
        item:SetText(v[1])
        item.v = v
        item.cmd = v[2]
        item.def = v[3]
        item.cur = GetConVar(v[2]):GetString()
        function item:DoClick()
            chat.AddText("Cur:",self.cur)
            notification.AddLegacy("Toggled '"..self.cmd.."' to '"..(item.cur=="0" and "ON" or "OFF").."'", NOTIFY_UNDO, 2 )
            surface.PlaySound( "buttons/button15.wav" )
            if item.cur == "0" then
                self.cur = "1"
                RunConsoleCommand(self.cmd,self.cur)
                
            else
                self.cur = "0"
                RunConsoleCommand(self.cmd,self.cur)
            end
        end
        beautifyButton(item)
    end
    --frame:SizeTo(300, 500, 0.2, 0)
end
function beautifyButton(el)
    el.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(247, 249, 254))
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(0,195,165))
            draw.RoundedBox(0, 1, 1, w-2, h-2, Color(66, 70, 77))
        end
    end
end
