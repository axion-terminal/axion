ifeq ($(OS),Windows_NT)
  PLATFORM := windows
else
  UNAME := $(shell uname -s)
  ifeq ($(UNAME),Linux)
	PLATFORM := linux
  else ifeq ($(UNAME),Darwin)
	PLATFORM := mac
  endif
endif
