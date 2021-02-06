# Toolchain.
AR := ar

# Flags.
CFLAGS += -DPLATFORM_MAC

# Add the platform layer to the directories to build.
BUILD_DIRS += platform/mac/
