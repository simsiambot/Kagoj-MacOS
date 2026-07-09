#!/bin/bash

# Kagoj macOS Build Script
# Run this script on a Mac to compile the raw Swift files into a native .app bundle!

echo "🚀 Building Kagoj for macOS..."

# Create the .app bundle structure
mkdir -p Kagoj.app/Contents/MacOS
mkdir -p Kagoj.app/Contents/Resources

if [ -f "AppIcon.icns" ]; then
    cp AppIcon.icns Kagoj.app/Contents/Resources/
fi

# Create a basic Info.plist
cat <<EOF > Kagoj.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Kagoj</string>
    <key>CFBundleIdentifier</key>
    <string>com.studiochoccymilk.Kagoj</string>
    <key>CFBundleName</key>
    <string>Kagoj</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSUIElement</key>
    <true/> <!-- This hides the app from the Dock! -->
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Compile the Swift files directly into the .app binary
swiftc Sources/*.swift -o Kagoj.app/Contents/MacOS/Kagoj -framework Cocoa

# Ad-hoc sign the entire app bundle (required for Apple Silicon)
codesign --force --deep --sign - Kagoj.app

echo "✅ Build Complete! You can now launch Kagoj.app"
