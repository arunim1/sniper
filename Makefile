.PHONY: build clean run test xcode help

# Variables
APP_NAME = SnipIt
BUNDLE_ID = com.snipit.SnipIt
SCHEME = SnipIt
BUILD_DIR = .build
RELEASE_DIR = $(BUILD_DIR)/release
DERIVED_DATA = $(BUILD_DIR)/DerivedData

help:
	@echo "SnipIt Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  make build      - Build release version"
	@echo "  make debug      - Build debug version"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make xcode      - Generate Xcode project"
	@echo "  make run        - Build and run the app"
	@echo "  make format     - Format Swift code"
	@echo "  make help       - Show this help"

build:
	@echo "Building $(APP_NAME) (Release)..."
	swift build -c release

debug:
	@echo "Building $(APP_NAME) (Debug)..."
	swift build -c debug

clean:
	@echo "Cleaning build artifacts..."
	swift package clean
	rm -rf $(BUILD_DIR)
	rm -rf $(DERIVED_DATA)

run: build
	@echo "Running $(APP_NAME)..."
	$(RELEASE_DIR)/$(APP_NAME)

xcode:
	@echo "Generating Xcode project..."
	swift package generate-xcodeproj

format:
	@echo "Formatting Swift code..."
	@command -v swiftformat >/dev/null 2>&1 && swiftformat Sources/ || echo "swiftformat not installed. Run: brew install swiftformat"

# Development helpers
resolve:
	@echo "Resolving package dependencies..."
	swift package resolve

update:
	@echo "Updating package dependencies..."
	swift package update

# Show package info
describe:
	swift package describe

# Dump package for debugging
dump:
	swift package dump-package
