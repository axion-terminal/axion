# *DOCUMENTATION*
# To see a list of typical targets execute "make help"
# More info can be located in ./README
# Comments in this file are targeted only to the developer, do not
# expect to learn how to build the kernel reading this file.

$(if $(filter __%, $(MAKECMDGOALS)), \
	$(error targets prefixed with '__' are only for internal use))

# That's our default target when none is given on the command line
PHONY := __all
__all:

# We are using a recursive build, so we need to do a little thinking
# to get the ordering right.
#
# Most importantly: sub-Makefiles should only ever modify files in
# their own directory. If in some directory we have a dependency on
# a file in another dir (which doesn't happen often, but it's often
# unavoidable when linking the built-in.a targets which finally
# turn into vmlinux), we will call a sub make in that other dir, and
# after that we are sure that everything which is in that other dir
# is now up to date.
#
# The only cases where we need to modify files which have global
# effects are thus separated out and done before the recursive
# descending is started. They are now explicitly listed as the
# prepare rule.

ifneq ($(SUB_MAKE_DONE),1)

# Do not use make's built-in rules and variables
# (this increases performance and avoids hard-to-debug behaviour)
MAKEFLAGS += -rR

# Avoid funny character set dependencies
unexport LC_ALL
LC_COLLATE=C
LC_NUMERIC=C
export LC_COLLATE LC_NUMERIC

# Avoid interference with shell env settings
unexport GREP_OPTIONS

# Beautify output
# ---------------------------------------------------------------------------
#
# Normally, we echo the whole command before executing it. By making
# that echo $($(quiet)$(cmd)), we now have the possibility to set
# $(quiet) to choose other forms of output instead, e.g.
#
#         quiet_cmd_cc_o_c = Compiling $(RELDIR)/$@
#         cmd_cc_o_c       = $(CC) $(c_flags) -c -o $@ $<
#
# If $(quiet) is empty, the whole command will be printed.
# If it is set to "quiet_", only the short version will be printed.
# If it is set to "silent_", nothing will be printed at all, since
# the variable $(silent_cmd_cc_o_c) doesn't exist.
#
# A simple variant is to prefix commands with $(Q) - that's useful
# for commands that shall be hidden in non-verbose mode.
#
#	$(Q)ln $@ :<
#
# If VERBOSE equals 0 then the above command will be hidden.
# If VERBOSE equals 1 then the above command is displayed.
# If VERBOSE equals 2 then give the reason why each target is rebuilt.
#
# To put more focus on warnings, be less verbose as default
# Use 'make V=1' to see the full commands

ifeq ("$(origin V)", "command line")
  VERBOSE = $(V)
endif
ifndef VERBOSE
  VERBOSE = 0
endif

ifeq ($(VERBOSE),1)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif

# If the user is running make -s (silent mode), suppress echoing of
# commands

ifneq ($(findstring s,$(filter-out --%,$(MAKEFLAGS))),)
  quiet=silent_
endif

export quiet Q VERBOSE

# We will save output files in the current working directory.
# This does not need to match to the root of the kernel source tree.
#
# For example, you can do this:
#
#  cd /dir/to/store/output/files; make -f /dir/to/kernel/source/Makefile
#
# If you want to save output files in a different location, there are
# two syntaxes to specify it.
#
# 1) O=
# Use "make O=dir/to/store/output/files/"
#
# 2) Set OUTPUT_DIR
# Set the environment variable OUTPUT_DIR to point to the output directory.
# export OUTPUT_DIR=dir/to/store/output/files/; make
#
# The O= assignment takes precedence over the OUTPUT_DIR environment
# variable.

# Do we want to change the working directory?
ifeq ("$(origin O)", "command line")
  OUTPUT_DIR := $(O)
endif

ifneq ($(OUTPUT_DIR),)
# Make's built-in functions such as $(abspath ...), $(realpath ...) cannot
# expand a shell special character '~'. We use a somewhat tedious way here.
ABS_OBJ_TREE := $(shell mkdir -p $(OUTPUT_DIR) && cd $(OUTPUT_DIR) && pwd)
$(if $(ABS_OBJ_TREE),, \
     $(error failed to create output directory "$(OUTPUT_DIR)"))

# $(realpath ...) resolves symlinks
ABS_OBJ_TREE := $(realpath $(ABS_OBJ_TREE))
else
ABS_OBJ_TREE := $(CURDIR)
endif # ifneq ($(OUTPUT_DIR),)

ifeq ($(ABS_OBJ_TREE),$(CURDIR))
# Suppress "Entering directory ..." unless we are changing the work directory.
MAKEFLAGS += --no-print-directory
else
need-sub-make := 1
endif

ABS_SRC_TREE := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

ifneq ($(words $(subst :, ,$(ABS_SRC_TREE))), 1)
$(error source directory cannot contain spaces or colons)
endif

ifneq ($(ABS_SRC_TREE),$(ABS_OBJ_TREE))
# Look for make include files relative to root of kernel src
#
# This does not become effective immediately because MAKEFLAGS is re-parsed
# once after the Makefile is read. We need to invoke sub-make.
MAKEFLAGS += --include-dir=$(ABS_SRC_TREE)
need-sub-make := 1
endif

this-makefile := $(lastword $(MAKEFILE_LIST))

