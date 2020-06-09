
#
# Makefile for building the library and demo ROM
#

#------------------------------------------------------------------------------
# VARIABLES

# some important paths (no trailing slash)
BUILD_DIR := build
INC_DIR := inc/
SRC_DIR := ./

#
# ROM file name
#
ROM_NAME := demo

#
# game ID string (must be 4 characters)
#
ROM_ID := DEMO

#
# game title (truncated to 16 characters)
#
ROM_TITLE := DEMO

ROM_GB := $(BUILD_DIR)/$(ROM_NAME).gb
ROM_MAP := $(BUILD_DIR)/$(ROM_NAME).map
ROM_SYM := $(BUILD_DIR)/$(ROM_NAME).sym

#
# Variables for the RGB toolchain (just the command name if you have PATH set)
#
RGBASM := rgbasm
RGBLINK := rgblink
RGBFIX := rgbfix
RGBGFX := rgbgfx

#
# BGB emulator
#
BGB := bgb

ASM_FLAGS := -i $(INC_DIR)
LINK_FLAGS := -m $(ROM_MAP) -n $(ROM_SYM)
FIX_FLAGS := -f lhg -i "$(ROM_ID)" -t "$(ROM_TITLE)" -p 0x0
DEFINES := -D TBE_ROM0

# (optional) user-specific overrides
# this can be used to specify the location of the RGBDS toolchain manually
# or a different build directory can be used by overriding BUILD_DIR
-include user.mk

LIB_SRC := lib/info.asm \
           lib/macros.asm \
           lib/engine.asm \
		   lib/commands.asm \
		   lib/frequency.asm \
           lib/tables.asm \
		   lib/utils.asm \
		   lib/wram.asm

#
# The library is combined into a single asm file for releases
#
LIB_FILE := $(BUILD_DIR)/tbengine.asm

LIB_OBJ_FILES := lib/all.obj
#
# List of object files to build, when adding a new assembly file, add its
# object file here (preferably in alphabetical order).
# Note: globbing could be used, but I do not recommend it for various reasons
#       (speed, excluding files is a pain, etc)
#
OBJ_FILES := demo/main.obj \
             demo/samplesong.obj \
             $(LIB_OBJ_FILES)
OBJ_FILES := $(addprefix $(BUILD_DIR)/,$(OBJ_FILES))

# dependency files to be created by the assembler
OBJ_DEPS := $(OBJ_FILES:.obj=.d)

# get a list of all directories that will need to be created when building
# patsubst removes the trailing slash
# (for some reason if this was left in, make would always remake the directories)
# sort is used to remove duplicates
OBJ_DIRS := $(patsubst %/,%,$(sort $(dir $(OBJ_FILES))))


# -----------------------------------------------------------------------------
# RULES

#
# default target is the ROM file
#
all: $(ROM_GB)

lib: $(LIB_FILE)

define ASSEMBLE_RULE
	@echo "ASM      $@"
	@$(RGBASM) $(ASM_FLAGS) $(DEFINES) -M $(BUILD_DIR)/$*.d -o $@ $<
endef

#
# Pattern rule for assembly source to an object file
#
$(BUILD_DIR)/%.obj: $(SRC_DIR)/%.asm $(MAKEFILE_LIST)
	$(ASSEMBLE_RULE)

#
# Same as above except for *.z80 files
#
$(BUILD_DIR)/%.obj: $(SRC_DIR)/%.z80 $(MAKEFILE_LIST)
	$(ASSEMBLE_RULE)

#
# library target
#
$(LIB_FILE): $(LIB_SRC) $(MAKEFILE_LIST)
	cat $(LIB_SRC) > $@

#
# Pattern rule for png images to planar tile format
#
$(BUILD_DIR)/%.png.2bpp: $(SRC_DIR)/%.png $(MAKEFILE_LIST)
	@echo "GFX      $@"
	@$(RGBGFX) -o $@ $<

$(ROM_GB): $(OBJ_FILES) $(MAKEFILE_LIST)
	@echo "LINK     $@"
	@$(RGBLINK) $(LINK_FLAGS) -o $@ $(OBJ_FILES)
	@echo "FIX      $@"
	@$(RGBFIX) $(FIX_FLAGS) $@
$(ROM_GB): DEFINES += -D TBE_EXPORT_FC

$(OBJ_FILES): | $(OBJ_DIRS)

$(OBJ_DIRS):
	@echo "MKDIR    $@"
	@mkdir -p $@

#
# Remove all built files
#
clean:
	rm -f $(ROM_GB) $(ROM_SYM) $(ROM_MAP) $(OBJ_FILES) $(OBJ_DEPS)

run: $(ROM_GB)
	@echo "RUN      $(ROM_GB)"
	@$(BGB) $(ROM_GB)

.PHONY: all clean lib run

#
# Keep these files for debugging
#
.PRECIOUS: $(ROM_MAP) $(ROM_SYM)

#
# assembler-generated dependency files
#
-include $(OBJ_DEPS)
