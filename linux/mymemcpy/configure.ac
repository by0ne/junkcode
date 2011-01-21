#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.63])
AC_INIT([mymemcpy], [1.1], [https://bugzilla.redhat.com/show_bug.cgi?id=638477])
AC_CONFIG_SRCDIR([mymemcpy.c])
AC_CONFIG_HEADERS([config.h])
# Must come before AM_INIT_AUTOMAKE.
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([1.11.1 -Wall -Werror gnu])

# Checks for programs.
AC_PROG_CC
AC_DISABLE_STATIC
LT_INIT
LT_PREREQ([2.2.6])

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T

# Checks for library functions.

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
