# BYTEPATH-fork Roadmap: Adapt -> Test -> Publish

Original by [a327ex](https://github.com/a327ex/BYTEPATH) · Fork by scillidan · License: MIT

## Current Status

| Item | Value |
|------|-------|
| LÖVE version | 0.10.2 (Super Toast, 2016) |
| Virtual resolution | 480x270 (16:9), canvas + integer scaling |
| Input | Keyboard + Mouse + Gamepad (boipushy) |
| Key rebinding | None (hardcoded per room) |
| Touch support | None |
| Build targets | Windows, Linux |

---

## Phase 1: Adapt

### 1.1 [BLOCKER] LÖVE 0.10.2 -> 11.5 API Migration

Required for modern platform support.

| 0.10.2 | 11.5 | Scope |
|--------|------|-------|
| `setColor(255,0,0)` | `setColor(1,0,0)` | Every setColor/setBackgroundColor/clear call |
| `newCanvas(w,h)` | `newCanvas(w,h,{msaa=n})` | Canvas creation in main.lua, Stage.lua |
| Shader `uniform extern` | `uniform` | All 8 .frag files |
| `love.window.getPixelScale` | `love.window.getDPIScale` | main.lua |
| `love.filesystem.exists` | `love.filesystem.getInfo` | Save/load code |
| `love.window.setMessage` | Removed | main.lua |
| `love.audio.newSource` default | `stream` vs `static` explicit | sound.lua |

- [ ] Grep all setColor/setBackgroundColor, convert 0-255 to 0-1
- [ ] Update all 8 shader files (effects/*.frag) syntax
- [ ] Verify Canvas constructors and setCanvas API
- [ ] Test bitser serialization with new LÖVE types
- [ ] Update conf.lua: t.version = "11.5", remove deprecated fields
- [ ] Update Makefile: LOVE_VERSION := 11.5, bundle new runtime

### 1.2 Screen Adaptation

- [ ] Add love.resize(w, h) callback in main.lua
- [ ] Letterbox/pillarbox for non-16:9 displays
- [ ] HiDPI via love.window.getDPIScale()
- [ ] Test ultrawide (21:9) and 4:3

### 1.3 Key Rebinding

Current: input:unbindAll() + hardcoded binds per room, no persistence.

- [ ] Create settings.lua with save/load (bitser or JSON)
- [ ] Minimal settings UI in Console room
- [ ] Store binds in love.filesystem.getSaveDirectory()
- [ ] Replace hardcoded input:bind() with configurable lookup
- [ ] Preserve defaults as fallback

### 1.4 Shader Pipeline Verification

6+ canvas/shader passes (RGB shift -> displacement -> glitch -> RGB separation -> distort).

- [ ] Test each shader on 11.5
- [ ] Fallback: disable effects on shader compile failure

---

## Phase 2: Test

### 2.1 Test Matrix

| Platform | Variant | Priority |
|----------|---------|----------|
| Windows 10/11 | x64 fused exe | High |
| Linux X11 | Flatpak | High |
| Linux Wayland | Flatpak | High |

### 2.2 Smoke Test Checklist

- [ ] Launch -> Main menu -> Start game
- [ ] Full gameplay run
- [ ] Pause / Resume
- [ ] Fullscreen toggle
- [ ] Window resize (desktop)
- [ ] Gamepad connect/disconnect
- [ ] Save / Load
- [ ] Skill tree navigation
- [ ] Console text input
- [ ] Clean exit

### 2.3 Performance Targets

| Metric | Target |
|--------|--------|
| FPS | >= 60 sustained |
| Memory | < 500 MB |
| Startup | < 3 sec |
| Bundle size | < 50 MB |

### 2.4 CI (GitHub Actions)

- [ ] Luacheck lint on push
- [ ] Build .love on tag
- [ ] Build Windows zip on tag
- [ ] Build Flatpak on tag
- [ ] Auto GitHub Release

---

## Phase 3: Publish

### 3.1 Scoop (Windows)

Strategy: self-contained bucket.

1. [ ] Create GitHub repo `scoop-bucket` via BucketTemplate
2. [ ] Write manifest bytepath.json (version, url, hash, bin, shortcuts, autoupdate)
3. [ ] Users: `scoop bucket add bytepath <repo> && scoop install bytepath`

### 3.2 Flathub (Linux)

Reference: org.love2d.love2d already on Flathub.

1. [ ] Prepare: manifest yml + metainfo.xml + .desktop + SVG icon
2. [ ] App ID: io.github.scillidan.bytepath
3. [ ] Manifest: build LÖVE from source + install game.love + launcher script
4. [ ] Local build + lint
5. [ ] Fork flathub/flathub, open PR

---

## Execution Order

```
#1  [BLOCKER] LÖVE 0.10.2 -> 11.5 migration
#2  Screen adaptation (love.resize + letterbox)
#3  Key rebinding system
#4  Shader pipeline verification on 11.5
#5  CI setup (GitHub Actions)
#6  Scoop bucket + manifest
#7  Flathub manifest + metainfo
#8  GitHub Release automation
```
