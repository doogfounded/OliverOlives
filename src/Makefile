# Compilers and Generators
VALAC    := valac
CXX      := g++
OBJCXX   := clang++
PKG_CFG  := pkg-config

# Target binary
TARGET   := frankenapp

# Source files
VALA_SRCS := ui_frontend.vala
CXX_SRCS  := core_engine.cpp
OBJC_SRCS := apple_bridge.mm

# Generated C files from Vala
VALA_GEN_C   := $(VALA_SRCS:.vala=.c)
VALA_GEN_HDR := vala_exports.h

# Object files
OBJS := $(VALA_GEN_C:.c=.o) $(CXX_SRCS:.cpp=.o) $(OBJC_SRCS:.mm=.o)

# Flags
# 1. Vala flags: target glib/gobject, generate a C header, and compile C sources
VALAFLAGS  := --pkg gobject-2.0 --pkg glib-2.0 -H $(VALA_GEN_HDR) -C

# 2. C / C++ Flags
GLIB_CFLAGS := $(shell $(PKG_CFG) --cflags gobject-2.0 glib-2.0)
CXXFLAGS    := -O2 -std=c++20 -Wall $(GLIB_CFLAGS)
CFLAGS      := -O2 -Wall $(GLIB_CFLAGS)

# 3. Objective-C++ Flags (Clang needs -x objective-c++ or .mm extension)
# Under Linux/BSD, this targets the GNUstep / libobjc2 runtime
OBJCXXFLAGS := -O2 -std=c++20 -Wall $(GLIB_CFLAGS) \
               $(shell gnustep-config --objc-flags 2>/dev/null || echo "-fobjc-runtime=gnustep-2.0")

# Linker flags: GLib/GObject, C++ standard lib, and the Objective-C runtime
LDFLAGS := $(shell $(PKG_CFG) --libs gobject-2.0 glib-2.0) \
           $(shell gnustep-config --base-libs 2>/dev/null || echo "-lobjc") \
           -lstdc++

.PHONY: all clean

all: $(TARGET)

# Final Link Step: use clang++ or g++ to tie together C, C++, and ObjC runtimes
$(TARGET): $(OBJS)
	$(OBJCXX) -o $@ $^ $(LDFLAGS)

# Step 1: Transpile Vala (.vala -> .c + .h)
$(VALA_GEN_C) $(VALA_GEN_HDR): $(VALA_SRCS)
	$(VALAC) $(VALAFLAGS) $<

# Step 2: Compile generated Vala C code
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Step 3: Compile C++ core (depends on Vala generated header if interacting)
%.o: %.cpp $(VALA_GEN_HDR)
	$(CXX) $(CXXFLAGS) -I. -c $< -o $@

# Step 4: Compile Objective-C++ translation unit (.mm)
%.o: %.mm $(VALA_GEN_HDR)
	$(OBJCXX) $(OBJCXXFLAGS) -I. -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJS) $(VALA_GEN_C) $(VALA_GEN_HDR)