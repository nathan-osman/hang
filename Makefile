SKIP_DOCKER=$(shell which nasm >/dev/null && which ld >/dev/null && echo yes)

ifeq ($(SKIP_DOCKER),yes)
  RUN =
else
  CWD = $(shell pwd)
  UID = $(shell id -u)
  GID = $(shell id -g)
  RUN = @docker run \
      --rm \
      -e UID=${UID} \
      -e GID=${GID} \
      -v ${CWD}:/usr/local/src/hang \
      -w /usr/local/src/hang \
      nathanosman/nasm
endif

all: hang

hang: hang.o
	$(RUN) ld -s -o hang hang.o

hang.o: hang.asm
	$(RUN) nasm -f elf64 hang.asm

clean:
	$(RM) hang hang.o

.PHONY: clean
