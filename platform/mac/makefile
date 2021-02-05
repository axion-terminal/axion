# Setup the environment for this build.
# We include this Makefile using a relative path (contains a ".."),
# This is because no environment has been setup yet.
# After including this Makefile, paths outside this directory should be
# included using the `TOP` variable (example: $(TOP)/axion/axion.mk).
include ../make/setup_env.mk

# Build the Axion so.
TARGET := axion_app.so

include $(TOP)/axion/axion.mk

# Build the platform layer.
TARGET := axion

SRC_O := \
	mac_axion.o

include $(TOP)/make/build_target.mk
