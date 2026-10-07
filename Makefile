NASM = nasm
CC = gcc
NASMFLAGS = -f elf64 -g -F dwarf
CFLAGS = -Wall -Wextra -g -no-pie

TARGET = my_printf_demo

.PHONY: build run valgrind clean

build: $(TARGET)

my_printf.o: my_printf.asm
	$(NASM) $(NASMFLAGS) my_printf.asm -o my_printf.o

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

$(TARGET): main.o my_printf.o
	$(CC) $(CFLAGS) main.o my_printf.o -o $(TARGET)

run: build
	./$(TARGET)

valgrind: build
	valgrind --leak-check=full --track-origins=yes ./$(TARGET)

clean:
	rm -f $(TARGET) main.o my_printf.o
