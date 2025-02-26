.SUFFIXES:

RM_RF := rm -rf
MKDIR_P := mkdir -p
ifeq ($(strip $(shell which rm)),)
	RM_RF := -rmdir /s /q
	MKDIR_P := -mkdir
endif

RGBDS   ?=
RGBASM  := $(RGBDS)rgbasm
RGBLINK := $(RGBDS)rgblink
RGBFIX  := $(RGBDS)rgbfix
RGBGFX  := $(RGBDS)rgbgfx

ROM = bin/$(ROMNAME).$(ROMEXT)

INCDIRS  = src/ src/include/
WARNINGS = all extra
ASFLAGS  = -p ${PADVALUE} $(addprefix -I,${INCDIRS}) $(addprefix -W,${WARNINGS})
LDFLAGS  = -p ${PADVALUE}
FIXFLAGS = -p ${PADVALUE} -i "${GAMEID}" -k "${LICENSEE}" -l ${OLDLIC} -m ${MBC} -n ${VERSION} -r ${SRAMSIZE} -t ${TITLE}

SRCS = $(wildcard src/*.asm)

include project.mk

all: $(ROM)
.PHONY: all

clean:
	$(RM_RF) dep obj bin
.PHONY: clean

rebuild:
	$(MAKE) clean
	$(MAKE) all
.PHONY: rebuild

bin/%.${ROMEXT}: $(patsubst src/%.asm,obj/%.o,${SRCS})
	@${MKDIR_P} "${@D}"
	${RGBLINK} ${LDFLAGS} -m bin/$*.map -n bin/$*.sym -o $@ $^ \
	&& ${RGBFIX} -v ${FIXFLAGS} $@

obj/%.mk: src/%.asm
	@${MKDIR_P} "${@D}"
	${RGBASM} ${ASFLAGS} -M $@ -MG -MP -MQ ${@:.mk=.o} -MQ $@ -o ${@:.mk=.o} $<

obj/%.o: obj/%.mk
	@touch $@

ifeq ($(filter clean,${MAKECMDGOALS}),)
include $(patsubst src/%.asm,obj/%.mk,${SRCS})
endif
