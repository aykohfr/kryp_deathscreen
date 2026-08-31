if not CLIENT then return end

local KDS = KrypDeathScreen
local Config = KDS.Config
local Net = KDS.Net

local state = {
    visible = false,
    leaving = false,
    requested = false,
    readyAt = 0,
    startedAt = 0,
    leaveAt = 0,
    sequence = 0
}

local function createFonts()
    local h = ScrH()

    surface.CreateFont("KrypDeathScreen.Header", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.0115), 12, 18),
        weight = 700,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Title", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.030), 28, 42),
        weight = 900,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Label", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.014), 15, 22),
        weight = 600,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Countdown", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.022), 22, 34),
        weight = 900,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Ready", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.015), 16, 24),
        weight = 800,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Footer", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.0105), 11, 16),
        weight = 500,
        antialias = true,
        extended = true
    })
end

createFonts()
hook.Add("OnScreenSizeChanged", "KrypDeathScreen.Fonts", createFonts)

local function clamp01(value)
    return math.Clamp(value, 0, 1)
end

local function easeOutCubic(value)
    value = clamp01(value)
    return 1 - ((1 - value) ^ 3)
end

local function getAnimation()
    if state.leaving then
        local duration = math.max(Config.FadeOutDuration or 0.32, 0.01)
        local progress = easeOutCubic((RealTime() - state.leaveAt) / duration)
        return 1 - progress, Lerp(progress, 1, Config.EndScale or 1.025)
    end

    local duration = math.max(Config.FadeInDuration or 0.42, 0.01)
    local progress = easeOutCubic((RealTime() - state.startedAt) / duration)
    return progress, Lerp(progress, Config.StartScale or 0.96, 1)
end

local function withAlpha(color, alpha)
    return Color(color.r, color.g, color.b, math.Clamp((color.a or 255) * alpha, 0, 255))
end

