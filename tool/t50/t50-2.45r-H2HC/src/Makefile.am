# Process this file with automake to produce Makefile.in
# Makefile for src/t50.

AM_CPPFLAGS = -I. -I$(srcdir)/include 
AM_CFLAGS = $(T50_CFLAGS)
AM_LDFLAGS = $(T50_LDFLAGS)

################################
## GLOBAL DEFINE FLAGS
################################
##
## Global define flags used by GCC.
## Any new define flag should be added in this section.
#
# Setting DEBUG.
#DFLAGS          = -D__HAVE_DEBUG__
#
# Setting USAGE.
DFLAGS         = -D__HAVE_USAGE__
#
# Setting THE REAL T50 POWER.
DFLAGS         += -D__HAVE_T50__
#
# Setting TURBO.
DFLAGS         += -D__HAVE_TURBO__
#
# Setting RESTRICTION ( __HAVE_RESTRICTION__ = __HAVE_LIMITATION__ + __HAVE_EXPIRATION__).
#DFLAGS         += -D__HAVE_RESTRICTION__
#
# Setting RFC 1918 LIMITATION.
DFLAGS         += -D__HAVE_LIMITATION__
#
# Setting EXPIRATION date.
#DFLAGS         += -D__HAVE_EXPIRATION__
#DFLAGS         += -DEXPIRATION_FIRST_DAY=1
#DFLAGS         += -DEXPIRATION_LAST_DAY=30
#DFLAGS         += -DEXPIRATION_MONTH=11
#DFLAGS         += -DEXPIRATION_YEAR=2010
#
# Setting VERSION.
DFLAGS         += -DMAJOR_VERSION=\"$(MAJOR_VERSION)\"
DFLAGS         += -DMINOR_VERSION=\"$(MINOR_VERSION)\"
DFLAGS         += -DBUILD_VERSION=\"$(BUILD_VERSION)\"
DFLAGS         += -DBUILD_PLATFORM=\"$(BUILD_PLATFORM)\"
#
# Setting USER and FQDN.
DFLAGS         += -DREGISTERED_USER=\"$(REGISTERED_USER)\"
DFLAGS         += -DREGISTERED_FQDN=\"$(REGISTERED_FQDN)\"
#

bin_PROGRAMS = t50
t50_SOURCES = check.c  cksum.c  config.c  \
                icmp.c  igmp.c  resolv.c    \
                sock.c  t50.c  tcp.c  udp.c  usage.c \
                include/common.h
t50_CPPFLAGS = $(DFLAGS) $(AM_CPPFLAGS)
t50_CFLAGS =  $(AM_CFLAGS)
t50_LDFLAGS = $(AM_LDFLAGS)
