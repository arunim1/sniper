# Architecture

## Overview

Sniper is a minimal macOS menu bar app for OCR text extraction from screen regions.

## Components

### Core (7 files)
- **main.swift**: Entry point
- **AppDelegate.swift**: Lifecycle and service initialization
- **HotkeyService.swift**: Global hotkey (⌘⇧2) via Carbon Events
- **CaptureController.swift**: Orchestrates capture flow
- **SelectionOverlay.swift**: Rubber-band selection UI
- **OcrService.swift**: Vision framework OCR
- **ClipboardService.swift**: Clipboard operations
- **HUDController.swift**: Toast notifications

### UI (2 files)
- **MenuBarController.swift**: Menu bar with Capture/Quit
- **PreferencesWindowController.swift**: Settings (SwiftUI)

### Data (1 file)
- **PreferencesStore.swift**: UserDefaults wrapper

## Flow

```
⌘⇧2 pressed
  → HotkeyService callback
  → AppDelegate starts capture
  → Show SelectionOverlay
  → User drags selection
  → Capture region (ScreenCaptureKit)
  → OCR text (Vision)
  → Copy to clipboard
  → Show HUD
```

## Stack

- Swift 5.10, AppKit + SwiftUI
- ScreenCaptureKit (macOS 13+)
- Vision framework
- Carbon Events
- Zero dependencies

## Permissions

Screen Recording (TCC prompt on first use)
