# Default target.
PHONY := __all
__all:

# Directories.
THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
AXION_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
SRC_DIR := $(AXION_DIR)/src
INCLUDE_DIR := $(AXION_DIR)/include
OBJ_DIR := $(OBJ_DIR)/$(AXION_DIR)

# All target.
__all: all

PHONY += all
all:
	@:

# Axion target.
AXION := $(LIB_DIR)/libaxion.so

OBJ := \
	app.o

OBJ := $(addprefix $(OBJ_DIR)/,$(OBJ))

all: $(AXION)
$(AXION): $(OBJ)
	@echo LD $@
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) $^ -fPIC -shared -o $@ $(LDFLAGS)

# Single-file targets.
# C source files.
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo CC $<
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) $(CFLAGS) -I$(INCLUDE_DIR) $< -c -o $@

# Phony targets.
.PHONY: $(PHONY)