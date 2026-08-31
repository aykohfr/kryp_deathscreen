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
        size = math.Clamp(math.floor(h * 0.031), 28, 44),
        weight = 900,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Subtitle", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.016), 16, 24),
        weight = 700,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Countdown", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.0195), 18, 30),
        weight = 900,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Ready", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.0165), 17, 25),
        weight = 900,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Credit", {
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
    return Color(
        color.r,
        color.g,
        color.b,
        math.Clamp((color.a or 255) * alpha, 0, 255)
    )
end

local function measureText(font, text)
    surface.SetFont(font)
    return surface.GetTextSize(text)
end

local function drawGlowBox(x, y, w, h, radius, color, alpha, passes, spread)
    passes = passes or 6
    spread = spread or 3

    for i = passes, 1, -1 do
        local grow = i * spread
        local strength = (alpha / 255) / (i * 1.45)

        draw.RoundedBox(
            radius + grow,
            x - grow,
            y - grow,
            w + (grow * 2),
            h + (grow * 2),
            withAlpha(color, strength)
        )
    end
end

local function drawContainmentMark(cx, cy, radius, alpha)
    local accent = Config.AccentColor or Color(188, 48, 48)
    local muted = Config.MutedTextColor or Color(155, 160, 168)

    surface.DrawCircle(cx, cy, radius, withAlpha(muted, alpha * 0.35))
    surface.DrawCircle(cx, cy, radius - 4, withAlpha(accent, alpha * 0.90))
    surface.DrawCircle(cx, cy, radius * 0.30, withAlpha(muted, alpha * 0.32))

    surface.SetDrawColor(withAlpha(accent, alpha * 0.85))

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
        ScrW() * (Config.PanelScreenWidth or 0.40),
        Config.PanelMinWidth or 460,
        Config.PanelMaxWidth or 700
    )

    local referenceW = Config.PanelWidth or 620
    local baseH = (Config.PanelHeight or 245) * (baseW / referenceW)

    local w = baseW * scaleAnimation
    local h = baseH * scaleAnimation

    return (ScrW() - w) * 0.5, (ScrH() - h) * 0.5, w, h
end

