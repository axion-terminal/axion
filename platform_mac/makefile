# Default target.
PHONY := __all
__all:

# Toolchain.
LDFLAGS := $(LDFLAGS) -framework AppKit

# Directories.
THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
PLATFORM_MAC_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
AXION_DIR := axion
SRC_DIR := $(PLATFORM_MAC_DIR)/src
INCLUDE_DIRS := $(PLATFORM_MAC_DIR)/include $(AXION_DIR)/include
OBJ_DIR := $(OBJ_DIR)/$(PLATFORM_MAC_DIR)

INCLUDE_FLAGS := $(addprefix -I,$(INCLUDE_DIRS))

# All target.
__all: all

PHONY += all
all:
	@:

# Platform layer target.
PLATFORM_MAC := $(BIN_DIR)/axion

OBJ := \
	main.o

OBJ := $(addprefix $(OBJ_DIR)/,$(OBJ))

all: $(PLATFORM_MAC)
$(PLATFORM_MAC): $(OBJ)
	@echo LD $@
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) $^ -o $@ $(LDFLAGS)

# Single-file targets.
# C source files.
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo CC $<
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) $(CFLAGS) $(INCLUDE_FLAGS) $< -c -o $@

# Objective-C source files.
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.m
	@echo CC $<
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) $(CFLAGS) $(INCLUDE_FLAGS) $< -c -o $@

# Phony targets.
.PHONY: $(PHONY)