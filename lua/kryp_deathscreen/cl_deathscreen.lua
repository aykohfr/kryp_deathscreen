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

    surface.CreateFont("KrypDeathScreen.Title", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.030), 28, 42),
        weight = 900,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Subtitle", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.016), 16, 24),
        weight = 600,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Ready", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.017), 17, 25),
        weight = 800,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Credit", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.0105), 11, 15),
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

local function drawSubtleContainmentMark(cx, cy, radius, alpha)
    local accent = Config.AccentColor or Color(172, 42, 42)
    local muted = Config.MutedTextColor or Color(151, 155, 161)

    surface.DrawCircle(cx, cy, radius, withAlpha(muted, alpha * 0.30))
    surface.DrawCircle(cx, cy, radius - 4, withAlpha(accent, alpha * 0.72))
    surface.DrawCircle(cx, cy, radius * 0.30, withAlpha(muted, alpha * 0.28))

    surface.SetDrawColor(withAlpha(accent, alpha * 0.72))

    for i = 0, 2 do
        local angle = math.rad(-90 + (i * 120))
        local inner = radius * 0.38
        local outer = radius * 0.76

        surface.DrawLine(
            cx + math.cos(angle) * inner,
            cy + math.sin(angle) * inner,
            cx + math.cos(angle) * outer,
            cy + math.sin(angle) * outer
        )
    end
end

local function getPanelRect(scaleAnimation)
    local baseW = math.Clamp(
        ScrW() * (Config.PanelScreenWidth or 0.34),
        Config.PanelMinWidth or 420,
        Config.PanelMaxWidth or 600
    )

    local referenceW = Config.PanelWidth or 540
    local baseH = (Config.PanelHeight or 220) * (baseW / referenceW)

    local w = baseW * scaleAnimation
    local h = baseH * scaleAnimation

    return (ScrW() - w) * 0.5, (ScrH() - h) * 0.5, w, h
end

local function drawDeathPanel(alpha, scaleAnimation, remaining)
    local x, y, w, h = getPanelRect(scaleAnimation)

    local accent = Config.AccentColor or Color(172, 42, 42)
    local accentSoft = Config.AccentSoftColor or Color(94, 28, 28)
    local panel = Config.PanelColor or Color(10, 11, 13, 244)
    local panelInner = Config.PanelInnerColor or Color(18, 19, 22, 238)
    local text = Config.TextColor or Color(240, 241, 243)
    local muted = Config.MutedTextColor or Color(151, 155, 161)

    local shadowOffset = math.max(5, math.floor(w * 0.010))
    draw.RoundedBox(10, x + shadowOffset, y + shadowOffset, w, h, Color(0, 0, 0, 165 * alpha))
    draw.RoundedBox(10, x, y, w, h, withAlpha(panel, alpha))

    surface.SetDrawColor(withAlpha(accentSoft, alpha))
    surface.DrawOutlinedRect(x, y, w, h, 1)

    -- Accent SCP discret, sans texte thématique supplémentaire.
    surface.SetDrawColor(withAlpha(accent, alpha))
    surface.DrawRect(x, y, 4, h)
    surface.DrawRect(x, y, w, 2)

    local markX = x + (w * 0.105)
    local markY = y + (h * 0.34)
    drawSubtleContainmentMark(markX, markY, math.Clamp(w * 0.040, 18, 25), alpha)

    draw.SimpleText(
        Config.DeathTitle or "Vous êtes mort..",
        "KrypDeathScreen.Title",
        x + (w * 0.17),
        y + (h * 0.31),
        withAlpha(text, alpha),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    local dividerY = y + (h * 0.52)
    surface.SetDrawColor(withAlpha(Color(255, 255, 255, 26), alpha))
    surface.DrawRect(x + (w * 0.05), dividerY, w * 0.90, 1)

    if remaining > 0 then
        draw.SimpleText(
            (Config.DeathSubtitlePrefix or "Vous allez réapparaitre dans ") .. tostring(remaining) .. (Config.DeathSubtitleSuffix or " secondes.."),
            "KrypDeathScreen.Subtitle",
            x + (w * 0.5),
            y + (h * 0.67),
            withAlpha(text, alpha),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    else
        local pulse = 0.82 + (math.sin(RealTime() * 5) * 0.12)
        draw.SimpleText(
            Config.ReadyMessage or "APPUYEZ SUR UNE TOUCHE",
            "KrypDeathScreen.Ready",
            x + (w * 0.5),
            y + (h * 0.67),
            withAlpha(accent, alpha * pulse),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end

    draw.SimpleText(
        Config.CreditText or "Réalisateur : Kryp Studio",
        "KrypDeathScreen.Credit",
        x + (w * 0.95),
        y + (h * 0.90),
        withAlpha(muted, alpha * 0.72),
        TEXT_ALIGN_RIGHT,
        TEXT_ALIGN_CENTER
    )
end

hook.Add("HUDPaint", "KrypDeathScreen.Draw", function()
    if not state.visible then return end

    local alpha, scaleAnimation = getAnimation()
    if alpha <= 0 then return end

    -- Fond volontairement très sombre tout en laissant légèrement voir la scène.
    local backgroundAlpha = math.Clamp((Config.BackgroundAlpha or 232) * alpha, 0, 255)
    surface.SetDrawColor(0, 0, 0, backgroundAlpha)
    surface.DrawRect(0, 0, ScrW(), ScrH())

    -- Vignette simple en haut et en bas.
    surface.SetDrawColor(0, 0, 0, 45 * alpha)
    surface.DrawRect(0, 0, ScrW(), ScrH() * 0.18)
    surface.DrawRect(0, ScrH() * 0.82, ScrW(), ScrH() * 0.18)

    local remaining = math.max(0, math.ceil(state.readyAt - CurTime()))
    drawDeathPanel(alpha, scaleAnimation, remaining)
end)

hook.Add("RenderScreenspaceEffects", "KrypDeathScreen.WorldEffect", function()
    if not state.visible or not Config.EnableWorldEffect then return end

    local alpha = select(1, getAnimation()) * (Config.WorldEffectStrength or 0.78)
    if alpha <= 0 then return end

    DrawColorModify({
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = -0.085 * alpha,
        ["$pp_colour_contrast"] = 1 - (0.20 * alpha),
        ["$pp_colour_colour"] = 1 - (0.86 * alpha),
        ["$pp_colour_mulr"] = 0.015 * alpha,
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
