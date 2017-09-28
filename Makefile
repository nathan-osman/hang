CWD = $(shell pwd)
UID = $(shell id -u)
GID = $(shell id -g)

all: dist/hang

dist/hang: hang.o
	@docker run \
	    --rm \
	    -e UID=${UID} \
	    -e GID=${GID} \
	    -v ${CWD}:/usr/local/src/hang \
	    -w /usr/local/src/hang \
	    nathanosman/nasm \
	    ld -s -o hang hang.o

hang.o: hang.asm
	@docker run \
	    --rm \
	    -e UID=${UID} \
	    -e GID=${GID} \
	    -v ${CWD}:/usr/local/src/hang \
	    -w /usr/local/src/hang \
	    nathanosman/nasm \
	    nasm -f elf64 hang.asm

clean:
	@rm hang hang.o

.PHONY: clean
