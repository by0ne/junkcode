#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.63])
AC_INIT([T50], [2.45], [nbrito@sekure.org>])
AC_CONFIG_SRCDIR([src/t50.c])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

# Must come before AM_INIT_AUTOMAKE.
AC_CONFIG_AUX_DIR([build-aux])
AC_CANONICAL_HOST
AM_INIT_AUTOMAKE([1.11 color-tests -Wall -Werror foreign])

# Checks for programs.
# Set common system defines for POSIX extensions, such as GNU_SOURCE
# Must be called before any macros that run the compiler (like AC-PROG-LIBTOOL)
AC_USE_SYSTEM_EXTENSIONS
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AC_PROG_LIBTOOL
# gcc CFLAGS
# Setting warning messages., [T50_CFLAGS])
 t50_CFLAGS_ADD([-Wall], [T50_CFLAGS])
 t50_CFLAGS_ADD([-Wextra], [T50_CFLAGS])
 t50_CFLAGS_ADD([-Werror], [T50_CFLAGS])
 t50_CFLAGS_ADD([-Wformat], [T50_CFLAGS])
 t50_CFLAGS_ADD([-Wformat-nonliteral], [T50_CFLAGS])
 t50_CFLAGS_ADD([-Wformat-security], [T50_CFLAGS])
 t50_CFLAGS_ADD([-Wformat-y2k], [T50_CFLAGS])
 t50_CFLAGS_ADD([-Wimplicit], [T50_CFLAGS])
 t50_CFLAGS_ADD([-Winline], [T50_CFLAGS])
 t50_CFLAGS_ADD([-Waddress], [T50_CFLAGS])
 t50_CFLAGS_ADD([-Warray-bounds], [T50_CFLAGS])
#
# Tuning parameters to better optimization.
 t50_CFLAGS_ADD([-O3], [T50_CFLAGS])
 t50_CFLAGS_ADD([-ftoplevel-reorder], [T50_CFLAGS])
 t50_CFLAGS_ADD([-funroll-loops], [T50_CFLAGS])
 t50_CFLAGS_ADD([-funroll-all-loops], [T50_CFLAGS])
 t50_CFLAGS_ADD([-fomit-frame-pointer], [T50_CFLAGS])
 t50_CFLAGS_ADD([-fkeep-inline-functions], [T50_CFLAGS])
 t50_CFLAGS_ADD([-ftree-loop-optimize], [T50_CFLAGS])
 t50_CFLAGS_ADD([-fbranch-target-load-optimize], [T50_CFLAGS])
 t50_CFLAGS_ADD([-foptimize-register-move], [T50_CFLAGS])
 t50_CFLAGS_ADD([-msahf], [T50_CFLAGS])

# 
AS_IF([test "x$build_cpu" = xx86_64],
  [ 
 t50_CFLAGS_ADD([-ffast-math], [T50_CFLAGS])
 t50_CFLAGS_ADD([-fstack-protector-all], [T50_CFLAGS])
 # hmm. Dont't work
 m4_define([ELF_BUILD_CPU], [ -m elf_$build_cpu])
 t50_LDFLAGS_ADD([ELF_BUILD_CPU], [T50_LDFLAGS])
  ])



# build t50 with mudflap instrumentation (GCC only)
t50_gcc_mudflap=no
AC_ARG_ENABLE([mudflap],
 [AS_HELP_STRING([--enable-mudflap],
                  [build T50 with mudflap instrumentation (@<:@default=no@:>@) (with GCC only) (EXPERIMENTAL)])],
 [case $enableval in
     yes|no) ;;
     *)      AC_MSG_ERROR([bad value $enableval for mudflap option]) ;;
   esac
   t50_gcc_mudflap=$enableval],
[ t50_gcc_mudflap=no ])

AS_IF([ test x"$t50_gcc_mudflap" = x"yes" ], 
      [
        AS_IF([test "x$GCC" != x],
              [ 
		old_CFLAGS="$CFLAGS"
		CFLAGS="$CFLAGS -fmudflap"
		old_LDFLAGS="$LDFLAGS"
		LDFLAGS="$LDFLAGS -lmudflap"
		AC_LINK_IFELSE([AC_LANG_PROGRAM([[]], [[]])],[t50_gcc_mudflap=yes],[t50_gcc_mudflap=fail])
		CFLAGS="$old_CFLAGS"
		LDFLAGS="$old_LDFLAGS"
		AS_IF([ test "$t50_gcc_mudflap" = fail ],
                      [
 	  	       AC_MSG_WARN([--enable-mudflap requires a compiler which understands this option.])
                      ],
                      [
                        t50_CFLAGS_ADD([-fmudflap], [T50_CFLAGS])
                	t50_LDFLAGS_ADD([-lmudflap], [T50_LDFLAGS])
                        # XXX: memory leak ?
                        #MUDFLAP_OPTIONS="-mode-check -abbreviate -viol-abort -check-initialization -print-leaks"
                        MUDFLAP_OPTIONS="-mode-check -abbreviate -check-initialization"
			AC_SUBST([MUDFLAP_OPTIONS])
                      ])
              ],
              [ AC_MSG_WARN([--enable-mudflap requires GCC])]
        )
      ])
     

AC_SUBST([T50_LDFLAGS])

# build t50 instrumented for extra optimization/security (GCC only)
# -fno-delete-null-pointer as the kernel does http://patchwork.kernel.org/patch/36060/
# GNU GCC (usually "gcc")
AS_IF([test "x$GCC" != x],
 [ for c in -fno-delete-null-pointer-checks -D_FORTIFY_SOURCE=2 -fstack-protector -fexceptions
   do
  	t50_CFLAGS_ADD([$c], [T50_CFLAGS])
   done
 ])
# Finally put an AC_SUBST for all the CFLAGS above
AC_SUBST([T50_CFLAGS])


# Checks for libraries.
# FIXME: Replace `main' with a function in `-lmpi':
# FIXME: T50 not seems to use mpi
# AC_CHECK_LIB([mpi], [main])

# Checks for header files.
AC_CHECK_HEADERS([fcntl.h netdb.h stdlib.h string.h sys/ioctl.h sys/socket.h sys/time.h unistd.h],[:],[AC_MSG_ERROR([Sorry. You don'have the prerequisite header files])])

AC_CHECK_HEADERS([ getopt.h sys/select.h sys/resource.h linux/ip.h linux/tcp.h linux/udp.h linux/icmp.h linux/igmp.h],[:],[AC_MSG_ERROR([Sorry. You don'have the prerequisite header files])])


# Checks for typedefs, structures, and compiler characteristics.
AC_C_INLINE
AC_TYPE_INT16_T
AC_TYPE_INT32_T
AC_TYPE_INT8_T
AC_TYPE_PID_T

# Checks for library functions.
AC_CHECK_FUNCS([gethostbyname fork gettimeofday memchr socket strchr])

# Create man pages if not "cross-compiling" 

if test $cross_compiling = no; then
  AM_MISSING_PROG(HELP2MAN, help2man)
else
  HELP2MAN=:
fi

AC_CONFIG_FILES([Makefile 
                 src/Makefile
                 man/Makefile])
AC_OUTPUT
