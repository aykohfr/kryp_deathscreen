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

    surface.CreateFont("KrypDeathScreen.Small", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.0135), 14, 22),
        weight = 500,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Title", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.050), 42, 76),
        weight = 1000,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Subtitle", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.020), 20, 32),
        weight = 600,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Countdown", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.020), 20, 32),
        weight = 900,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Ready", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.021), 21, 34),
        weight = 900,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Credit", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.011), 11, 16),
        weight = 400,
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
        return 1 - progress, Lerp(progress, 1, Config.EndScale or 1.02)
    end

    local duration = math.max(Config.FadeInDuration or 0.42, 0.01)
    local progress = easeOutCubic((RealTime() - state.startedAt) / duration)
    return progress, Lerp(progress, Config.StartScale or 0.97, 1)
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

local function drawGlowText(text, font, x, y, color, alpha, xalign, yalign)
    local glow = withAlpha(Config.GlowColor or Color(255, 255, 255), alpha * 0.16)

    draw.SimpleText(text, font, x + 1, y, glow, xalign, yalign)
    draw.SimpleText(text, font, x - 1, y, glow, xalign, yalign)
    draw.SimpleText(text, font, x, y + 1, glow, xalign, yalign)
    draw.SimpleText(text, font, x, y - 1, glow, xalign, yalign)
    draw.SimpleText(text, font, x, y, withAlpha(color, alpha), xalign, yalign)
end

local function drawSoftBox(x, y, w, h, radius, alpha)
    for i = 8, 1, -1 do
        local grow = i * 4
        draw.RoundedBox(
            radius + grow,
            x - grow,
            y - grow,
            w + (grow * 2),
            h + (grow * 2),
            Color(0, 0, 0, (7 * alpha) / i)
        )
    end

    draw.RoundedBox(radius, x, y, w, h, withAlpha(Config.PanelColor or Color(8, 8, 10, 185), alpha))
    draw.RoundedBox(radius - 2, x + 2, y + 2, w - 4, h - 4, withAlpha(Config.PanelSoftColor or Color(16, 16, 20, 160), alpha * 0.85))
end

local function getPanelRect(scaleAnimation)
    local baseW = math.Clamp(
        ScrW() * (Config.PanelScreenWidth or 0.52),
        Config.PanelMinWidth or 520,
        Config.PanelMaxWidth or 860
    )

    local refW = Config.PanelWidth or 760
    local refH = Config.PanelHeight or 250
    local baseH = refH * (baseW / refW)

    local w = baseW * scaleAnimation
    local h = baseH * scaleAnimation

    return (ScrW() - w) * 0.5, (ScrH() - h) * 0.5, w, h
end

local function drawRespawnLine(x, y, w, h, alpha, remaining)
    local prefix = Config.DeathSubtitlePrefix or "Vous allez réapparaitre dans"
    local suffix = Config.DeathSubtitleSuffix or "secondes.."
    local countText = tostring(remaining)

    local prefixW = measureText("KrypDeathScreen.Subtitle", prefix)
    local countW = measureText("KrypDeathScreen.Countdown", countText)
    local suffixW = measureText("KrypDeathScreen.Subtitle", suffix)

    local gap = math.max(10, math.floor(w * 0.012))
    local totalW = prefixW + gap + countW + gap + suffixW

    local startX = x + (w * 0.5) - (totalW * 0.5)
    local centerY = y + (h * 0.66)

    drawGlowText(
        prefix,
        "KrypDeathScreen.Subtitle",
        startX,
        centerY,
        Config.MutedTextColor or Color(220, 220, 220),
        alpha,
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    drawGlowText(
        countText,
        "KrypDeathScreen.Countdown",
        startX + prefixW + gap,
        centerY,
        Config.TextColor or Color(255, 255, 255),
        alpha,
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    drawGlowText(
        suffix,
        "KrypDeathScreen.Subtitle",
        startX + prefixW + gap + countW + gap,
        centerY,
        Config.MutedTextColor or Color(220, 220, 220),
        alpha,
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )
end

local function drawReadyLine(x, y, w, h, alpha)
    local pulse = 0.88 + math.sin(RealTime() * 5.0) * 0.08

    drawGlowText(
        Config.ReadyMessage or "APPUYEZ SUR UNE TOUCHE",
        "KrypDeathScreen.Ready",
        x + (w * 0.5),
        y + (h * 0.66),
        Config.TextColor or Color(255, 255, 255),
        alpha * pulse,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )
end

local function drawDeathPanel(alpha, scaleAnimation, remaining)
    local x, y, w, h = getPanelRect(scaleAnimation)
    local radius = Config.PanelRadius or 18

    drawSoftBox(x, y, w, h, radius, alpha)

    drawGlowText(
        Config.DeathTitle or "VOUS ÊTES MORT.",
        "KrypDeathScreen.Title",
        x + (w * 0.5),
        y + (h * 0.42),
        Config.TextColor or Color(255, 255, 255),
        alpha,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    if remaining > 0 then
        drawRespawnLine(x, y, w, h, alpha, remaining)
    else
        drawReadyLine(x, y, w, h, alpha)
    end

    draw.SimpleText(
        Config.CreditText or "Réalisateur : Kryp Studio",
        "KrypDeathScreen.Credit",
        x + (w * 0.5),
        y + h - 18,
        withAlpha(Config.MutedTextColor or Color(220, 220, 220), alpha * 0.85),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_BOTTOM
    )
end

hook.Add("HUDPaint", "KrypDeathScreen.Draw", function()
    if not state.visible then return end

    local alpha, scaleAnimation = getAnimation()
    if alpha <= 0 then return end

    local backgroundAlpha = math.Clamp((Config.BackgroundAlpha or 235) * alpha, 0, 255)
    surface.SetDrawColor(0, 0, 0, backgroundAlpha)
    surface.DrawRect(0, 0, ScrW(), ScrH())

    -- Assombrissement doux des bords
    surface.SetDrawColor(0, 0, 0, 55 * alpha)
    surface.DrawRect(0, 0, ScrW(), ScrH() * 0.18)
    surface.DrawRect(0, ScrH() * 0.82, ScrW(), ScrH() * 0.18)
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
        ["$pp_colour_brightness"] = -0.080 * alpha,
        ["$pp_colour_contrast"] = 1 - (0.18 * alpha),
        ["$pp_colour_colour"] = 1 - (0.82 * alpha),
        ["$pp_colour_mulr"] = 0,
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
