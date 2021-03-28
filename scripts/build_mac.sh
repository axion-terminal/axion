#!/bin/bash

# Exit if any error occurs.
set -e

# Directories.
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPTS_DIR="$(dirname "$SCRIPT_PATH")"
PROJECT_DIR="$(dirname "$SCRIPTS_DIR")"
AXION_DIR="$PROJECT_DIR/axion"
PLATFORM_LAYER_DIR="$PROJECT_DIR/platform_mac"
BUILD_DIR="$PROJECT_DIR/build"

# Build setup.
# Toolchain.
CC=clang

# Build flags.
C_FLAGS="-Wall -Werror -std=c17 -fdiagnostics-absolute-paths -DPLATFORM_MAC"
LD_FLAGS="-framework AppKit"

# Build mode setup.
BUILD_MODE="$1"
if [ "$BUILD_MODE" = "debug" ]; then
	C_FLAGS+=" -g -DBUILD_DEBUG"
elif [ "$BUILD_MODE" = "release" ]; then
	C_FLAGS+=" -O3 -DBUILD_RELEASE"
else
	echo "Unknown build mode: [$BUILD_MODE]"
fi

# Build Axion.

# Build the macOS platform layer.
$CC $C_FLAGS "$PLATFORM_LAYER_DIR/src/main.m" -o "$BUILD_DIR/axion" $LD_FLAGS