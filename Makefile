CC = gcc
ASM = nasm
CFLAGS = -Wall -no-pie -g
ASMFLAGS = -f elf64

all: hookTest

hookTest: tests/hookTest.o arch/x86_64/hook.o
	$(CC) $(CFLAGS) -o hookTest tests/hookTest.o arch/x86_64/hook.o

tests/hookTest.o: tests/hookTest.c
	$(CC) $(CFLAGS) -c tests/hookTest.c -o tests/hookTest.o

arch/x86_64/hook.o: arch/x86_64/hook.asm
	$(ASM) $(ASMFLAGS) arch/x86_64/hook.asm -o arch/x86_64/hook.o

clean:
	rm -f hookTest tests/*.o arch/x86_64/*.o
