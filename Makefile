
.SUFFIXES:

################################################
#                                              #
#             CONSTANT DEFINITIONS             #
#                                              #
################################################

# Directory constants
BINDIR := bin
OBJDIR := obj
DEPDIR := dep

# Program constants
ifneq ($(strip $(shell which rm)),)
    # POSIX OSes
    RM_RF := rm -rf
    MKDIR_P := mkdir -p
    PY :=
    filesize = printf 'NB_PB$2_BLOCKS equ ((%u) + $2 - 1) / $2\n' "`wc -c <$1`"
else
    # Windows outside of a POSIX env (Cygwin, MSYS2, etc.)
    # We need Powershell to get any sort of decent functionality
    $(warning Powershell is required to get basic functionality)
    RM_RF := -del /q
    MKDIR_P := -mkdir
    PY := python
    filesize = powershell Write-Output $$('NB_PB$2_BLOCKS equ ' + [string] [int] (([IO.File]::ReadAllBytes('$1').Length + $2 - 1) / $2))
endif

# Shortcut if you want to use a local copy of RGBDS
RGBDS   :=
RGBASM  := $(RGBDS)rgbasm
RGBLINK := $(RGBDS)rgblink
RGBFIX  := $(RGBDS)rgbfix
RGBGFX  := $(RGBDS)rgbgfx

ROM = $(BINDIR)/$(ROMNAME).$(ROMEXT)

# Argument constants
INCDIRS  = src/ src/include/
WARNINGS = all extra
ASFLAGS  = -p 0xFF $(addprefix -i,$(INCDIRS)) $(addprefix -W,$(WARNINGS))
LDFLAGS  = -p 0xFF
FIXFLAGS = -p 0xFF -l 0x33 -m 0x03 -r 0x02 -v -i $(GAMEID) -k $(LICENSEE) -t $(TITLE) -n $(VERSION)

# The list of "root" ASM files that RGBASM will be invoked on
SRCS = $(wildcard src/*.asm)

## Project-specific configuration
# Use this to override the above
include project.mk

################################################
#                                              #
#                    TARGETS                   #
#                                              #
################################################

# `all` (Default target): build the ROM
all: $(ROM)
.PHONY: all

# `clean`: Clean temp and bin files
clean:
	$(RM_RF) $(BINDIR)
	$(RM_RF) $(OBJDIR)
	$(RM_RF) $(DEPDIR)
	$(RM_RF) res
.PHONY: clean

# `rebuild`: Build everything from scratch
# It's important to do these two in order if we're using more than one job
rebuild:
	$(MAKE) clean
	$(MAKE) all
.PHONY: rebuild

################################################
#                                              #
#                RESOURCE FILES                #
#                                              #
################################################

# By default, asset recipes convert files in `res/` into other files in `res/`
# This line causes assets not found in `res/` to be also looked for in `src/res/`
# "Source" assets can thus be safely stored there without `make clean` removing them
VPATH := src

res/%.1bpp: res/%.png
	@$(MKDIR_P) $(@D)
	$(RGBGFX) -d 1 -o $@ $<

# Define how to compress files using the PackBits16 codec
# Compressor script requires Python 3
res/%.pb16: res/% src/tools/pb16.py
	@$(MKDIR_P) $(@D)
	$(PY) src/tools/pb16.py $< res/$*.pb16

res/%.pb16.size: res/%
	@$(MKDIR_P) $(@D)
	$(call filesize,$<,16) > res/$*.pb16.size

# Define how to compress files using the PackBits8 codec
# Compressor script requires Python 3
res/%.pb8: res/% src/tools/pb8.py
	@$(MKDIR_P) $(@D)
	$(PY) src/tools/pb8.py $< res/$*.pb8

res/%.pb8.size: res/%
	@$(MKDIR_P) $(@D)
	$(call filesize,$<,8) > res/$*.pb8.size

###############################################
#                                             #
#                 COMPILATION                 #
#                                             #
###############################################

# How to build a ROM
$(BINDIR)/%.$(ROMEXT) $(BINDIR)/%.sym $(BINDIR)/%.map: $(patsubst src/%.asm,$(OBJDIR)/%.o,$(SRCS))
	@$(MKDIR_P) $(@D)
	$(RGBASM) $(ASFLAGS) -o $(OBJDIR)/build_date.o src/res/build_date.asm
	$(RGBLINK) $(LDFLAGS) -m $(BINDIR)/$*.map -n $(BINDIR)/$*.sym -o $(BINDIR)/$*.$(ROMEXT) $^ $(OBJDIR)/build_date.o \
	&& $(RGBFIX) -v $(FIXFLAGS) $(BINDIR)/$*.$(ROMEXT)

# `.mk` files are auto-generated dependency lists of the "root" ASM files, to save a lot of hassle.
# Also add all obj dependencies to the dep file too, so Make knows to remake it
# Caution: some of these flags were added in RGBDS 0.4.0, using an earlier version WILL NOT WORK
# (and produce weird errors)
$(OBJDIR)/%.o $(DEPDIR)/%.mk: src/%.asm
	@$(MKDIR_P) $(patsubst %/,%,$(dir $(OBJDIR)/$* $(DEPDIR)/$*))
	$(RGBASM) $(ASFLAGS) -M $(DEPDIR)/$*.mk -MG -MP -MQ $(OBJDIR)/$*.o -MQ $(DEPDIR)/$*.mk -o $(OBJDIR)/$*.o $<

ifneq ($(MAKECMDGOALS),clean)
-include $(patsubst src/%.asm,$(DEPDIR)/%.mk,$(SRCS))
endif

# Catch non-existent files
# KEEP THIS LAST!!
%:
	@false
