MAGIC = $(pkgdatadir)/magic
#lib_LTLIBRARIES = libmagic.la
noinst_LTLIBRARIES = libmagic.la
#include_HEADERS = magic.h
noinst_HEADERS = \
	file.h magic.h names.h patchlevel.h readelf.h tar.h \
	file_opts.h elfclass.h mygetopt.h cdf.h

#bin_PROGRAMS = file
noinst_PROGRAMS = file

AM_CPPFLAGS = -DMAGIC='"$(MAGIC)"'
AM_CFLAGS = @WARNINGS@

libmagic_la_SOURCES = magic.c apprentice.c softmagic.c ascmagic.c \
	encoding.c compress.c is_tar.c readelf.c print.c fsmagic.c \
	funcs.c apptype.c cdf.c cdf_time.c readcdf.c
libmagic_la_LDFLAGS = -no-undefined -version-info 1:0:0
libmagic_la_LIBADD = $(LTLIBOBJS)

file_SOURCES = file.c
file_LDADD = libmagic.la
