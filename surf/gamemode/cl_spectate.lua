
local cvarShowKeys = CreateClientConVar("ls_showinputs", "0", true, false)
local ViewSpec = CreateClientConVar( "ls_showspec", "1", true, false )

surface.CreateFont( "lsurf_spec_keys", {
	font = "consolas",
	size = 30,
	weight = 500,
	antialias = true,
})

local lp = nil
local colblack = Color(0,0,0)
local colwhite = Color(255,255,255,255)
local coldarkened = Color(255,255,255,80)

local spectators = {}
timer.Create("luctus_surf_spectate_time",1,0,function()
    spectators = {}
    for k,v in pairs(player.GetAll()) do
        if v:GetObserverTarget() == lp then
            table.insert(spectators,v:Nick())
        end
    end
end)

hook.Add("HUDPaint","surf_spectate_hud",function()
    if not lp then lp = LocalPlayer() end
    local scrw = ScrW()
    local scrh = ScrH()
    if cvarShowKeys:GetString() ~= "0" then
        draw.WordBox(8, scrw/2-25, scrh-300, "W", "lsurf_spec_keys", lp:KeyDown(IN_FORWARD) and colwhite or coldarkened, colblack)
        draw.WordBox(8, scrw/2-60, scrh-250, "A", "lsurf_spec_keys", lp:KeyDown(IN_MOVELEFT) and colwhite or coldarkened, colblack)
        draw.WordBox(8, scrw/2-25, scrh-250, "S", "lsurf_spec_keys", lp:KeyDown(IN_BACK) and colwhite or coldarkened, colblack)
        draw.WordBox(8, scrw/2+10, scrh-250, "D", "lsurf_spec_keys", lp:KeyDown(IN_MOVERIGHT) and colwhite or coldarkened, colblack)
        draw.WordBox(8, scrw/2-150, scrh-250, "CTRL", "lsurf_spec_keys", lp:KeyDown(IN_DUCK) and colwhite or coldarkened, colblack)
    end
    if lp:GetNWBool("spectating",false) then
        draw.SimpleTextOutlined("SPECTATING", "DermaLarge",scrw/2, scrh/10, colwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, colblack)
        draw.SimpleTextOutlined("R - switch mode  ||  LMB/RMB - switch target", "DermaLarge",scrw/2, scrh/7, colwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, colblack)
        local spec = lp:GetObserverTarget()
        if IsValid(spec) then
            draw.SimpleTextOutlined(spec:Nick(), "DermaLarge",scrw/2, scrh/5, colwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, colblack)
            draw.WordBox(8, scrw/2-25, scrh-300, "W", "lsurf_spec_keys", spec:GetNWBool("spec_w",false) and colwhite or coldarkened, colblack )
            draw.WordBox(8, scrw/2-60, scrh-250, "A", "lsurf_spec_keys", spec:GetNWBool("spec_a",false) and colwhite or coldarkened, colblack )
            draw.WordBox(8, scrw/2-25, scrh-250, "S", "lsurf_spec_keys", spec:GetNWBool("spec_s",false) and colwhite or coldarkened, colblack )
            draw.WordBox(8, scrw/2+10, scrh-250, "D", "lsurf_spec_keys", spec:GetNWBool("spec_d",false) and colwhite or coldarkened, colblack )
            draw.WordBox(8, scrw/2-150, scrh-250, "STRG", "lsurf_spec_keys", spec:GetNWBool("spec_ctrl",false) and colwhite or coldarkened, colblack )
        else
            draw.SimpleTextOutlined("<Freeroam>", "DermaLarge",scrw/2, scrh/5, colwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, colblack)
        end
    end
    if not ViewSpec:GetBool() then return end
    if #spectators <= 0 then return end
    draw.SimpleTextOutlined("-Spectators-", "Trebuchet18",scrw-10, scrh/2, colwhite, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 0.5, colblack)
    for k,v in pairs(spectators) do
        draw.SimpleTextOutlined(v, "Trebuchet18",scrw-10, scrh/2+k*15, colwhite, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 0.5, colblack)
    end
end)

hook.Add( "HUDDrawTargetID", "surf_disable_targetid_spec", function()
    if LocalPlayer():GetNWBool("spectating",false) then return false end
end)
