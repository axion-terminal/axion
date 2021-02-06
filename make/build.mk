PHONY := __all
__all:

include make/build_utils.mk

# Include the currently built directory's makefile.
include $(DIR)/makefile

# Determine the build target extension.
ifeq ($(TYPE), exe)
  BUILD_TARGET_DIR := $(BIN_DIR)
  EXT := $(EXE_EXT)
  BUILD_TARGET_CMD := link_exe
else ifeq ($(TYPE), shared)
  BUILD_TARGET_DIR := $(LIB_DIR)
  EXT := $(SHARED_EXT)
  BUILD_TARGET_CMD:= link_shared
else ifeq ($(TYPE), static)
  BUILD_TARGET_DIR := $(LIB_DIR)
  EXT := $(STATIC_EXT)
  BUILD_TARGET_CMD := ar
else
  $(error Unsupported target type: [$(TYPE)])
endif

# Target to build.
BUILD_TARGET := $(TARGET)
ifneq ($(EXT),)
  BUILD_TARGET := $(addsuffix .$(EXT),$(BUILD_TARGET))
endif
BUILD_TARGET := $(addprefix $(BUILD_TARGET_DIR)/,$(BUILD_TARGET))
# Subdirectories we need to descend into.
BUILD_SUBDIRS := $(filter %/, $(OBJ))
# Object files to build.
BUILD_OBJ := $(filter-out $(BUILD_SUBDIRS), $(OBJ))
# Append the currently built directory to each build item.
BUILD_SUBDIRS := $(addprefix $(SRC_TREE)/$(DIR)/,$(patsubst %/,%,$(BUILD_SUBDIRS)))
BUILD_OBJ := $(addprefix $(OBJ_DIR)/$(DIR)/,$(BUILD_OBJ))

# Build process starts here.
PHONY += all
__all: all
all: $(BUILD_TARGET) descend

# Link the build target.
quiet_cmd_link_exe = LD   $@
      cmd_link_exe = $(LD) $(LDFLAGS) $(real-prereqs) -o $@

quiet_cmd_link_shared = LD   $@
      cmd_link_shared = $(LD) $(LDFLAGS) -fPIC -shared $(real-prereqs) -o $@

quiet_cmd_ar = AR   $@
      cmd_ar = $(AR) $(real-prereqs) -o $@

$(BUILD_TARGET): $(BUILD_OBJ) FORCE
	$(call if_changed,$(BUILD_TARGET_CMD))

# Build the C files.
quiet_cmd_cc_o_c = CC   $@
      cmd_cc_o_c = $(CC) $(CFLAGS) -Wp,-MMD,$(depfile) -c $< -o $@

$(OBJ_DIR)/%.o: $(SRC_TREE)/%.c FORCE
	$(call if_changed_dep,cc_o_c)

# Descent and build each build sub-directory.
PHONY := descend $(BUILD_SUBDIRS)
descend: $(BUILD_SUBDIRS)
$(BUILD_SUBDIRS):
	$(Q)$(MAKE) $(build)=$@

# Add FORCE to the prerequisites of a target to force it to be always rebuilt.
# ---------------------------------------------------------------------------
PHONY += FORCE
FORCE:

# Include all .cmd files, if there are any.
TARGETS := $(BUILD_TARGET) $(BUILD_OBJ)
EXISTING_TARGETS := $(wildcard $(sort $(TARGETS)))
-include $(foreach f,$(EXISTING_TARGETS),$(dir $(f)).$(notdir $(f)).cmd)

.PHONY: $(PHONY)
