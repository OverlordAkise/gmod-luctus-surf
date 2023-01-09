
hook.Add("OnPlayerChat","surf_leaderboard",function(ply,text,team,dead)
    if ply ~= LocalPlayer() then return end
    if text == "!leaderboard" or text == "!lb" then
        SurfOpenLeaderboard()
    end
end)

lb_frame = nil
lb_list = nil

function SurfOpenLeaderboard()
    local lb_frame = vgui.Create("DFrame")
    lb_frame:SetPos(5, 5)
    lb_frame:SetSize(500, 600)
    lb_frame:Center()
    lb_frame:SetTitle("Luctus Surf | Leaderboard")
    lb_frame:SetVisible(true)
    lb_frame:SetDraggable(true)
    lb_frame:ShowCloseButton(false)
    lb_frame:MakePopup()
    function lb_frame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
    --Close Button Top Right
    local CloseButton = vgui.Create("DButton", lb_frame)
    CloseButton:SetText("X")
    CloseButton:SetPos(500-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        lb_frame:Close()
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
		
    DetailPanel = vgui.Create("DLabel", lb_frame)
    DetailPanel:Dock(TOP)
    DetailPanel:SetText("")
    
    lb_list = vgui.Create("DListView", lb_frame)
    lb_list:Dock(FILL)
    lb_list:AddColumn("SteamID")
    lb_list:AddColumn("Player")
    lb_list:AddColumn("Time")
    lb_list:AddColumn("Date")
    --lb_list:AddColumn("PTime"):SetFixedWidth(125)
    net.Start("surf_leaderboard")
        net.WriteString(game.GetMap())
    net.SendToServer()
end

net.Receive("surf_leaderboard",function()
    lb_list:Clear()
    DetailPanel:SetText(net.ReadString())--mapname
    local timeTab = net.ReadTable()
    for k,v in ipairs(timeTab) do
        v.time = tonumber(v.time)
    end
    table.SortByMember(timeTab, "time",true)
    PrintTable(timeTab)
    for k,v in ipairs(timeTab) do
        lb_list:AddLine(v["sid"],v["nick"],string.ToMinutesSecondsMilliseconds(v["time"]),v["date"])
    end
end)
