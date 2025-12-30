# Base image with Flutter pre-installed
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build the APK (defaulting to release)
# You can override this command to build for linux or other targets
RUN flutter build apk --release

# Stage 2: Scratch (Optional - just to output the artifact)
# For now, we leave it as a build environment. 
# To extract the APK: docker cp <container_id>:/app/build/app/outputs/flutter-apk/app-release.apk .

CMD ["echo", "Build complete. Artifacts are in /app/build/app/outputs/flutter-apk/"]
