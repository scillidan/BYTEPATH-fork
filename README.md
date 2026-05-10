# BYTEPATH

## Requirements

- **LÖVE2D Version: 0.10.2 (Super Toast)**
- Runtime files are located in the `love/` directory

## Running

```bash
# Windows (using bundled runtime)
love/love.exe .

# Linux (requires love 0.10.2 installed)
love .
```

## Building

```bash
make all        # Build for all platforms (windows, linux, linux-arm)
make windows    # Build for Windows
make linux      # Build for Linux
make linux-arm  # Build for Linux ARM
```

Build outputs are placed in `dist/` directory.