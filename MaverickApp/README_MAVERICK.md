# Maverick Task App

A React Native Expo app for Android that displays random tasks from a list. Tap the big "MAVERICK" button to hear a dubstep sting and get a random task. Long-press the task to delete it.

## Features

- **One Big Button**: Tap the oversized "MAVERICK" button to trigger a dubstep sound and display a random task
- **Task List**: 40 pre-loaded tasks from `assets/tasks.json`
- **Long-Press Delete**: Hold down on a task to delete it from the list
- **Task Counter**: See how many tasks remain
- **Dark Theme**: Eye-friendly dark interface with orange accent color

## Installation & Setup

1. Install dependencies:
```bash
cd MaverickApp
npm install
```

2. Run on Android:
```bash
npm run android
```

Or start the Expo development server:
```bash
npm start
```

Then press `a` to run on Android emulator/device.

## How to Use

1. **Tap MAVERICK**: Press the large orange button to play the dubstep sting and get a random task
2. **Read Task**: The task appears in a card below the button
3. **Delete Task**: Long-press (hold for ~1 second) on the task card to remove it from the list
4. **Repeat**: Tap MAVERICK again to get another random task

## Project Structure

```
MaverickApp/
├── app/
│   ├── _layout.tsx          # Root layout
│   └── index.tsx            # Main screen with all app logic
├── assets/
│   ├── tasks.json           # List of 40 tasks
│   └── dubstep-sting.wav    # Generated audio file
├── package.json
└── tsconfig.json
```

## Technologies

- **React Native** with Expo
- **TypeScript**
- **Expo Router** for navigation
- **Expo AV** for audio playback

## Adding More Tasks

Edit `assets/tasks.json` and add new task strings to the "tasks" array:

```json
{
  "tasks": [
    "Existing task",
    "New task here",
    ...
  ]
}
```

## Building for Production

To build an APK or AAB for Android:

```bash
eas build --platform android
```

Or use Expo CLI for a development APK:

```bash
expo build:android -t apk
```

## Notes

- Tasks are stored in memory; deleting them persists only during the current app session
- The dubstep sting is generated programmatically to keep the app small
- App requires audio permissions on Android (handled by Expo automatically)
