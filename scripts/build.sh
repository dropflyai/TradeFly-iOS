#!/bin/bash

# TradeFly Automated Build Script
# This script builds the iOS app and reports any errors

set -e  # Exit on error

echo "🚀 TradeFly Automated Build"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT="TradeFly.xcodeproj"
SCHEME="TradeFly"
DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro"
BUILD_DIR="build"

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
rm -rf ~/Library/Developer/Xcode/DerivedData/TradeFly-*

# Resolve package dependencies
echo -e "${YELLOW}Resolving Swift Package dependencies...${NC}"
xcodebuild -resolvePackageDependencies \
    -project "$PROJECT" \
    -scheme "$SCHEME" 2>&1 | grep -E "Resolved|error" || true

# Build the project
echo -e "${YELLOW}Building project...${NC}"
xcodebuild build \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    2>&1 | tee build.log

# Check if build succeeded
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}✅ BUILD SUCCEEDED${NC}"
    echo "Build artifacts in: $BUILD_DIR"
    exit 0
else
    echo -e "${RED}❌ BUILD FAILED${NC}"
    echo "Extracting errors..."
    grep -E "error:|warning:" build.log | head -20
    exit 1
fi
