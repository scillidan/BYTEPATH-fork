# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Removed

- Removed Steam integration (`libraries/steamworks.lua`, `love/steam_api.dll`, `love/steam_api64.dll`, `love/steam_appid.txt`)
- Removed Steam achievement sync (`loadAchievementsFromSteam`, `Steam.userstats.SetAchievement`, `Steam.userstats.StoreStats`)
- Removed Steam cloud save logic (`Steam.remotestorage.FileWrite/FileRead/FileDelete`)
- Removed `Steam = require 'libraries/steamworks'` from `main.lua`

### Changed

- Fixed variable shadowing: removed redundant `local` in default argument patterns (`local opts = opts or {}` → `opts = opts or {}`) across 9 files
- Fixed inconsistent indentation: replaced tabs with spaces in 9 files
- Removed trailing whitespace from 59 files
- Removed empty `if` branches for `classes.turner`, `classes.dasher`, `self.turner`, `self.dasher` in `objects/Player.lua`
- Split over-long line in `rooms/SkillTree.lua` (line 166)

### Added

- Added `.gitignore` (`/dist`, `/build`)
- Added `Makefile` with `lint`, `windows`, `linux`, `linux-arm`, and `clean` targets
- Added `.luacheckrc` with project-specific globals, exclusions, and lint configuration
