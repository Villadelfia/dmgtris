# ROM Version
VERSION := 0x01

# 4 Character Game ID
GAMEID := DTGM

# ROM Title (14 chars max)
TITLE := DMGTRIS

# "Licensee" code (2 chars)
LICENSEE := NR

# Output options
ROMNAME := PandorasBlocks
ROMEXT  := gbc

# Mapper
MAPPER := 0x1B

# Extra assembler flags
# Do not insert nop after halt
ASFLAGS += -h

# 8.24 fixed point.
ASFLAGS += -Q 25

# Extra fix flags
# Set as gbc compatible
FIXFLAGS += -c