ifneq ($(filter 3.%,$(MAKE_VERSION)),)
# 'MAKEFLAGS += -rR' does not immediately become effective for GNU Make 3.x
# We need to invoke sub-make to avoid implicit rules in the top Makefile.
need-sub-make := 1
# Cancel implicit rules for this Makefile.
$(this-makefile): ;
endif

export ABS_SRC_TREE ABS_OBJ_TREE
export SUB_MAKE_DONE := 1

ifeq ($(need-sub-make),1)

PHONY += $(MAKECMDGOALS) __sub-make

$(filter-out $(this-makefile), $(MAKECMDGOALS)) __all: __sub-make
	@:

# Invoke a second make in the output directory, passing relevant variables
__sub-make:
	$(Q)$(MAKE) -C $(ABS_OBJ_TREE) -f $(ABS_SRC_TREE)/Makefile $(MAKECMDGOALS)

endif # need-sub-make
endif # SUB_MAKE_DONE

# We process the rest of the Makefile if this is the final invocation of make
ifeq ($(need-sub-make),)

# Do not print "Entering directory ...",
# but we want to display it when entering to the output directory
# so that IDEs/editors are able to understand relative filenames.
MAKEFLAGS += --no-print-directory

ifeq ($(ABS_SRC_TREE),$(ABS_OBJ_TREE))
  # building in the source tree
  SRCTREE := .
  BUILDING_OUT_OF_SRC_TREE :=
else
  ifeq ($(ABS_SRC_TREE)/,$(dir $(ABS_OBJ_TREE)))
    # building in a subdirectory of the source tree
    SRCTREE := ..
  else
    SRCTREE := $(ABS_SRC_TREE)
  endif
  BUILDING_OUT_OF_SRC_TREE := 1
endif

ifneq ($(ABS_SRC_TREE),)
  SRCTREE := $(ABS_SRC_TREE)
endif

objtree		:= .
VPATH		:= $(SRCTREE)

include make/build_utils.mk

# include make/infer_platform.mk

# Make variables (CC, etc...)
CPP		= $(CC) -E
ifneq ($(LLVM),)
  CC		= clang
  LD		= ld.lld
  AR		= llvm-ar
  NM		= llvm-nm
  OBJCOPY		= llvm-objcopy
  OBJDUMP		= llvm-objdump
  READELF		= llvm-readelf
  STRIP		= llvm-strip
else
  CC		= gcc
  LD		= ld
  AR		= ar
  NM		= nm
  OBJCOPY		= objcopy
  OBJDUMP		= objdump
  READELF		= readelf
  STRIP		= strip
endif

SHELL := bash

CFLAGS := -Wall -Werror
LDFLAGS :=

MODE_DEBUG := debug
MODE_RELEASE := release

ifeq ($(MODE),)
  MODE = debug
endif

ifeq ($(MODE), $(MODE_DEBUG))
  CFLAGS += -g -D_DEBUG
else ifeq ($(MODE), $(MODE_RELEASE))
  LDFLAGS += -O3
else
  $(error Unsupported build mode: [$(MODE)])
endif

PHONY += outputmakefile
# Before starting out-of-tree build, make sure the source tree is clean.
# outputmakefile generates a Makefile in the output directory, if using a
# separate output directory. This allows convenient use of make in the
# output directory.
# At the same time when output Makefile generated, generate .gitignore to
# ignore whole output directory
outputmakefile:
ifdef BUILDING_OUT_OF_SRC_TREE
	$(Q)if [ -f $(SRCTREE)/.config -o \
		 -d $(SRCTREE)/include/config -o \
		 -d $(SRCTREE)/arch/$(SRCARCH)/include/generated ]; then \
		echo >&2 "***"; \
		echo >&2 "*** The source tree is not clean, please run 'make$(if $(findstring command line, $(origin ARCH)), ARCH=$(ARCH)) mrproper'"; \
		echo >&2 "*** in $(ABS_SRC_TREE)";\
		echo >&2 "***"; \
		false; \
	fi
	$(Q)ln -fsn $(SRCTREE) src
	$(Q)$(SHELL) $(SRCTREE)/scripts/mkmakefile $(SRCTREE)
	$(Q)test -e .gitignore || \
	{ echo "# This is a build directory, ignore it."; echo "*"; } > .gitignore
endif

# ===========================================================================
# Build targets: This includes axion, the platform target, clean
# targets and others.

PHONY += all
__all: all

# The directories to descent into while building the project.
BUILD_DIRS := \
	axion/

# Include the platform layer's makefile.
# This layer will add the platform layer directory to the
# list of directories to build (BUILD_DIRS).
# include platform/$(PLATFORM)/makefile

# Execute the build process.
all: descend

PHONY := descend $(BUILD_DIRS)
descend: $(BUILD_DIRS)
$(BUILD_DIRS):
	$(Q)$(MAKE) $(build)=$@


app_dir := axion/

# The all: target is the default when no target is given on the
# command line.
# This allow a user to issue only 'make' to build a kernel including modules
# Defaults to app, but the platform makefile usually adds further targets
app_obj := \
	main.o
app_obj := $(addprefix app_dir/, $(app_obj))

endif # ifeq ($(need-sub-make),)

# Declare the contents of the PHONY variable as phony.  We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)
