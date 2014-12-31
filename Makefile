########################################################
#                                                      #
#                      Makefile                        #
#        Single executable for all source files        #
#                                                      #
#                   by Wonmin Jung                     #
#                 wonmin82@gmail.com                   #
#             https://github.com/wonmin82              #
#                                                      #
########################################################

SRCDIR   = src
BUILDDIR = build
TARGET   = a.out

# gcc executables configuration {{{
# CROSS   ?=
CC      := $(CROSS)gcc
CXX     := $(CROSS)g++
LD      := $(CROSS)g++
STRIP   := $(CROSS)strip
# }}}

# clang executables configuration {{{
# CC      := clang
# CXX     := clang++
# LD      := clang++
# }}}

# common flags {{{
DEBUG    = -g -pg
CFLAGS   = -O2 -Wall -pedantic
CXXFLAGS = -O2 -Wall -pedantic -std=c++11
LDFLAGS  = -static -Wall
# }}}
# flags used only when CC is GCC {{{
STRIPFLAGS = --strip-all
# }}}

RM      ?= rm
MKDIR   ?= mkdir

SRCEXT1  = c
SRCEXT2  = cc
SRCEXT3  = cpp

stripwhitespace = $(shell echo $(1) | sed -e "s/ \+ / /g" -e "s/^ *//g" -e "s/ *$$//g")

SRCS1   := $(shell find $(SRCDIR) -name '*.$(SRCEXT1)')
SRCS2   := $(shell find $(SRCDIR) -name '*.$(SRCEXT2)')
SRCS3   := $(shell find $(SRCDIR) -name '*.$(SRCEXT3)')
SRCS	:= $(SRCS1) $(SRCS2) $(SRCS3)
SRCS    := $(call stripwhitespace,$(SRCS))

SRCDIRS1 := $(shell find . -name '*.$(SRCEXT1)' -exec dirname {} \;)
SRCDIRS2 := $(shell find . -name '*.$(SRCEXT2)' -exec dirname {} \;)
SRCDIRS3 := $(shell find . -name '*.$(SRCEXT3)' -exec dirname {} \;)
SRCDIRS := $(shell echo $(SRCDIRS1) $(SRCDIRS2) $(SRCDIRS3) | tr " " "\\n" | sort -u | tr "\\n" " " | sed 's/ $$//')
SRCDIRS := $(call stripwhitespace,$(SRCDIRS))

OBJS1   := $(patsubst %.$(SRCEXT1),$(BUILDDIR)/%.$(SRCEXT1).o,$(SRCS1))
OBJS2   := $(patsubst %.$(SRCEXT2),$(BUILDDIR)/%.$(SRCEXT2).o,$(SRCS2))
OBJS3   := $(patsubst %.$(SRCEXT3),$(BUILDDIR)/%.$(SRCEXT3).o,$(SRCS3))
OBJS    := $(OBJS1) $(OBJS2) $(OBJS3)
OBJS    := $(call stripwhitespace,$(OBJS))

OBJDIRS := $(addprefix $(BUILDDIR)/,$(SRCDIRS))

CC_IS_GCC := $(shell expr `$(CC) --version | grep gcc | wc -l` != 0)
CC_IS_CLANG := $(shell expr `$(CC) --version | grep clang | wc -l` != 0)

all: debug

# gcc rules {{{
ifeq "$(CC_IS_GCC)" "1"
GCC_VERSION := $(shell expr `$(CC) -dumpversion | sed -e 's/\.\([0-9][0-9]\)/\1/g' -e 's/\.\([0-9]\)/0\1/g' -e 's/^[0-9]\{3,4\}$$/&00/'`)
GCXX_VERSION := $(shell expr `$(CXX) -dumpversion | sed -e 's/\.\([0-9][0-9]\)/\1/g' -e 's/\.\([0-9]\)/0\1/g' -e 's/^[0-9]\{3,4\}$$/&00/'`)
GCC_GTEQ_490 := $(shell expr $(GCC_VERSION) \>= 40900)
GCXX_GTEQ_490 := $(shell expr $(GCXX_VERSION) \>= 40900)
ifeq "$(GCC_GTEQ_490)" "1"
	CFLAGS   += -fdiagnostics-color=always
endif

ifeq "$(GCXX_GTEQ_490)" "1"
	CXXFLAGS += -fdiagnostics-color=always
endif

release: $(OBJS)
	$(LD) $(OBJS) $(LDFLAGS) $(DEBUG) -o $(BUILDDIR)/$(TARGET)
	$(STRIP) $(STRIPFLAGS) $(BUILDDIR)/$(TARGET)

debug: $(OBJS)
	$(LD) $(OBJS) $(LDFLAGS) $(DEBUG) -o $(BUILDDIR)/$(TARGET)

endif
# }}}

# clang rules {{{
ifeq "$(CC_IS_CLANG)" "1"
release: LDFLAGS += -Wl,-s

release: $(OBJS)
	$(LD) $(OBJS) $(LDFLAGS) -o $(BUILDDIR)/$(TARGET)

debug: $(OBJS)
	$(LD) $(OBJS) $(LDFLAGS) $(DEBUG) -o $(BUILDDIR)/$(TARGET)

endif
# }}}

# common rules {{{
$(OBJS): | $(OBJDIRS)

$(BUILDDIR)/%.c.o: %.c
	$(CC) $(CFLAGS) $(DEBUG) $< -c -o $@

$(BUILDDIR)/%.cc.o: %.cc
	$(CXX) $(CXXFLAGS) $(DEBUG) $< -c -o $@

$(BUILDDIR)/%.cpp.o: %.cpp
	$(CXX) $(CXXFLAGS) $(DEBUG) $< -c -o $@

clean:
	$(RM) -rfv $(BUILDDIR)

$(OBJDIRS):
	$(MKDIR) -pv $@
# }}}
