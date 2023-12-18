# Compiler
CC = gcc

# Compile-time flags
CFLAGS = -Wall -pg

# Link-time flags
LDFLAGS = -lm

# List of linked files
INCLUDES = fonctions_ES.o timers_b.o 

# Target (final executable)
TARGET = my_program
TARGET_PG = my_program_pg
TARGET_DTIME = my_program_dtime
TARGET_PRINTLAYERNEURONSCPU = my_program_printLayerNeuronsCPU

# Rules
all: $(TARGET) $(TARGET_PG) $(TARGET_DTIME) $(TARGET_PRINTLAYERNEURONSCPU)

$(TARGET): $(INCLUDES) main.o
	$(CC) $(LDFLAGS) -o $(TARGET) $(INCLUDES) main.o

$(TARGET_PG): $(INCLUDES) main_pg.o
	$(CC) $(LDFLAGS) -o $(TARGET) $(INCLUDES) main_pg.o

$(TARGET_DTIME): $(INCLUDES) main_dtime.o
	$(CC) $(LDFLAGS) -o $(TARGET) $(INCLUDES) main_dtime.o

$(TARGET_PRINTLAYERNEURONSCPU): $(INCLUDES) main_printLayerNeuronsCPU.o
	$(CC) $(LDFLAGS) -o $(TARGET_PRINTLAYERNEURONSCPU) $(INCLUDES) main_printLayerNeuronsCPU.o

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean rule
clean:
	rm $(TARGET) $(TARGET_PG) $(TARGET_DTIME) $(TARGET_PRINTLAYERNEURONSCPU) *.o *.txt
