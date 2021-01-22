# NetBSD bmake
V =
.if empty(V)
E = @echo
Q = @
.else
E = @\#
Q =
.endif

PROG= ${.CURDIR}/me

SRCS= ansi.c basic.c bind.c buffer.c crypt.c display.c eval.c exec.c \
      file.c fileio.c ibmpc.c input.c isearch.c line.c lock.c main.c \
      pklock.c posix.c random.c region.c search.c spawn.c tcap.c \
      termio.c vmsvt.c vt52.c window.c word.c names.c globals.c version.c \
      usage.c wrapper.c utf8.c util.c

OBJS= ${SRCS:T:N*.h:R:S/$/.o/}

_objdir = ${.CURDIR}/objs
.if !exists(${_objdir}/) 
_objdir_made != echo ${_objdir}/; mkdir -p ${_objdir}
.endif
_allsrcs= ${SRCS}
SRC_DIRS= ${_allsrcs:H:O:u:%=${.CURDIR}/%}
.OBJDIR: ${_objdir}
.PATH: ${SRC_DIRS}
.NOPATH: ${OBJS}

CC = gcc
RM = rm -f

CFLAGS = -Wall -Wstrict-prototypes -pipe -O2 -g
CFLAGS += -DAUTOCONF -DPOSIX -DUSG -D_DEFAULT_SOURCE -D_XOPEN_SOURCE=600 -D_GNU_SOURCE
LDFLAGS = -lncurses
BINDIR=/usr/local/bin

.PHONY: all install clean cleanall
all: ${PROG}

${PROG}: ${OBJS}
	${E} "  LINK    " ${@:T}
	${Q} ${CC} -o $@ $> ${LDFLAGS}

.c.o:
	${E} "  CC      " $@
	${Q} ${CC} ${CFLAGS} -o $@ -c $<

install:
	strip ${PROG}
	cp ${PROG} ${BINDIR}
	cp ${.CURDIR}/doc/emacs.hlp ${BINDIR}
	cp ${.CURDIR}/doc/uemacs.rc ${HOME}/.emacsrc

clean:
	${E} "  CLEAN"
	${Q} ${RM} ${PROG} ${OBJS}

# generated dependency files
_depsrcs=${SRCS:M*.c}
.if !empty(_depsrcs)
_depsrcs:=${_depsrcs:T:R:S/$/.d/}
cleanall:
	${E} "  CLEAN ALL"
	${Q} ${RM} -r ${PROG} ${_objdir}
.if defined(gendep)
CFLAGS_MD?=-MMD
CFLAGS_MF?=-MF ${.TARGET:T:R}.d -MT ${.TARGET:T:R}.o
CFLAGS+= ${CFLAGS_MD} ${CFLAGS_MF}
.endif
.for d in ${_depsrcs}
.dinclude "$d"
.endfor
.endif
