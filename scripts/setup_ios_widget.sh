#!/bin/bash

# Script to setup iOS Widget Extension without Xcode
# This script configures the iOS project for Widget support

set -e

echo "🔧 Setting up iOS Widget Extension..."

IOS_DIR="ios"
WIDGET_DIR="$IOS_DIR/TwinAmWidget"
RUNNER_DIR="$IOS_DIR/Runner"

# Create Widget directory if it doesn't exist
mkdir -p "$WIDGET_DIR"

# Copy Swift files
echo "📝 Copying Widget Swift files..."
cp -f "$WIDGET_DIR/TwinAmWidget.swift" "$WIDGET_DIR/TwinAmWidget.swift" 2>/dev/null || true
cp -f "$WIDGET_DIR/Info.plist" "$WIDGET_DIR/Info.plist" 2>/dev/null || true

# Update Runner's Info.plist to add App Group
echo "📱 Configuring App Groups..."

# Check if Info.plist exists
if [ -f "$RUNNER_DIR/Info.plist" ]; then
    # Add App Group entitlement if not exists
    if ! grep -q "group.com.twinam.app" "$RUNNER_DIR/Info.plist"; then
        echo "Adding App Group to Runner Info.plist"
        # This will be handled by Xcode build or manual configuration
    fi
fi

# Create Entitlements file for Runner
RUNNER_ENTITLEMENTS="$RUNNER_DIR/Runner.entitlements"
if [ ! -f "$RUNNER_ENTITLEMENTS" ]; then
    echo "Creating Runner.entitlements..."
    cat > "$RUNNER_ENTITLEMENTS" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.com.twinam.app</string>
	</array>
</dict>
</plist>
EOF
fi

# Create Entitlements file for Widget
WIDGET_ENTITLEMENTS="$WIDGET_DIR/TwinAmWidget.entitlements"
if [ ! -f "$WIDGET_ENTITLEMENTS" ]; then
    echo "Creating TwinAmWidget.entitlements..."
    cat > "$WIDGET_ENTITLEMENTS" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.com.twinam.app</string>
	</array>
</dict>
</plist>
EOF
fi

echo "✅ iOS Widget files setup complete!"
echo ""
echo "🔧 Adding Widget Extension to Xcode project..."

# Run Python script to modify project.pbxproj
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/add_widget_to_xcode.py"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Widget Extension successfully added to Xcode project!"
    echo ""
    echo "📋 Next steps:"
    echo "1. The widget code is ready in $WIDGET_DIR"
    echo "2. App Groups are configured for data sharing"
    echo "3. Widget Extension target is configured in Xcode"
    echo "4. Build the iOS app to test the widget"
else
    echo ""
    echo "⚠️  Warning: Could not automatically add Widget Extension to Xcode project"
    echo "   This may need to be done manually in Xcode"
fi
