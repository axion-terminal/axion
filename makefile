# Default target.
# That's our default target when none is given on the command line
PHONY := __all
__all:

# Prettify output.
ifeq ("$(origin V)", "command line")
  VERBOSE := $(V)
endif
ifndef VERBOSE
  VERBOSE := 0
endif

ifeq ($(VERBOSE),1)
  Q :=
else
  Q := @
endif

export VERBOSE Q

# Make flags.
MAKEFLAGS += --no-print-directory

# Toolchain.
CC := clang
CFLAGS := -Wall -Werror -std=c17 -fdiagnostics-absolute-paths -MMD -MP
LDFLAGS :=

# Build mode.
MODE_DEBUG := debug
MODE_RELEASE := release

ifeq ($(MODE),)
  MODE := $(MODE_DEBUG)
endif

ifeq ($(MODE),$(MODE_DEBUG))
  CFLAGS += -g -DBUILD_DEBUG
else ifeq ($(MODE),$(MODE_RELEASE))
  CFLAGS +=-O3 -DBUILD_RELEASE
  LDFLAGS += -flto
endif

# Platform.
PLATFORM := $(shell uname -s)
ifeq ($(PLATFORM),Darwin)
  PLATFORM_LAYER_DIR := platform_mac
  CFLAGS += -DPLATFORM_MAC
else
  $(error Unsupported platform: [$(PLATFORM)])
endif

export CC CFLAGS LDFLAGS

# Directories.
BUILD_DIR := build
OBJ_DIR := $(BUILD_DIR)/obj
BIN_DIR := $(BUILD_DIR)/bin
LIB_DIR := $(BUILD_DIR)/lib

export BUILD_DIR OBJ_DIR BIN_DIR LIB_DIR

# All target.
PHONY += all
__all: all

# Clean targets.
clean:
	$(Q)rm -rf $(OBJ_DIR)

cleanall:
	$(Q)rm -rf $(BUILD_DIR)

# Axion target.
AXION_DIR := axion

all: $(AXION_DIR)

PHONY += $(AXION_DIR)
$(AXION_DIR):
	@$(MAKE) -f $(AXION_DIR)/makefile

# Platform layer target.
all: $(PLATFORM_LAYER_DIR)

PHONY += $(PLATFORM_LAYER_DIR)
$(PLATFORM_LAYER_DIR):
	@$(MAKE) -f $(PLATFORM_LAYER_DIR)/makefile

# Phony targets.
.PHONY: $(PHONY)