
extern zend_class_entry *sdl3ttf_sdlttf_sdlttf_ce;

ZEPHIR_INIT_CLASS(Sdl3ttf_SDLTTF_SDLTTF);

PHP_METHOD(Sdl3ttf_SDLTTF_SDLTTF, TTFInit);
PHP_METHOD(Sdl3ttf_SDLTTF_SDLTTF, TTFQuit);
PHP_METHOD(Sdl3ttf_SDLTTF_SDLTTF, TTFCloseFont);
PHP_METHOD(Sdl3ttf_SDLTTF_SDLTTF, TTFRenderTextBlended);
PHP_METHOD(Sdl3ttf_SDLTTF_SDLTTF, TTFOpenFont);

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_sdl3ttf_sdlttf_sdlttf_ttfinit, 0, 0, _IS_BOOL, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_sdl3ttf_sdlttf_sdlttf_ttfquit, 0, 0, IS_VOID, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_sdl3ttf_sdlttf_sdlttf_ttfclosefont, 0, 1, IS_VOID, 0)

	ZEND_ARG_TYPE_INFO(0, ptr, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_sdl3ttf_sdlttf_sdlttf_ttfrendertextblended, 0, 6, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, font, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, text, IS_STRING, 0)
	ZEND_ARG_TYPE_INFO(0, r, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, g, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, b, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, a, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, length, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_sdl3ttf_sdlttf_sdlttf_ttfopenfont, 0, 2, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, file, IS_STRING, 0)
	ZEND_ARG_TYPE_INFO(0, size, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEPHIR_INIT_FUNCS(sdl3ttf_sdlttf_sdlttf_method_entry) {
	PHP_ME(Sdl3ttf_SDLTTF_SDLTTF, TTFInit, arginfo_sdl3ttf_sdlttf_sdlttf_ttfinit, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	PHP_ME(Sdl3ttf_SDLTTF_SDLTTF, TTFQuit, arginfo_sdl3ttf_sdlttf_sdlttf_ttfquit, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	PHP_ME(Sdl3ttf_SDLTTF_SDLTTF, TTFCloseFont, arginfo_sdl3ttf_sdlttf_sdlttf_ttfclosefont, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	PHP_ME(Sdl3ttf_SDLTTF_SDLTTF, TTFRenderTextBlended, arginfo_sdl3ttf_sdlttf_sdlttf_ttfrendertextblended, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	PHP_ME(Sdl3ttf_SDLTTF_SDLTTF, TTFOpenFont, arginfo_sdl3ttf_sdlttf_sdlttf_ttfopenfont, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	PHP_FE_END
};
