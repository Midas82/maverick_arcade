# Base image with Flutter pre-installed
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build the Linux binary (Server runs on Linux usually)
RUN flutter config --enable-linux-desktop
RUN flutter build linux --release

CMD ["/app/build/linux/x64/release/bundle/maverick_server"]
