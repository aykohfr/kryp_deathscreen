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

-- Position du nombre du compte à rebours dans le PNG.
-- Le nombre est placé juste après le mot "dans" et garde une taille proche
-- de celle du texte inférieur de l'interface.
Config.CountdownX = 0.635
Config.CountdownY = 0.58

-- Taille du compteur, relative à la hauteur de l'écran.
Config.CountdownFontScale = 0.019
Config.CountdownFontMin = 18
Config.CountdownFontMax = 30

-- Fond sombre derrière l'interface.
-- 0 = invisible, 255 = noir complet.
Config.BackgroundAlpha = 155

-- Décalage vertical du message affiché lorsque le timer est terminé.
Config.ReadyMessageOffset = 42

-- Animations
Config.FadeInDuration = 0.38
Config.FadeOutDuration = 0.34
Config.StartScale = 0.94
Config.EndScale = 1.035

-- Effet visuel sur le monde pendant la mort.
Config.EnableWorldEffect = true
Config.WorldEffectStrength = 0.58

-- Textes
Config.ReadyMessage = "Merci de cliquer sur une touche pour réapparaitre"

-- Réseau
KrypDeathScreen.Net = KrypDeathScreen.Net or {
    Start = "KrypDeathScreen.Start",
    Stop = "KrypDeathScreen.Stop",
    Respawn = "KrypDeathScreen.Respawn"
}
