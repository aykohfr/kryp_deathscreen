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
        size = math.Clamp(math.floor(h * 0.050), 40, 74),
        weight = 900,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Subtitle", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.018), 18, 28),
        weight = 500,
        antialias = true,
        extended = true,
        italic = true
    })

    surface.CreateFont("KrypDeathScreen.Countdown", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.019), 19, 30),
        weight = 800,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Ready", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.020), 20, 32),
        weight = 900,
        antialias = true,
        extended = true
    })

    surface.CreateFont("KrypDeathScreen.Credit", {
        font = "Roboto",
        size = math.Clamp(math.floor(h * 0.0115), 12, 18),
        weight = 500,
        antialias = true,
        extended = true
    })
end

createFonts()
hook.Add("OnScreenSizeChanged", "KrypDeathScreen.Fonts", createFonts)

local function clamp01(v)
    return math.Clamp(v, 0, 1)
end

local function easeOutCubic(v)
    v = clamp01(v)
    return 1 - ((1 - v) ^ 3)
end

local function withAlpha(col, alpha)
    return Color(col.r, col.g, col.b, math.Clamp((col.a or 255) * alpha, 0, 255))
end

local function getAnimation()
    if state.leaving then
        local duration = math.max(Config.FadeOutDuration or 0.30, 0.01)
        local p = easeOutCubic((RealTime() - state.leaveAt) / duration)
        return 1 - p, Lerp(p, 1, Config.EndScale or 1.015)
    end

    local duration = math.max(Config.FadeInDuration or 0.40, 0.01)
    local p = easeOutCubic((RealTime() - state.startedAt) / duration)
    return p, Lerp(p, Config.StartScale or 0.97, 1)
end

local function getContentRect(scaleAnimation)
    local baseW = math.Clamp(
        ScrW() * (Config.ContentScreenWidth or 0.46),
        Config.ContentMinWidth or 520,
        Config.ContentMaxWidth or 820
    )

    local refW = Config.ContentWidth or 720
    local baseH = (Config.ContentHeight or 230) * (baseW / refW)

    local w = baseW * scaleAnimation
    local h = baseH * scaleAnimation

    return (ScrW() - w) * 0.5, (ScrH() - h) * 0.5, w, h
end

local function measureText(font, text)
    surface.SetFont(font)
    return surface.GetTextSize(text)
end

local function drawSoftGlow(x, y, w, h, radius, color, alpha)
    for i = 6, 1, -1 do
        local grow = i * 3
        local strength = alpha / (i * 1.7)
        draw.RoundedBox(radius + grow, x - grow, y - grow, w + grow * 2, h + grow * 2, Color(color.r, color.g, color.b, strength))
    end
end

local function drawCountdownLine(cx, y, alpha, remaining)
    local prefix = Config.DeathSubtitlePrefix or "Vous allez réapparaitre dans "
    local suffix = Config.DeathSubtitleSuffix or " secondes.."
    local number = tostring(remaining)

    local prefixW = measureText("KrypDeathScreen.Subtitle", prefix)
    local numberW = measureText("KrypDeathScreen.Countdown", number)
    local suffixW = measureText("KrypDeathScreen.Subtitle", suffix)
    local gap = 6
    local total = prefixW + numberW + suffixW + gap * 2
    local x = cx - total * 0.5

    draw.SimpleText(prefix, "KrypDeathScreen.Subtitle", x, y, withAlpha(Config.TextColor or color_white, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    x = x + prefixW + gap

    draw.SimpleText(number, "KrypDeathScreen.Countdown", x, y, withAlpha(Config.AccentColor or Color(232, 92, 36), alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    x = x + numberW + gap

    draw.SimpleText(suffix, "KrypDeathScreen.Subtitle", x, y, withAlpha(Config.TextColor or color_white, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local function drawDeathContent(alpha, scaleAnimation, remaining)
    local x, y, w, h = getContentRect(scaleAnimation)
    local radius = Config.ContentRadius or 16
    local accent = Config.AccentColor or Color(232, 92, 36)
    local glow = Config.AccentGlowColor or Color(255, 112, 48)
    local text = Config.TextColor or Color(248, 248, 248)
    local muted = Config.MutedTextColor or Color(205, 205, 210)

    -- Zone sombre centrale sans cadre visible.
    drawSoftGlow(x, y, w, h, radius, glow, 18 * alpha)
    draw.RoundedBox(radius, x, y, w, h, Color(0, 0, 0, (Config.ContentAlpha or 118) * alpha))

    -- Léger bandeau sombre derrière le titre.
    local titleBoxW = w * 0.58
    local titleBoxH = h * 0.27
    local titleBoxX = x + (w - titleBoxW) * 0.5
    local titleBoxY = y + h * 0.24
    draw.RoundedBox(10, titleBoxX, titleBoxY, titleBoxW, titleBoxH, Color(0, 0, 0, 92 * alpha))

    draw.SimpleText(
        Config.DeathTitle or "VOUS ÊTES MORT..",
        "KrypDeathScreen.Title",
        x + w * 0.5,
        y + h * 0.37,
        withAlpha(accent, alpha),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    if remaining > 0 then
        drawCountdownLine(x + w * 0.5, y + h * 0.64, alpha, remaining)
    else
        local pulse = 0.84 + math.sin(RealTime() * 5) * 0.10
        draw.SimpleText(
            Config.ReadyMessage or "APPUYEZ SUR UNE TOUCHE",
            "KrypDeathScreen.Ready",
            x + w * 0.5,
            y + h * 0.64,
            withAlpha(text, alpha * pulse),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end

    draw.SimpleText(
        Config.CreditText or "Réalisateur : Kryp Studio",
        "KrypDeathScreen.Credit",
        x + w - 14,
        y + h - 10,
        withAlpha(muted, alpha * 0.78),
        TEXT_ALIGN_RIGHT,
        TEXT_ALIGN_BOTTOM
    )
end

hook.Add("HUDPaint", "KrypDeathScreen.Draw", function()
    if not state.visible then return end

    local alpha, scaleAnimation = getAnimation()
    if alpha <= 0 then return end

    local bgAlpha = math.Clamp((Config.BackgroundAlpha or 212) * alpha, 0, 255)
    surface.SetDrawColor(0, 0, 0, bgAlpha)
    surface.DrawRect(0, 0, ScrW(), ScrH())

    -- Vignette simple, aucun cadre.
    surface.SetDrawColor(0, 0, 0, 62 * alpha)
    surface.DrawRect(0, 0, ScrW(), ScrH() * 0.16)
    surface.DrawRect(0, ScrH() * 0.84, ScrW(), ScrH() * 0.16)

    local remaining = math.max(0, math.ceil(state.readyAt - CurTime()))
    drawDeathContent(alpha, scaleAnimation, remaining)
end)

hook.Add("RenderScreenspaceEffects", "KrypDeathScreen.WorldEffect", function()
    if not state.visible or not Config.EnableWorldEffect then return end

    local alpha = select(1, getAnimation()) * (Config.WorldEffectStrength or 0.80)
    if alpha <= 0 then return end

    DrawColorModify({
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = -0.070 * alpha,
        ["$pp_colour_contrast"] = 1 - (0.15 * alpha),
        ["$pp_colour_colour"] = 1 - (0.72 * alpha),
        ["$pp_colour_mulr"] = 0.012 * alpha,
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

    timer.Simple((Config.FadeOutDuration or 0.30) + 0.05, function()
        if state.sequence ~= sequence then return end

        state.visible = false
        state.leaving = false
        state.requested = false
    end)
end)
