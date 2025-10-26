# Quick Start

## Build and Run

```bash
# Clone
git clone https://github.com/arunim1/sniper.git
cd sniper

# Build
chmod +x build_app.sh
./build_app.sh

# Install
cp -r Sniper.app /Applications/

# Run
open /Applications/Sniper.app
```

## First Use

1. Grant Screen Recording permission when prompted
2. Find the Sniper icon in your menu bar
3. Press ⌘⇧2 to capture text

## Auto-launch

```bash
mkdir -p ~/Library/LaunchAgents
cp com.sniper.Sniper.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.sniper.Sniper.plist
```

## Troubleshooting

### Permission denied
System Settings → Privacy & Security → Screen Recording → Enable Sniper

### Hotkey not working
Check menu bar for the Sniper icon - if it's there, the app is running

## Development

```bash
# Build
swift build -c release

# Clean
make clean

# Generate Xcode project
swift package generate-xcodeproj
```
