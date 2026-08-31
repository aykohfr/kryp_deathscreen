KrypDeathScreen = KrypDeathScreen or {}
KrypDeathScreen.Config = KrypDeathScreen.Config or {}

local Config = KrypDeathScreen.Config

-- Respawn
Config.RespawnDelay = 45
Config.UseDarkRPRespawnTime = false

-- Fond global
Config.BackgroundAlpha = 205
Config.EnableWorldEffect = true
Config.WorldEffectStrength = 0.78

-- Grande fenêtre façon deathscreen cinématique
Config.FrameScreenWidth = 0.88
Config.FrameScreenHeight = 0.78
Config.FrameMinWidth = 850
Config.FrameMaxWidth = 1500
Config.FrameRadius = 10

-- Zone centrale transparente laissant voir la scène
Config.ViewScreenWidth = 0.70
Config.ViewScreenHeight = 0.60
Config.ViewRadius = 14
Config.ViewOverlayAlpha = 118

-- Couleurs
Config.AccentColor = Color(214, 66, 45)
Config.AccentGlowColor = Color(235, 78, 52)
Config.TextColor = Color(245, 245, 245)
Config.MutedTextColor = Color(178, 178, 182)
Config.FrameColor = Color(5, 5, 6, 188)
Config.FrameBorderColor = Color(225, 225, 225, 220)

-- Animations
Config.FadeInDuration = 0.40
Config.FadeOutDuration = 0.30
Config.StartScale = 0.985
Config.EndScale = 1.01

-- Textes
Config.DeathTitle = "VOUS ÊTES MORT.."
Config.DeathSubtitlePrefix = "Vous allez réapparaitre dans "
Config.DeathSubtitleSuffix = " secondes.."
Config.ReadyMessage = "APPUYEZ SUR UNE TOUCHE"
Config.CreditText = "Réalisateur : Kryp Studio"

-- Réseau
KrypDeathScreen.Net = KrypDeathScreen.Net or {
    Start = "KrypDeathScreen.Start",
    Stop = "KrypDeathScreen.Stop",
    Respawn = "KrypDeathScreen.Respawn"
}
