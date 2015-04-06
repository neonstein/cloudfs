
# --------------------------------------------------------------------------
# VERBOSE Compile Information 
ifdef VERBOSE
        VERBOSE = true
        VERBOSE_ECHO = @ echo
        VERBOSE_SHOW =
        QUIET_ECHO = @ echo > /dev/null
else
        VERBOSE = false
        VERBOSE_ECHO = @ echo > /dev/null
        VERBOSE_SHOW = @
        QUIET_ECHO = @ echo
endif


# --------------------------------------------------------------------------
# BUILD directory
ifndef BUILD
    ifdef DEBUG
        BUILD := build-debug
    else
        BUILD := build
    endif
endif

# --------------------------------------------------------------------------
# Acquire configuration information for libraries that libs3 depends upon

ifndef CURL_LIBS
    CURL_LIBS := $(shell curl-config --libs)
endif

ifndef LIBXML2_LIBS
    LIBXML2_LIBS := $(shell xml2-config --libs)
endif

# --------------------------------------------------------------------------
# Setup FUSE flags 

FUSE_CFLAGS := -D_FILE_OFFSET_BITS=64 \
					 		 -DFUSE_USE_VERSION=26 \
					     -I/usr/local/include/fuse \
					     -I/usr/include/fuse

FUSE_LIBS := -lfuse

# --------------------------------------------------------------------------
# These CFLAGS assume a GNU compiler.  For other compilers, write a script
# which converts these arguments into their equivalent for that particular
# compiler.

ifndef CFLAGS
    ifdef DEBUG
        CFLAGS := -g
    else
        CFLAGS := -O3
    endif
endif

#          $(CURL_CFLAGS) $(LIBXML2_CFLAGS) 
	
CFLAGS += -Wall  -Wshadow -Wextra -Iinclude \
					$(FUSE_CFLAGS) \
          -D__STRICT_ANSI__ \
          -D_ISOC99_SOURCE \
          -D_POSIX_C_SOURCE=200112L

LDFLAGS = $(CURL_LIBS) $(LIBXML2_LIBS) $(FUSE_LIBS) -lpthread

LIBRARY = ./lib/libs3.a 

# --------------------------------------------------------------------------
# Default targets are everything

.PHONY: all
all: cloudfs 

# --------------------------------------------------------------------------
# Compile target patterns

$(BUILD)/obj/%.o: cloudfs/%.c
	$(QUIET_ECHO) $@: Compiling object
	@ mkdir -p $(dir $(BUILD)/dep/$<)
	@ gcc $(CFLAGS) -M -MG -MQ $@ -DCOMPILINGDEPENDENCIES \
        -o $(BUILD)/dep/$(<:%.c=%.d) -c $<
	@ mkdir -p $(dir $@)
	$(VERBOSE_SHOW) gcc $(CFLAGS) -o $@ -c $<


# --------------------------------------------------------------------------
# CloudFS targets

.PHONY: cloudfs 
cloudfs: $(BUILD)/bin/cloudfs

CLOUDFS_OBJS = $(BUILD)/obj/cloudapi.o \
							 $(BUILD)/obj/cloudfs.o \
							 $(BUILD)/obj/main.o

#You can append other objects

$(BUILD)/bin/cloudfs: $(CLOUDFS_OBJS)
	$(QUIET_ECHO) $@: Building executable
	@ mkdir -p $(dir $@)
	$(VERBOSE_SHOW) gcc -o $@ $^ $(LDFLAGS) $(LIBRARY)

# --------------------------------------------------------------------------
# Example targets

.PHONY: example 
example: $(BUILD)/bin/example

CLOUDFS_OBJS = $(BUILD)/obj/cloudapi.o \
							 $(BUILD)/obj/cloudfs.o \
							 $(BUILD)/obj/example.o

$(BUILD)/bin/example: $(CLOUDFS_OBJS)
	$(QUIET_ECHO) $@: Building executable
	@ mkdir -p $(dir $@)
	$(VERBOSE_SHOW) gcc -o $@ $^ $(LDFLAGS) $(LIBRARY)

# --------------------------------------------------------------------------
# Clean target

.PHONY: clean
clean:
	$(QUIET_ECHO) $(BUILD): Cleaning
	$(VERBOSE_SHOW) rm -rf $(BUILD)