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

# Extra assembler flags
# Do not insert nop after halt
ASFLAGS += -h
# Do optimize ld to ldh
ASFLAGS += -l

# Extra linker flags
# Tiny Rom
LDFLAGS += -t

# Extra fix flags
# SEt as gbc compatible
FIXFLAGS += -c