local function drawSubtitleSentence(panelX, panelY, panelW, panelH, alpha, remaining)
    local prefix = Config.DeathSubtitlePrefix or "Vous allez réapparaitre dans"
    local suffix = Config.DeathSubtitleSuffix or "secondes.."
    local countText = tostring(remaining)

    local prefixW = measureText("KrypDeathScreen.Subtitle", prefix)
    local suffixW = measureText("KrypDeathScreen.Subtitle", suffix)
    local countW, countH = measureText("KrypDeathScreen.Countdown", countText)

    local gap = math.max(9, math.floor(panelH * 0.025))
    local pillPadX = math.max(11, math.floor(panelW * 0.016))
    local pillH = math.max(32, math.floor(panelH * 0.145))
    local pillW = countW + (pillPadX * 2)

    local totalW = prefixW + gap + pillW + gap + suffixW
    local startX = panelX + (panelW * 0.5) - (totalW * 0.5)
    local centerY = panelY + (panelH * 0.67)

    draw.SimpleText(
        prefix,
        "KrypDeathScreen.Subtitle",
        startX,
        centerY,
        withAlpha(Config.TextColor or Color(242, 243, 245), alpha),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    local pillX = startX + prefixW + gap
    local pillY = centerY - (pillH * 0.5)
    local pillRadius = math.max(8, math.floor((Config.PanelRadius or 14) * 0.75))

    drawGlowBox(
        pillX,
        pillY,
        pillW,
        pillH,
        pillRadius,
        Config.AccentGlowColor or Color(215, 64, 64),
        42 * alpha,
        5,
        2
    )

    draw.RoundedBox(
        pillRadius,
        pillX,
        pillY,
        pillW,
        pillH,
        withAlpha(Color(46, 20, 22, 230), alpha)
    )

    draw.RoundedBox(
        pillRadius,
        pillX + 1,
        pillY + 1,
        pillW - 2,
        2,
        withAlpha(Config.AccentColor or Color(188, 48, 48), alpha * 0.70)
    )

    draw.SimpleText(
        countText,
        "KrypDeathScreen.Countdown",
        pillX + (pillW * 0.5),
        centerY,
        withAlpha(Config.TextColor or Color(242, 243, 245), alpha),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    draw.SimpleText(
        suffix,
        "KrypDeathScreen.Subtitle",
        pillX + pillW + gap,
        centerY,
        withAlpha(Config.TextColor or Color(242, 243, 245), alpha),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )
end

local function drawReadyMessage(panelX, panelY, panelW, panelH, alpha)
    local pulse = 0.84 + (math.sin(RealTime() * 5.2) * 0.10)
    local message = Config.ReadyMessage or "APPUYEZ SUR UNE TOUCHE"
    local textW, textH = measureText("KrypDeathScreen.Ready", message)

    local boxW = textW + 42
    local boxH = textH + 18
    local x = panelX + (panelW * 0.5) - (boxW * 0.5)
    local y = panelY + (panelH * 0.60)
    local radius = math.max(9, math.floor((Config.PanelRadius or 14) * 0.80))

    drawGlowBox(
        x,
        y,
        boxW,
        boxH,
        radius,
        Config.AccentGlowColor or Color(215, 64, 64),
        58 * alpha * pulse,
        6,
        2
    )

    draw.RoundedBox(
        radius,
        x,
        y,
        boxW,
        boxH,
        withAlpha(Color(48, 19, 21, 235), alpha)
    )

    draw.RoundedBox(
        radius,
        x + 1,
        y + 1,
        boxW - 2,
        2,
        withAlpha(Config.AccentColor or Color(188, 48, 48), alpha * pulse)
    )

    draw.SimpleText(
        message,
        "KrypDeathScreen.Ready",
        x + (boxW * 0.5),
        y + (boxH * 0.5),
        withAlpha(Config.TextColor or Color(242, 243, 245), alpha),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )
end

local function drawDeathPanel(alpha, scaleAnimation, remaining)
    local x, y, w, h = getPanelRect(scaleAnimation)
    local radius = Config.PanelRadius or 14

    local accent = Config.AccentColor or Color(188, 48, 48)
    local accentSoft = Config.AccentSoftColor or Color(102, 27, 27)
    local accentGlow = Config.AccentGlowColor or Color(215, 64, 64)
    local panel = Config.PanelColor or Color(10, 11, 13, 245)
    local panelInner = Config.PanelInnerColor or Color(17, 19, 22, 240)
    local panelInnerSoft = Config.PanelInnerSoftColor or Color(24, 26, 30, 220)
    local text = Config.TextColor or Color(242, 243, 245)
    local muted = Config.MutedTextColor or Color(155, 160, 168)

    local shadowOffset = math.max(8, math.floor(w * 0.014))

    draw.RoundedBox(
        radius,
        x + shadowOffset,
        y + shadowOffset,
        w,
        h,
        Color(0, 0, 0, 150 * alpha)
    )

    drawGlowBox(x, y, w, h, radius, accentGlow, 32 * alpha, 8, 3)

    draw.RoundedBox(radius, x, y, w, h, withAlpha(panel, alpha))
    draw.RoundedBox(radius - 2, x + 2, y + 2, w - 4, h - 4, withAlpha(panelInner, alpha))

    draw.RoundedBoxEx(
        radius - 2,
        x + 2,
        y + 2,
        w - 4,
        h * 0.23,
        withAlpha(panelInnerSoft, alpha),
        true,
        true,
        false,
        false
    )

    -- Accent rouge discret et arrondi.
    draw.RoundedBoxEx(radius, x, y, 5, h, withAlpha(accent, alpha), true, false, true, false)

    surface.SetDrawColor(withAlpha(accentSoft, alpha * 0.95))
    surface.DrawRect(x + (w * 0.055), y + (h * 0.49), w * 0.89, 1)

    local emblemX = x + (w * 0.12)
    local emblemY = y + (h * 0.30)
    local emblemRadius = math.Clamp(w * 0.040, 19, 27)

    drawGlowBox(
        emblemX - emblemRadius,
        emblemY - emblemRadius,
        emblemRadius * 2,
        emblemRadius * 2,
        emblemRadius,
        accentGlow,
        18 * alpha,
        4,
        2
    )

    drawContainmentMark(emblemX, emblemY, emblemRadius, alpha)

    draw.SimpleText(
        Config.DeathTitle or "Vous êtes mort..",
        "KrypDeathScreen.Title",
        x + (w * 0.18),
        y + (h * 0.30),
        withAlpha(text, alpha),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    if remaining > 0 then
        drawSubtitleSentence(x, y, w, h, alpha, remaining)
    else
        drawReadyMessage(x, y, w, h, alpha)
    end

    draw.SimpleText(
        Config.CreditText or "Réalisateur : Kryp Studio",
        "KrypDeathScreen.Credit",
        x + w - 18,
        y + h - 15,
        withAlpha(muted, alpha * 0.80),
        TEXT_ALIGN_RIGHT,
        TEXT_ALIGN_BOTTOM
    )
end

hook.Add("HUDPaint", "KrypDeathScreen.Draw", function()
    if not state.visible then return end

    local alpha, scaleAnimation = getAnimation()
    if alpha <= 0 then return end

    local backgroundAlpha = math.Clamp((Config.BackgroundAlpha or 238) * alpha, 0, 255)
    surface.SetDrawColor(0, 0, 0, backgroundAlpha)
    surface.DrawRect(0, 0, ScrW(), ScrH())

    -- Vignette renforcée sans rendre l'arrière-plan totalement noir.
    surface.SetDrawColor(0, 0, 0, 74 * alpha)
    surface.DrawRect(0, 0, ScrW(), ScrH() * 0.15)
    surface.DrawRect(0, ScrH() * 0.85, ScrW(), ScrH() * 0.15)
    surface.DrawRect(0, 0, ScrW() * 0.10, ScrH())
    surface.DrawRect(ScrW() * 0.90, 0, ScrW() * 0.10, ScrH())

    local remaining = math.max(0, math.ceil(state.readyAt - CurTime()))
    drawDeathPanel(alpha, scaleAnimation, remaining)
end)

hook.Add("RenderScreenspaceEffects", "KrypDeathScreen.WorldEffect", function()
    if not state.visible or not Config.EnableWorldEffect then return end

    local alpha = select(1, getAnimation()) * (Config.WorldEffectStrength or 0.82)
    if alpha <= 0 then return end

    DrawColorModify({
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = -0.085 * alpha,
        ["$pp_colour_contrast"] = 1 - (0.21 * alpha),
        ["$pp_colour_colour"] = 1 - (0.86 * alpha),
        ["$pp_colour_mulr"] = 0.018 * alpha,
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