local function drawContainmentMark(cx, cy, radius, alpha)
    local accent = Config.AccentColor or Color(177, 45, 45)
    local muted = Config.MutedTextColor or Color(145, 151, 158)

    surface.DrawCircle(cx, cy, radius, withAlpha(muted, alpha * 0.70))
    surface.DrawCircle(cx, cy, radius - 5, withAlpha(accent, alpha * 0.95))
    surface.DrawCircle(cx, cy, radius * 0.34, withAlpha(muted, alpha * 0.68))

    surface.SetDrawColor(withAlpha(accent, alpha))

    for i = 0, 2 do
        local angle = math.rad(-90 + (i * 120))
        local inner = radius * 0.40
        local outer = radius * 0.82
        local x1 = cx + math.cos(angle) * inner
        local y1 = cy + math.sin(angle) * inner
        local x2 = cx + math.cos(angle) * outer
        local y2 = cy + math.sin(angle) * outer

        surface.DrawLine(x1, y1, x2, y2)

        local tipX = cx + math.cos(angle) * (radius * 0.94)
        local tipY = cy + math.sin(angle) * (radius * 0.94)
        local side = radius * 0.17
        local back = radius * 0.14
        local perpendicular = angle + (math.pi * 0.5)
        local baseX = tipX - math.cos(angle) * back
        local baseY = tipY - math.sin(angle) * back

        draw.NoTexture()
        surface.DrawPoly({
            {x = tipX, y = tipY},
            {x = baseX + math.cos(perpendicular) * side, y = baseY + math.sin(perpendicular) * side},
            {x = baseX - math.cos(perpendicular) * side, y = baseY - math.sin(perpendicular) * side}
        })
    end

    draw.SimpleText("SCP", "KrypDeathScreen.Header", cx, cy, withAlpha(Config.TextColor or color_white, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function getPanelRect(scaleAnimation)
    local baseW = math.Clamp(
        ScrW() * (Config.PanelScreenWidth or 0.36),
        Config.PanelMinWidth or 430,
        Config.PanelMaxWidth or 620
    )

    local referenceW = Config.PanelWidth or 560
    local baseH = (Config.PanelHeight or 250) * (baseW / referenceW)

    local w = baseW * scaleAnimation
    local h = baseH * scaleAnimation

    return (ScrW() - w) * 0.5, (ScrH() - h) * 0.5, w, h
end

local function drawDeathPanel(alpha, scaleAnimation, remaining)
    local x, y, w, h = getPanelRect(scaleAnimation)
    local accent = Config.AccentColor or Color(177, 45, 45)
    local accentSoft = Config.AccentSoftColor or Color(120, 34, 34)
    local panel = Config.PanelColor or Color(13, 15, 17, 242)
    local panelInner = Config.PanelInnerColor or Color(20, 22, 24, 238)
    local text = Config.TextColor or Color(236, 238, 240)
    local muted = Config.MutedTextColor or Color(145, 151, 158)

    local shadowOffset = math.max(5, math.floor(w * 0.012))
    draw.RoundedBox(8, x + shadowOffset, y + shadowOffset, w, h, Color(0, 0, 0, 150 * alpha))
    draw.RoundedBox(8, x, y, w, h, withAlpha(panel, alpha))

    surface.SetDrawColor(withAlpha(accentSoft, alpha))
    surface.DrawOutlinedRect(x, y, w, h, 1)

    local topBarH = h * 0.16
    draw.RoundedBoxEx(8, x, y, w, topBarH, withAlpha(panelInner, alpha), true, true, false, false)

    surface.SetDrawColor(withAlpha(accent, alpha))
    surface.DrawRect(x, y + topBarH - 2, w, 2)
    surface.DrawRect(x, y, 4, h)

    draw.SimpleText(
        Config.HeaderText or "SCP FOUNDATION // MEDICAL PROTOCOL",
        "KrypDeathScreen.Header",
        x + (w * 0.04),
        y + (topBarH * 0.5),
        withAlpha(muted, alpha),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    local contentTop = y + topBarH
    local emblemX = x + (w * 0.12)
    local emblemY = contentTop + (h * 0.25)
    local emblemRadius = math.Clamp(w * 0.050, 22, 32)
    drawContainmentMark(emblemX, emblemY, emblemRadius, alpha)

    local titleX = x + (w * 0.205)
    draw.SimpleText(
        Config.DeathTitle or "PERSONNEL DÉCÉDÉ",
        "KrypDeathScreen.Title",
        titleX,
        contentTop + (h * 0.20),
        withAlpha(text, alpha),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    draw.SimpleText(
        "STATUT : TERMINÉ",
        "KrypDeathScreen.Footer",
        titleX,
        contentTop + (h * 0.33),
        withAlpha(accent, alpha),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    local dividerY = y + (h * 0.62)
    surface.SetDrawColor(withAlpha(Color(255, 255, 255, 28), alpha))
    surface.DrawRect(x + (w * 0.04), dividerY, w * 0.92, 1)

    if remaining > 0 then
        local labelY = y + (h * 0.72)
        draw.SimpleText(
            Config.DeathSubtitle or "RÉANIMATION AUTORISÉE DANS",
            "KrypDeathScreen.Label",
            x + (w * 0.05),
            labelY,
            withAlpha(muted, alpha),
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )

        draw.SimpleText(
            tostring(remaining) .. " SECONDES",
            "KrypDeathScreen.Countdown",
            x + (w * 0.95),
            labelY,
            withAlpha(text, alpha),
            TEXT_ALIGN_RIGHT,
            TEXT_ALIGN_CENTER
        )
    else
        local pulse = 0.78 + (math.sin(RealTime() * 5) * 0.12)
        draw.SimpleText(
            Config.ReadyMessage or "AUTORISATION ACCORDÉE — APPUYEZ SUR UNE TOUCHE",
            "KrypDeathScreen.Ready",
            x + (w * 0.5),
            y + (h * 0.73),
            withAlpha(accent, alpha * pulse),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end

    draw.SimpleText(
        Config.FooterText or "SECURE • CONTAIN • PROTECT",
        "KrypDeathScreen.Footer",
        x + (w * 0.5),
        y + (h * 0.91),
        withAlpha(muted, alpha * 0.70),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )
end

hook.Add("HUDPaint", "KrypDeathScreen.Draw", function()
    if not state.visible then return end

    local alpha, scaleAnimation = getAnimation()
    if alpha <= 0 then return end

    local backgroundAlpha = math.Clamp((Config.BackgroundAlpha or 218) * alpha, 0, 255)
    surface.SetDrawColor(0, 0, 0, backgroundAlpha)
    surface.DrawRect(0, 0, ScrW(), ScrH())

    -- Assombrit davantage les bords sans masquer totalement la scène.
    local edgeAlpha = 55 * alpha
    surface.SetDrawColor(0, 0, 0, edgeAlpha)
    surface.DrawRect(0, 0, ScrW(), ScrH() * 0.16)
    surface.DrawRect(0, ScrH() * 0.84, ScrW(), ScrH() * 0.16)

    local remaining = math.max(0, math.ceil(state.readyAt - CurTime()))
    drawDeathPanel(alpha, scaleAnimation, remaining)
end)

hook.Add("RenderScreenspaceEffects", "KrypDeathScreen.WorldEffect", function()
    if not state.visible or not Config.EnableWorldEffect then return end

    local alpha = select(1, getAnimation()) * (Config.WorldEffectStrength or 0.72)
    if alpha <= 0 then return end

    DrawColorModify({
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = -0.075 * alpha,
        ["$pp_colour_contrast"] = 1 - (0.18 * alpha),
        ["$pp_colour_colour"] = 1 - (0.82 * alpha),
        ["$pp_colour_mulr"] = 0.02 * alpha,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    })
end)

local function requestRespawn()
    if not state.visible or state.leaving or state.requested then return end
    if CurTime() < state.readyAt then return end

    state.requested = true

    net.Start(Net.Respawn)
    net.SendToServer()
end

hook.Add("PlayerButtonDown", "KrypDeathScreen.AnyButton", function(ply)
    if ply ~= LocalPlayer() then return end
    if not IsFirstTimePredicted() then return end
    requestRespawn()
end)

hook.Add("CreateMove", "KrypDeathScreen.AnyKeyboardKey", function()
    if not state.visible or state.leaving or state.requested then return end
    if CurTime() < state.readyAt then return end

    for key = KEY_FIRST + 1, KEY_LAST do
        if input.WasKeyPressed(key) then
            requestRespawn()
            return
        end
    end
end)

net.Receive(Net.Start, function()
    local delay = math.max(0, net.ReadFloat())

    state.sequence = state.sequence + 1
    state.visible = true
    state.leaving = false
    state.requested = false
    state.readyAt = CurTime() + delay
    state.startedAt = RealTime()
    state.leaveAt = 0
end)

net.Receive(Net.Stop, function()
    if not state.visible then return end

    state.sequence = state.sequence + 1
    local sequence = state.sequence

    state.leaving = true
    state.leaveAt = RealTime()

    timer.Simple((Config.FadeOutDuration or 0.32) + 0.05, function()
        if state.sequence ~= sequence then return end

        state.visible = false
        state.leaving = false
        state.requested = false
    end)
end)
