
local cvarShowKeys = CreateClientConVar("ls_showinputs", "0", true, false)

local lp = nil
local colblack = Color(0,0,0)
local colwhite = Color(255,255,255,255)
local coldarkened = Color(255,255,255,80)

hook.Add("HUDPaint","surf_spectate_hud",function()
    if not lp then lp = LocalPlayer() end
    local scrw = ScrW()
    local scrh = ScrH()
    if cvarShowKeys:GetString() ~= "0" then
        draw.WordBox(8, scrw/2-27, scrh-300, "W", "DermaLarge", lp:KeyDown(IN_FORWARD) and colwhite or coldarkened, colblack)
        draw.WordBox(8, scrw/2-60, scrh-250, "A", "DermaLarge", lp:KeyDown(IN_MOVELEFT) and colwhite or coldarkened, colblack)
        draw.WordBox(8, scrw/2-25, scrh-250, "S", "DermaLarge", lp:KeyDown(IN_BACK) and colwhite or coldarkened, colblack)
        draw.WordBox(8, scrw/2+9, scrh-250, "D", "DermaLarge", lp:KeyDown(IN_MOVERIGHT) and colwhite or coldarkened, colblack)
        draw.WordBox(8, scrw/2-150, scrh-250, "CTRL", "DermaLarge", lp:KeyDown(IN_DUCK) and colwhite or coldarkened, colblack)
        draw.WordBox(8, scrw/2+50, scrh-250, "SPACE", "DermaLarge", lp:KeyDown(IN_JUMP) and colwhite or coldarkened, colblack)
    end
    if lp:GetNWBool("spectating",false) then
        draw.SimpleTextOutlined("SPECTATING", "DermaLarge",scrw/2, scrh/5, colwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, colblack)
        draw.SimpleTextOutlined("R - switch mode  ||  LMB/RMB - switch target", "DermaLarge",scrw/2, scrh/10, colwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, colblack)
        local spec = lp:GetObserverTarget()
        if IsValid(spec) then
            draw.SimpleTextOutlined(spec:Nick(), "DermaLarge",scrw/2, scrh/5+50, colwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, colblack)
            draw.WordBox(8, scrw/2-27, scrh-300, "W", "DermaLarge", spec:GetNWBool("spec_w",false) and colwhite or coldarkened, colblack )
            draw.WordBox(8, scrw/2-60, scrh-250, "A", "DermaLarge", spec:GetNWBool("spec_a",false) and colwhite or coldarkened, colblack )
            draw.WordBox(8, scrw/2-25, scrh-250, "S", "DermaLarge", spec:GetNWBool("spec_s",false) and colwhite or coldarkened, colblack )
            draw.WordBox(8, scrw/2+9, scrh-250, "D", "DermaLarge", spec:GetNWBool("spec_d",false) and colwhite or coldarkened, colblack )
            draw.WordBox(8, scrw/2-150, scrh-250, "STRG", "DermaLarge", spec:GetNWBool("spec_ctrl",false) and colwhite or coldarkened, colblack )
        end
    end
    local c = 0
    for k,v in pairs(player.GetAll()) do
        if v:GetObserverTarget() == lp then
            c = c + 1
            draw.SimpleTextOutlined(v:Nick(), "Trebuchet18",scrw-10, scrh/2+c*15, colwhite, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 0.5, colblack)
        end
    end
    if c ~= 0 then
        draw.SimpleTextOutlined("-Spectators-", "Trebuchet18",scrw-10, scrh/2, colwhite, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 0.5, colblack)
    end
end)

hook.Add( "HUDDrawTargetID", "surf_disable_targetid_spec", function()
    if LocalPlayer():GetNWBool("spectating",false) then return false end
end)
