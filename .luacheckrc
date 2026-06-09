std = "lua51"

max_line_length = 250

exclude_files = {
   "libraries/",
   "tutorial/",
}

files["tree.lua"] = {
   max_line_length = 500,
}

globals = {
   "love",

   "Object", "Timer", "Input", "fn", "Camera", "Physics", "Vector",
   "draft", "bitser", "Math", "Grid", "Cam", "Tim", "binser", "HC", "ffi",

   "GameObject",
   "gw", "gh", "sx", "sy",

   "default_color", "background_color", "ammo_color", "boost_color",
   "hp_color", "skill_point_color", "default_colors", "negative_colors",
   "all_colors", "white", "dark", "gray", "red", "green", "blue",
   "pink", "brown", "yellow", "orange", "bluegreen", "purple",

   "attacks", "attack_names",

   "setPermanentGlobals", "setTransientGlobals",
   "id", "loop", "main_volume", "sfx_volume", "music_volume", "muted",
   "fullscreen", "display", "screen_shake", "distortion", "glitch",
   "achievements", "high_score",
   "skill_points", "bought_node_indexes", "run", "device",
   "unlocked_devices", "classes", "rank", "score", "found_keys",
   "max_tree_nodes", "spent_sp", "keys", "command_history",

   "enemies", "class_colors", "unlockAchievement",
   "achievement_names", "achievement_descriptions", "devices",

   "Stat",

   "tree", "types", "treeToPlayer",

   "Stage", "Console", "SkillTree", "Director", "Achievements",
   "AchievementScreenshots", "Classes",

   "Player", "Projectile", "Area", "Attack", "Boost",
   "ConsoleInputLine", "ConsoleLine", "Drone", "EnemyProjectile",
   "Explosion", "HasteArea", "HP", "InfoText", "Item", "Key",
   "Line", "Node", "Paused", "ScoreScreen", "Shake", "SkillPoint",
   "Tutorial", "Ammo",

   "AmmoEffect", "AttackEffect", "BoostEffect", "CycleEffect",
   "EnemyDeathEffect", "ExplodeParticles", "GlitchBlockDisplacement",
   "GlitchDisplacement", "GlitchDisplacementC", "GlitcherShootEffect",
   "LaserLine", "LightningLine", "PreAttackEffect",
   "ProjectileDeathEffect", "ProjectileTrails", "RGBShift",
   "ShapeEffect", "ShapeEffect2", "ShockwaveDisplacement",
   "ShootEffect", "TargetParticle", "TrailParticle", "TrailParticles",
   "TrailerShootEffect", "WaverPreAttackEffect",

   "Rock", "BigRock", "Shooter", "Seeker", "Waver", "Roller",
   "Trailer", "Reflecteer", "Orbitter", "Tanker", "Rotator",
   "RotatorPart", "Triad", "Sapper", "Glitcher", "RollerPool",

   "AboutModule", "ClearModule", "CreditsModule", "DeviceModule",
   "DisplayModule", "EffectsModule", "EscapeModule",
   "FullscreenModule", "HelpModule", "ResolutionModule",
   "ShutdownModule", "SoundModule",

   "UUID", "KEY", "random", "round", "sign",
   "pushRotate", "pushRotateScale",
   "areRectanglesOverlapping", "rectangleToVertexList",
   "getPointsAlongLine", "createIrregularPolygon", "BSGRectangle",
   "chanceList", "distance", "pointLineDistance",
   "rotatePointAroundPoint", "printCenteredText",
   "drawCenteredRectangle", "drawRectangle", "addColor",

   "time", "start_time", "start_date", "trailer_mode",
   "timer", "input", "camera", "sound",
   "current_room", "slow_amount", "fps",
   "disable_expensive_shaders", "pre_disable_expensive_shaders",
   "disable_expensive_shaders_time",
   "flash_frames",
   "first_run_ever",

   "loadFonts", "loadGraphics", "loadShaders",
   "recursiveEnumerate", "requireFiles",
   "gotoRoom", "save", "load", "removeSave",
   "resize", "resizeFullscreen", "changeToDisplay",
   "getScaleBasedOnDisplay",

   "flash", "slow", "frameStop",

   "count_all", "type_count", "type_name", "global_type_table",

   "fonts", "assets", "shaders",

   "sound", "soundUpdate", "register", "isAnySongPlaying", "play",
   "fadeIn", "fadeOut", "fadeVolume", "playRandomSong", "playKeystroke",
   "playMenuClick", "playComputerStartup", "fadeInComputerBackground",
   "fadeOutComputerBackground", "playMenuSwitch", "playMenuSelect",
   "playMenuBack", "playMenuError", "playComputerLine",
   "playGameShoot1", "playGameShoot2", "playGameExplosion",
   "playGameItem", "playGameEnemyDie", "playGameKey",
   "playGameLaser", "playGameLightning", "playGameHurt", "playGameFlame",

   "update_times", "update_index", "draw_times", "draw_index",
   "command_history_index", "delay", "verified_keys", "AchievementModule",
   "target",

   "table.find",
   "table.random",
   "table.randomh",
   "table.merge",
   "table.copy",
}

unused = false
redefined = false

ignore = {
   "212",
   "541",
   "542",
   "621",
   "122",
}
