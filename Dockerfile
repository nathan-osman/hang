FROM scratch
MAINTAINER Nathan Osman <nathan@quickmediasolutions.com>

# Add the binary to the container
ADD hang /hang

# Set it as the default entrypoint
ENTRYPOINT ["/hang"]
