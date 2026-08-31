KrypDeathScreen = KrypDeathScreen or {}
KrypDeathScreen.Config = KrypDeathScreen.Config or {}

local Config = KrypDeathScreen.Config

-- Respawn
Config.RespawnDelay = 45
Config.UseDarkRPRespawnTime = false

-- Fond général
Config.BackgroundAlpha = 212
Config.EnableWorldEffect = true
Config.WorldEffectStrength = 0.80

-- Bloc central discret, sans cadre extérieur
Config.ContentWidth = 720
Config.ContentHeight = 230
Config.ContentMinWidth = 520
Config.ContentMaxWidth = 820
Config.ContentScreenWidth = 0.46
Config.ContentRadius = 16
Config.ContentAlpha = 118

-- Couleurs
Config.AccentColor = Color(232, 92, 36)
Config.AccentGlowColor = Color(255, 112, 48)
Config.TextColor = Color(248, 248, 248)
Config.MutedTextColor = Color(205, 205, 210)

-- Animations
Config.FadeInDuration = 0.40
Config.FadeOutDuration = 0.30
Config.StartScale = 0.97
Config.EndScale = 1.015

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
