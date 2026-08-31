KrypDeathScreen = KrypDeathScreen or {}
KrypDeathScreen.Config = KrypDeathScreen.Config or {}

local Config = KrypDeathScreen.Config

-- UI distante
Config.ImageURL = "https://i.imgur.com/Ba5xCtK.png"
Config.CacheFile = "kryp_deathscreen/deathscreen_ba5xctk.png"

-- Temps avant de pouvoir réapparaitre.
Config.RespawnDelay = 45

-- Si activé, utilise GAMEMODE.Config.respawntime quand DarkRP le fournit.
Config.UseDarkRPRespawnTime = false

-- Taille de l'image à l'écran.
Config.ImageScreenWidth = 0.46
Config.ImageMaxWidth = 900
Config.ImageMinWidth = 460

-- Position du nombre du compte à rebours DANS l'image.
-- 0.50 = centre horizontal, 0.50 = centre vertical.
-- Ajuste ces deux valeurs si ton PNG change légèrement.
Config.CountdownX = 0.50
Config.CountdownY = 0.58

-- Décalage vertical du message affiché lorsque le timer est terminé.
Config.ReadyMessageOffset = 42

-- Animations
Config.FadeInDuration = 0.38
Config.FadeOutDuration = 0.34
Config.StartScale = 0.94
Config.EndScale = 1.035

-- Effet visuel sur le monde pendant la mort.
Config.EnableWorldEffect = true
Config.WorldEffectStrength = 0.82

-- Textes
Config.ReadyMessage = "Merci de cliquer sur une touche pour réapparaitre"

-- Réseau
KrypDeathScreen.Net = KrypDeathScreen.Net or {
    Start = "KrypDeathScreen.Start",
    Stop = "KrypDeathScreen.Stop",
    Respawn = "KrypDeathScreen.Respawn"
}
