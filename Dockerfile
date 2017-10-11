FROM nathanosman/nasm as builder
ADD hang.asm /hang.asm
RUN nasm -f elf64 hang.asm
RUN ld -s -o hang hang.o


FROM scratch
MAINTAINER Nathan Osman <nathan@quickmediasolutions.com>

# Add the binary to the container
COPY --from=builder /hang /hang

# Set it as the default entrypoint
ENTRYPOINT ["/hang"]
