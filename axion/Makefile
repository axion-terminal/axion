TARGET := axion$(SO_EXT)

OBJ := \
	src/main.o
OBJ := $(addprefix $(BUILD_DIR), $(OBJ))

all: $(TARGET)

$(TARGET): $(OBJ)
	$(call link_shared)
