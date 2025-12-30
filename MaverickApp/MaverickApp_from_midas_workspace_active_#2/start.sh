#!/bin/bash
# Quick start script for Maverick App

echo "🚀 Starting Maverick Task App..."
echo ""
echo "Prerequisites:"
echo "  ✓ Node.js and npm installed"
echo "  ✓ Android SDK/Emulator or device connected"
echo "  ✓ Expo CLI installed globally (npm install -g expo-cli)"
echo ""
echo "Running app on Android..."
echo ""

cd "$(dirname "$0")"
npm run android

echo ""
echo "✅ App is running!"
echo ""
echo "Instructions:"
echo "  1. Tap the big MAVERICK button"
echo "  2. Listen to the dubstep sting"
echo "  3. Read the random task"
echo "  4. Long-press the task to delete it"
echo "  5. Repeat!"
