# ROM Version
VERSION := 0x01

# 4 Character Game ID
GAMEID := DTGM

# ROM Title (14 chars max)
TITLE := DMGTRIS

# "Licensee" code (2 chars)
LICENSEE := NR

# Output options
ROMNAME := DMGTRIS
ROMEXT  := GBC

# Mapper
MAPPER := 0x1B

# Extra assembler flags
# Do not insert nop after halt
ASFLAGS += -h

# Extra fix flags
# Set as gbc compatible
FIXFLAGS += -c
