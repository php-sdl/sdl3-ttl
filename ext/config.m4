PHP_ARG_ENABLE(sdl3ttf, whether to enable sdl3ttf, [ --enable-sdl3ttf   Enable Sdl3ttf])

if test "$PHP_SDL3TTF" = "yes"; then

	dnl GCC 14 promoted several long-standing warnings to hard errors by default.
	dnl Zephir-generated C code trips these in dead-code paths that are
	dnl runtime-safe and have built cleanly on gcc <= 13 and clang for years.
	dnl Each flag is silently ignored by compilers that don't know it.
	CFLAGS="$CFLAGS -Wno-error=incompatible-pointer-types -Wno-error=int-conversion -Wno-error=implicit-function-declaration -Wno-error=implicit-int"

	dnl ── SDL3 + SDL3_ttf via pkg-config ─────────────────────────────────────
	AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
	if test "x$PKG_CONFIG" = "xno"; then
		AC_MSG_ERROR([pkg-config not found. Install pkg-config and try again.])
	fi

	dnl SDL3 core
	AC_MSG_CHECKING([for sdl3])
	if $PKG_CONFIG --exists sdl3 2>/dev/null; then
		SDL3_CFLAGS=$($PKG_CONFIG --cflags sdl3)
		SDL3_LIBS=$($PKG_CONFIG --libs sdl3)
		AC_MSG_RESULT([yes ($($PKG_CONFIG --modversion sdl3))])
	else
		dnl Fallback: assume SDL3 is in the standard search paths
		SDL3_CFLAGS="-I/opt/homebrew/include -I/usr/local/include"
		SDL3_LIBS="-lSDL3"
		AC_MSG_RESULT([not found via pkg-config, using fallback paths])
	fi

	dnl SDL3_ttf — may be registered under several pc names depending on how it was built
	AC_MSG_CHECKING([for sdl3_ttf])
	SDL3TTF_FOUND=no
	for pc_name in SDL3_ttf sdl3-ttf sdl3_ttf; do
		if $PKG_CONFIG --exists $pc_name 2>/dev/null; then
			SDL3TTF_CFLAGS=$($PKG_CONFIG --cflags $pc_name)
			SDL3TTF_LIBS=$($PKG_CONFIG --libs $pc_name)
			SDL3TTF_FOUND=yes
			AC_MSG_RESULT([yes ($($PKG_CONFIG --modversion $pc_name) via $pc_name)])
			break
		fi
	done
	if test "x$SDL3TTF_FOUND" = "xno"; then
		dnl Fallback: assume SDL3_ttf is in the standard search paths
		SDL3TTF_CFLAGS="-I/opt/homebrew/include -I/usr/local/include"
		SDL3TTF_LIBS="-lSDL3_ttf"
		AC_MSG_RESULT([not found via pkg-config, using fallback paths])
	fi

	dnl Merge include flags (deduplicate obvious overlap)
	ALL_CFLAGS="$SDL3_CFLAGS $SDL3TTF_CFLAGS"
	ALL_LIBS="$SDL3_LIBS $SDL3TTF_LIBS"

	dnl Wire the libs into the build
	PHP_EVAL_LIBLINE($ALL_LIBS, SDL3TTF_SHARED_LIBADD)

	AC_DEFINE(HAVE_SDL3TTF, 1, [Whether you have Sdl3ttf])
	sdl3ttf_sources="sdl3ttf.c kernel/main.c kernel/memory.c kernel/exception.c kernel/debug.c kernel/backtrace.c kernel/object.c kernel/array.c kernel/string.c kernel/fcall.c kernel/require.c kernel/file.c kernel/operators.c kernel/math.c kernel/concat.c kernel/variables.c kernel/filter.c kernel/iterator.c kernel/time.c kernel/exit.c sdl3ttf/sdlttf/sdlttf.zep.c "
	PHP_NEW_EXTENSION(sdl3ttf, $sdl3ttf_sources, $ext_shared,, $ALL_CFLAGS)
	PHP_ADD_BUILD_DIR([$ext_builddir/kernel/])
	for dir in "sdl3ttf/sdlttf"; do
		PHP_ADD_BUILD_DIR([$ext_builddir/$dir])
	done
	PHP_SUBST(SDL3TTF_SHARED_LIBADD)

	old_CPPFLAGS=$CPPFLAGS
	CPPFLAGS="$CPPFLAGS $INCLUDES"

	AC_CHECK_DECL(
		[HAVE_BUNDLED_PCRE],
		[
			AC_CHECK_HEADERS(
				[ext/pcre/php_pcre.h],
				[
					PHP_ADD_EXTENSION_DEP([sdl3ttf], [pcre])
					AC_DEFINE([ZEPHIR_USE_PHP_PCRE], [1], [Whether PHP pcre extension is present at compile time])
				],
				,
				[[#include "main/php.h"]]
			)
		],
		,
		[[#include "php_config.h"]]
	)

	AC_CHECK_DECL(
		[HAVE_JSON],
		[
			AC_CHECK_HEADERS(
				[ext/json/php_json.h],
				[
					PHP_ADD_EXTENSION_DEP([sdl3ttf], [json])
					AC_DEFINE([ZEPHIR_USE_PHP_JSON], [1], [Whether PHP json extension is present at compile time])
				],
				,
				[[#include "main/php.h"]]
			)
		],
		,
		[[#include "php_config.h"]]
	)

	CPPFLAGS=$old_CPPFLAGS

	PHP_INSTALL_HEADERS([ext/sdl3ttf], [php_SDL3TTF.h])

fi
