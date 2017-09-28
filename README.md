## hang

This application does absolutely nothing. Once started, it will hang until a signal is received.

### Wait, what?

Despite its seemingly useless behavior, this application does serve an important purpose for me. I am using [caddy-docker](https://github.com/nathan-osman/caddy-docker) to monitor containers running in Docker. In order for caddy-docker to route requests to a container, it must remain running. Some containers don't actually do anything and exist solely to configure caddy-docker. However, they must remain running.

That's where this application comes in.

### Why assembly?

This application must not link against any libraries, ensuring it has no dependencies. That is easiest to do in assembly. The entirety of the application's functionality is to hang until a signal is received and this can be done easily with syscalls.

Also, where else can you find a Docker container that occupies less than 1 KB on disk?

### How do I use this?

Assuming you have GNU Make and Docker installed, simply run:

    make

You will have a new binary named `hang` and it will be really small.
