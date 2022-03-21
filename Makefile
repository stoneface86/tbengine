
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
# BGB emulator
#
BGB ?= bgb

#
# python3
#
PY ?= python

PAD_VALUE := 0xFF

ASM_FLAGS := -i $(INC_DIR) -p $(PAD_VALUE)
DEFINES := -D TBE_PRINT_USAGE

# (optional) user-specific overrides
# this can be used to specify the location of the RGBDS toolchain manually
# or a different build directory can be used by overriding BUILD_DIR
-include user.mk

RGBASM := $(RGBDS)rgbasm
RGBLINK := $(RGBDS)rgblink
RGBFIX := $(RGBDS)rgbfix
RGBGFX := $(RGBDS)rgbgfx

TESTER_OBJ := tests/tester.obj \
              tests/tbengine.obj \
              tests/test_seqenum.obj \
              tests/test_update_nr51.obj
TESTER_OBJ := $(addprefix $(BUILD_DIR)/,$(TESTER_OBJ))
# dependency files
TESTER_DEPS := $(TESTER_OBJ:.obj=.d)

# get a list of all directories that will need to be created when building
# patsubst removes the trailing slash
# (for some reason if this was left in, make would always remake the directories)
# sort is used to remove duplicates
OBJ_FILES := $(TESTER_OBJ)
OBJ_DIRS := $(patsubst %/,%,$(sort $(dir $(OBJ_FILES))))

TESTER_GB := $(BUILD_DIR)/tester.gb
TESTER_MAP := $(BUILD_DIR)/tester.map
TESTER_SYM := $(BUILD_DIR)/tester.sym


#
# List of object files to build, when adding a new assembly file, add its
# object file here (preferably in alphabetical order).
# Note: globbing could be used, but I do not recommend it for various reasons
#       (speed, excluding files is a pain, etc)
#
# OBJ_FILES := demo/main.obj \
#              demo/joypad.obj \
#              demo/music/stageclear.obj \
#              demo/music/nationalpark.obj \
#              demo/music/rushingheart.obj \
#              demo/music/calltest.obj \
#              demo/music/waveforms.obj \
#              $(TBENGINE_OBJ)
# OBJ_FILES := $(addprefix $(BUILD_DIR)/,$(OBJ_FILES))

# # dependency files to be created by the assembler
# OBJ_DEPS := $(OBJ_FILES:.obj=.d)

# # get a list of all directories that will need to be created when building
# # patsubst removes the trailing slash
# # (for some reason if this was left in, make would always remake the directories)
# # sort is used to remove duplicates
# OBJ_DIRS := $(patsubst %/,%,$(sort $(dir $(OBJ_FILES))))


# -----------------------------------------------------------------------------
# RULES

#
# default target is the ROM file
#
all: $(TESTER_GB)

#lib: $(BUILD_DIR)/$(TBENGINE_OBJ)

test: $(TESTER_GB)
	@echo "TEST     $(TESTER_GB)"
	@$(BGB) -hf -setting DebugSrcBrk=1 -rom $(TESTER_GB)
	@$(PY) $(SRC_DIR)/tests/savchecker.py $(TESTER_GB:.gb=.sav)

define ASSEMBLE_RULE
	@echo "ASM      $@"
	@$(RGBASM) $(ASM_FLAGS) -h $(DEFINES) -M $(BUILD_DIR)/$*.d -o $@ $<
endef

# export all symbols so we can test everything
$(BUILD_DIR)/tests/tbengine.obj: ASM_FLAGS += -E

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
# Pattern rule for png images to planar tile format
#
$(BUILD_DIR)/%.png.2bpp: $(SRC_DIR)/%.png $(MAKEFILE_LIST)
	@echo "GFX      $@"
	@$(RGBGFX) -o $@ $<

# $(ROM_GB): $(OBJ_FILES) $(MAKEFILE_LIST)
# 	@echo "LINK     $@"
# 	@$(RGBLINK) $(LINK_FLAGS) -o $@ $(OBJ_FILES)
# 	@echo "FIX      $@"
# 	@$(RGBFIX) $(FIX_FLAGS) $@

#
# Tester ROM
#
$(TESTER_GB): $(TESTER_OBJ) $(MAKEFILE_LIST)
	@echo "LINK     $@"
	@$(RGBLINK) -m $(TESTER_MAP) -n $(TESTER_SYM) -o $@ $(TESTER_OBJ)
	@echo "FIX      $@"
	@$(RGBFIX) -f lhg -i "TEST" -t "Tester" -p $(PAD_VALUE) -m 0x03 -r 0x02 $@

$(OBJ_FILES): | $(OBJ_DIRS)

$(OBJ_DIRS):
	@echo "MKDIR    $@"
	@mkdir -p $@

#
# Remove all built files
#
clean:
	rm -rf $(BUILD_DIR)/*

run: $(ROM_GB)
	@echo "RUN      $(ROM_GB)"
	@$(BGB) $(ROM_GB)

.PHONY: all clean run test

#
# Keep these files for debugging
#
.PRECIOUS: $(TESTER_MAP) $(TESTER_SYM)

#
# assembler-generated dependency files
#
-include $(TESTER_DEPS)
