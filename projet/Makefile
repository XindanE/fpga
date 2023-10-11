# Compiler
CC = gcc

# Compile-time flags
CFLAGS = -Wall -pg

# Link-time flags
LDFLAGS = -lm -pg

# List of object files
OBJS = fonctions_ES.o timers_b.o main.o

# Target (final executable)
TARGET = my_program

# Rules
all: $(TARGET)

$(TARGET): $(OBJS) 
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJS)

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

fonctions_ES.o: fonctions_ES.c
	$(CC) $(CFLAGS) -c fonctions_ES.c

timers_b.o: timers_b.c
	$(CC) $(CFLAGS) -c timers_b.c

# Clean rule
clean:
	rm -f $(OBJS) $(TARGET)
