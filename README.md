# Sniper

A lightweight macOS menu bar app for quick OCR text extraction from screen regions.

## Installation

```bash
git clone https://github.com/arunim1/sniper.git
cd sniper
chmod +x build_app.sh
./build_app.sh
cp -r Sniper.app /Applications/
```

### Auto-launch on Login (Optional)

```bash
mkdir -p ~/Library/LaunchAgents
cp com.sniper.Sniper.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.sniper.Sniper.plist
```

## Usage

1. Press ⌘⇧2
2. Select a region
3. Text is copied to clipboard

## Features

- Global hotkey (⌘⇧2)
- OCR using Apple Vision framework
- Runs in background (no dock icon)
- Multi-display support
- Offline - no internet required

## Requirements

- macOS 13.0+
- Screen Recording permission (prompted on first use)

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.sniper.Sniper.plist
rm ~/Library/LaunchAgents/com.sniper.Sniper.plist
rm -rf /Applications/Sniper.app
```

## Development

```bash
swift build -c release
# Or use: make build
```

Built with Swift, AppKit, and Vision framework.
