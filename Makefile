hang: hang.o
	ld -s -o hang hang.o

hang.o: hang.asm
	nasm -f elf64 hang.asm

clean:
	rm -f hang hang.o

.PHONY: clean
