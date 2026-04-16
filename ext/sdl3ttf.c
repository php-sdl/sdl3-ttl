
/* This file was generated automatically by Zephir do not modify it! */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <php.h>

#include "php_ext.h"
#include "sdl3ttf.h"

#include <ext/standard/info.h>

#include <Zend/zend_operators.h>
#include <Zend/zend_exceptions.h>
#include <Zend/zend_interfaces.h>

#include "kernel/globals.h"
#include "kernel/main.h"
#include "kernel/fcall.h"
#include "kernel/memory.h"



zend_class_entry *sdl3ttf_sdlttf_sdlttf_ce;

ZEND_DECLARE_MODULE_GLOBALS(sdl3ttf)

PHP_INI_BEGIN()
	
PHP_INI_END()

static PHP_MINIT_FUNCTION(sdl3ttf)
{
	REGISTER_INI_ENTRIES();
	zephir_module_init();
	ZEPHIR_INIT(Sdl3ttf_SDLTTF_SDLTTF);
	
	return SUCCESS;
}

#ifndef ZEPHIR_RELEASE
static PHP_MSHUTDOWN_FUNCTION(sdl3ttf)
{
	
	zephir_deinitialize_memory();
	UNREGISTER_INI_ENTRIES();
	return SUCCESS;
}
#endif

/**
 * Initialize globals on each request or each thread started
 */
static void php_zephir_init_globals(zend_sdl3ttf_globals *sdl3ttf_globals)
{
	sdl3ttf_globals->initialized = 0;

	/* Cache Enabled */
	sdl3ttf_globals->cache_enabled = 1;

	/* Recursive Lock */
	sdl3ttf_globals->recursive_lock = 0;

	/* Static cache */
	memset(sdl3ttf_globals->scache, '\0', sizeof(zephir_fcall_cache_entry*) * ZEPHIR_MAX_CACHE_SLOTS);

	
	
}

/**
 * Initialize globals only on each thread started
 */
static void php_zephir_init_module_globals(zend_sdl3ttf_globals *sdl3ttf_globals)
{
	
}

static PHP_RINIT_FUNCTION(sdl3ttf)
{
	zend_sdl3ttf_globals *sdl3ttf_globals_ptr;
	sdl3ttf_globals_ptr = ZEPHIR_VGLOBAL;

	php_zephir_init_globals(sdl3ttf_globals_ptr);
	zephir_initialize_memory(sdl3ttf_globals_ptr);

	
	return SUCCESS;
}

static PHP_RSHUTDOWN_FUNCTION(sdl3ttf)
{
	
	zephir_deinitialize_memory();
	return SUCCESS;
}



static PHP_MINFO_FUNCTION(sdl3ttf)
{
	php_info_print_box_start(0);
	php_printf("%s", PHP_SDL3TTF_DESCRIPTION);
	php_info_print_box_end();

	php_info_print_table_start();
	php_info_print_table_header(2, PHP_SDL3TTF_NAME, "enabled");
	php_info_print_table_row(2, "Author", PHP_SDL3TTF_AUTHOR);
	php_info_print_table_row(2, "Version", PHP_SDL3TTF_VERSION);
	php_info_print_table_row(2, "Build Date", __DATE__ " " __TIME__ );
	php_info_print_table_row(2, "Powered by Zephir", "Version " PHP_SDL3TTF_ZEPVERSION);
	php_info_print_table_end();
	
	DISPLAY_INI_ENTRIES();
}

static PHP_GINIT_FUNCTION(sdl3ttf)
{
#if defined(COMPILE_DL_SDL3TTF) && defined(ZTS)
	ZEND_TSRMLS_CACHE_UPDATE();
#endif

	php_zephir_init_globals(sdl3ttf_globals);
	php_zephir_init_module_globals(sdl3ttf_globals);
}

static PHP_GSHUTDOWN_FUNCTION(sdl3ttf)
{
	
}


zend_function_entry php_sdl3ttf_functions[] = {
	ZEND_FE_END

};

static const zend_module_dep php_sdl3ttf_deps[] = {
	
	ZEND_MOD_END
};

zend_module_entry sdl3ttf_module_entry = {
	STANDARD_MODULE_HEADER_EX,
	NULL,
	php_sdl3ttf_deps,
	PHP_SDL3TTF_EXTNAME,
	php_sdl3ttf_functions,
	PHP_MINIT(sdl3ttf),
#ifndef ZEPHIR_RELEASE
	PHP_MSHUTDOWN(sdl3ttf),
#else
	NULL,
#endif
	PHP_RINIT(sdl3ttf),
	PHP_RSHUTDOWN(sdl3ttf),
	PHP_MINFO(sdl3ttf),
	PHP_SDL3TTF_VERSION,
	ZEND_MODULE_GLOBALS(sdl3ttf),
	PHP_GINIT(sdl3ttf),
	PHP_GSHUTDOWN(sdl3ttf),
#ifdef ZEPHIR_POST_REQUEST
	PHP_PRSHUTDOWN(sdl3ttf),
#else
	NULL,
#endif
	STANDARD_MODULE_PROPERTIES_EX
};

/* implement standard "stub" routine to introduce ourselves to Zend */
#ifdef COMPILE_DL_SDL3TTF
# ifdef ZTS
ZEND_TSRMLS_CACHE_DEFINE()
# endif
ZEND_GET_MODULE(sdl3ttf)
#endif
