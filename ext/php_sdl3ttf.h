
/* This file was generated automatically by Zephir do not modify it! */

#ifndef PHP_SDL3TTF_H
#define PHP_SDL3TTF_H 1

#ifdef PHP_WIN32
#define ZEPHIR_RELEASE 1
#endif

#include "kernel/globals.h"

#define PHP_SDL3TTF_NAME        "sdl3ttf"
#define PHP_SDL3TTF_VERSION     "0.1.0"
#define PHP_SDL3TTF_EXTNAME     "sdl3ttf"
#define PHP_SDL3TTF_AUTHOR      "Project Saturn Studios, LLC"
#define PHP_SDL3TTF_ZEPVERSION  "0.19.0-$Id$"
#define PHP_SDL3TTF_DESCRIPTION "PHP extension for SDL3_ttf ? TrueType font rendering via SDL3"



ZEND_BEGIN_MODULE_GLOBALS(sdl3ttf)

	int initialized;

	/** Function cache */
	HashTable *fcache;

	zephir_fcall_cache_entry *scache[ZEPHIR_MAX_CACHE_SLOTS];

	/* Cache enabled */
	unsigned int cache_enabled;

	/* Max recursion control */
	unsigned int recursive_lock;

	
ZEND_END_MODULE_GLOBALS(sdl3ttf)

#ifdef ZTS
#include "TSRM.h"
#endif

ZEND_EXTERN_MODULE_GLOBALS(sdl3ttf)

#ifdef ZTS
	#define ZEPHIR_GLOBAL(v) ZEND_MODULE_GLOBALS_ACCESSOR(sdl3ttf, v)
#else
	#define ZEPHIR_GLOBAL(v) (sdl3ttf_globals.v)
#endif

#ifdef ZTS
	ZEND_TSRMLS_CACHE_EXTERN()
	#define ZEPHIR_VGLOBAL ((zend_sdl3ttf_globals *) (*((void ***) tsrm_get_ls_cache()))[TSRM_UNSHUFFLE_RSRC_ID(sdl3ttf_globals_id)])
#else
	#define ZEPHIR_VGLOBAL &(sdl3ttf_globals)
#endif

#define ZEPHIR_API ZEND_API

#define zephir_globals_def sdl3ttf_globals
#define zend_zephir_globals_def zend_sdl3ttf_globals

extern zend_module_entry sdl3ttf_module_entry;
#define phpext_sdl3ttf_ptr &sdl3ttf_module_entry

#endif
