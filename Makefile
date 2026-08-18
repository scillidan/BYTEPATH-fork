.PHONY: all clean lint windows linux linux-arm

GAME_NAME := bytepath
LOVE_VERSION := 11.5
DIST_DIR := dist
BUILD_DIR := build
LOVE_DIR := love

all: windows linux linux-arm

lint:
	luacheck --codes --ranges . || true

clean:
	@rm -rf $(DIST_DIR) $(BUILD_DIR)

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(DIST_DIR):
	@mkdir -p $(DIST_DIR)

$(BUILD_DIR)/$(GAME_NAME).love: $(BUILD_DIR)
	@cd . && zip -r $(BUILD_DIR)/$(GAME_NAME).love conf.lua main.lua globals.lua utils.lua GameObject.lua tree.lua settings.lua libraries objects rooms resources -x "*.git*"

windows: $(BUILD_DIR)/$(GAME_NAME).love $(DIST_DIR)
	@echo "Building Windows executable..."
	@mkdir -p $(BUILD_DIR)/windows
	@cp -r $(LOVE_DIR)/* $(BUILD_DIR)/windows/
	@cat $(BUILD_DIR)/windows/love.exe $(BUILD_DIR)/$(GAME_NAME).love > $(BUILD_DIR)/windows/$(GAME_NAME).exe
	@rm $(BUILD_DIR)/windows/love.exe
	@rm $(BUILD_DIR)/windows/lovec.exe
	@mv $(BUILD_DIR)/windows/$(GAME_NAME).exe $(BUILD_DIR)/windows/love.exe
	@cd $(BUILD_DIR)/windows && zip -r ../../$(DIST_DIR)/$(GAME_NAME)-windows.zip *
	@echo "Windows build complete: $(DIST_DIR)/$(GAME_NAME)-windows.zip"

linux: $(BUILD_DIR)/$(GAME_NAME).love $(DIST_DIR)
	@echo "Building Linux executable..."
	@mkdir -p $(BUILD_DIR)/linux
	@cp $(BUILD_DIR)/$(GAME_NAME).love $(BUILD_DIR)/linux/
	@echo '#!/bin/bash' > $(BUILD_DIR)/linux/$(GAME_NAME).sh
	@echo 'LOVE_VERSION=$(LOVE_VERSION)' >> $(BUILD_DIR)/linux/$(GAME_NAME).sh
	@echo 'if ! command -v love &> /dev/null; then' >> $(BUILD_DIR)/linux/$(GAME_NAME).sh
	@echo '    echo "LÖVE2D is not installed. Please install love $(LOVE_VERSION)"' >> $(BUILD_DIR)/linux/$(GAME_NAME).sh
	@echo '    exit 1' >> $(BUILD_DIR)/linux/$(GAME_NAME).sh
	@echo 'fi' >> $(BUILD_DIR)/linux/$(GAME_NAME).sh
	@echo 'SCRIPT_DIR="$$(cd "$$(dirname "$$0")" && pwd)"' >> $(BUILD_DIR)/linux/$(GAME_NAME).sh
	@echo 'love "$$SCRIPT_DIR/$(GAME_NAME).love"' >> $(BUILD_DIR)/linux/$(GAME_NAME).sh
	@chmod +x $(BUILD_DIR)/linux/$(GAME_NAME).sh
	@cd $(BUILD_DIR)/linux && zip -r ../../$(DIST_DIR)/$(GAME_NAME)-linux.zip *
	@echo "Linux build complete: $(DIST_DIR)/$(GAME_NAME)-linux.zip"

linux-arm: $(BUILD_DIR)/$(GAME_NAME).love $(DIST_DIR)
	@echo "Building Linux ARM executable..."
	@mkdir -p $(BUILD_DIR)/linux-arm
	@cp $(BUILD_DIR)/$(GAME_NAME).love $(BUILD_DIR)/linux-arm/
	@echo '#!/bin/sh' > $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo 'LOVE_BIN=""' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo 'for name in love love-11.5 love-11.4 love-11.3 love-0.10.2; do' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo '  if command -v "$$name" >/dev/null 2>&1; then LOVE_BIN="$$name"; break; fi' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo 'done' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo 'if [ -z "$$LOVE_BIN" ]; then' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo '  for dir in /usr/local/bin /usr/bin /snap/bin "$$HOME/.local/bin" "$$HOME/bin" /opt/love/usr/bin; do' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo '    for name in love love-11.5; do' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo '      if [ -x "$$dir/$$name" ]; then LOVE_BIN="$$dir/$$name"; break 2; fi' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo '    done' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo '  done' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo 'fi' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo 'if [ -z "$$LOVE_BIN" ]; then' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo '    echo "LOVE $(LOVE_VERSION) is required but no love executable was found in PATH." >&2' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo '    echo "Install it, e.g.:  sudo apt install love" >&2' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo '    exit 1' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo 'fi' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo 'SCRIPT_DIR="$$(cd "$$(dirname "$$0")" && pwd)"' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@echo 'exec "$$LOVE_BIN" "$$SCRIPT_DIR/$(GAME_NAME).love"' >> $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@chmod +x $(BUILD_DIR)/linux-arm/$(GAME_NAME).sh
	@cd $(BUILD_DIR)/linux-arm && zip -r ../../$(DIST_DIR)/$(GAME_NAME)-linux-arm.zip *
	@echo "Linux ARM build complete: $(DIST_DIR)/$(GAME_NAME)-linux-arm.zip"