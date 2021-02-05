PHONY := __all
__all:

include make/build_utils.mk

# Consts.
OUT_DIR := out

# Include the built directory's makefile.
include $(SRC_TREE)/$(BUILD_DIR)/makefile

# Determine the build target extension.
ifeq ($(TYPE), exe)
  EXT := $(EXE_EXT)
  BUILD_TARGET_CMD := link_exe
else ifeq ($(TYPE), shared)
  EXT := $(SHARED_EXT)
  BUILD_TARGET_CMD:= link_shared
else ifeq ($(TYPE), static)
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
BUILD_TARGET := $(addprefix out/,$(BUILD_TARGET))
# Subdirectories we need to descend into.
BUILD_SUBDIRS := $(filter %/, $(OBJ))
# Object files to build.
BUILD_OBJ := $(filter-out $(BUILD_SUBDIRS), $(OBJ))
# Append the build directory to each build item.
BUILD_SUBDIRS := $(addprefix $(BUILD_DIR)/,$(patsubst %/,%,$(BUILD_SUBDIRS)))
BUILD_OBJ := $(addprefix $(BUILD_DIR)/,$(BUILD_OBJ))

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

$(BUILD_TARGET): $(BUILD_OBJ) FORCE | $(OUT_DIR)
	$(call if_changed,$(BUILD_TARGET_CMD))

$(OUT_DIR):
	$(Q)mkdir -p $(OUT_DIR)

# Build the C files.
quiet_cmd_cc_o_c = CC   $@
      cmd_cc_o_c = $(CC) $(CFLAGS) -c $< -o $@

define rule_cc_o_c
	$(Q)mkdir -p $(dir $@)
	$(call cmd,cc_o_c)
endef

$(BUILD_DIR)/%.o: $(SRC_TREE)/$(BUILD_DIR)/%.c FORCE
	$(call if_changed_rule,cc_o_c)

# Descent and build each build sub-directory.
PHONY := descend $(BUILD_SUBDIRS)
descend: $(BUILD_SUBDIRS)
$(BUILD_SUBDIRS):
	$(Q)$(MAKE) $(build)=$@

# Add FORCE to the prequisites of a target to force it to be always rebuilt.
# ---------------------------------------------------------------------------
PHONY += FORCE
FORCE:

.PHONY: $(PHONY)
