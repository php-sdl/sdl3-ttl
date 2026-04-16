
#ifdef HAVE_CONFIG_H
#include "../../ext_config.h"
#endif

#include <php.h>
#include "../../php_ext.h"
#include "../../ext.h"

#include <Zend/zend_operators.h>
#include <Zend/zend_exceptions.h>
#include <Zend/zend_interfaces.h>

#include "kernel/main.h"
#include "kernel/object.h"
#include "kernel/operators.h"
#include "kernel/memory.h"
#include "kernel/array.h"

#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>
#include <stdio.h>



ZEPHIR_INIT_CLASS(Sdl3ttf_SDLTTF_SDLTTF)
{
	ZEPHIR_REGISTER_CLASS(Sdl3ttf\\SDLTTF, SDLTTF, sdl3ttf, sdlttf_sdlttf, sdl3ttf_sdlttf_sdlttf_method_entry, 0);

	return SUCCESS;
}

PHP_METHOD(Sdl3ttf_SDLTTF_SDLTTF, TTFInit)
{
	zend_bool result = 0;
	
            result = TTF_Init();
        
	RETURN_BOOL(result);
}

PHP_METHOD(Sdl3ttf_SDLTTF_SDLTTF, TTFQuit)
{

	
            TTF_Quit();
        
}

PHP_METHOD(Sdl3ttf_SDLTTF_SDLTTF, TTFCloseFont)
{
	zval *ptr_param = NULL;
	zend_long ptr;

	ZEND_PARSE_PARAMETERS_START(1, 1)
		Z_PARAM_LONG(ptr)
	ZEND_PARSE_PARAMETERS_END();
	zephir_fetch_params_without_memory_grow(1, 0, &ptr_param);
	
            TTF_CloseFont((TTF_Font *)(uintptr_t) ptr);
        
}

PHP_METHOD(Sdl3ttf_SDLTTF_SDLTTF, TTFRenderTextBlended)
{
	zval pixels_data, _1;
	zephir_method_globals *ZEPHIR_METHOD_GLOBALS_PTR = NULL;
	zval text;
	zval *font_param = NULL, *text_param = NULL, *r_param = NULL, *g_param = NULL, *b_param = NULL, *a_param = NULL, *length_param = NULL, _0;
	zend_long font, r, g, b, a, length, ptr = 0, flags = 0, format = 0, w = 0, h = 0, pitch = 0, pixels_ptr = 0, refcount = 0;

	ZVAL_UNDEF(&_0);
	ZVAL_UNDEF(&text);
	ZVAL_UNDEF(&pixels_data);
	ZVAL_UNDEF(&_1);
	ZEND_PARSE_PARAMETERS_START(6, 7)
		Z_PARAM_LONG(font)
		Z_PARAM_STR(text)
		Z_PARAM_LONG(r)
		Z_PARAM_LONG(g)
		Z_PARAM_LONG(b)
		Z_PARAM_LONG(a)
		Z_PARAM_OPTIONAL
		Z_PARAM_LONG(length)
	ZEND_PARSE_PARAMETERS_END();
	ZEPHIR_METHOD_GLOBALS_PTR = pecalloc(1, sizeof(zephir_method_globals), 0);
	zephir_memory_grow_stack(ZEPHIR_METHOD_GLOBALS_PTR, __func__);
	zephir_fetch_params(1, 6, 1, &font_param, &text_param, &r_param, &g_param, &b_param, &a_param, &length_param);
	zephir_get_strval(&text, text_param);
	if (!length_param) {
		length = 0;
	} else {
		}
	
            TTF_Font    *f       = (TTF_Font *)(uintptr_t) font;
            SDL_Color    fg      = { (Uint8)r, (Uint8)g, (Uint8)b, (Uint8)a };
            SDL_Surface *surface = TTF_RenderText_Blended(f, Z_STRVAL(text), (size_t)length, fg);

            if (!surface) {
                ptr = 0; flags = 0; format = 0; w = 0; h = 0; pitch = 0; refcount = 0;
            } else {
                ptr      = (zend_long)(uintptr_t) surface;
                flags    = (zend_long) surface->flags;
                format   = (zend_long) surface->format;
                w        = (zend_long) surface->w;
                h        = (zend_long) surface->h;
                pitch    = (zend_long) surface->pitch;
                pixels_ptr = surface->pixels ? (zend_long)(uintptr_t) surface->pixels : 0;
                refcount = (zend_long) surface->refcount;
                array_init(&pixels_data);
                if (surface->pixels) {
                    for (int py = 0; py < surface->h; py++) {
                        Uint32 *row = (Uint32 *)(((Uint8 *)surface->pixels) + py * surface->pitch);
                        for (int px = 0; px < surface->w; px++) {
                            add_next_index_long(&pixels_data, (zend_long)(zend_ulong)row[px]);
                        }
                    }
                }
            }
        
	if (ptr == 0) {
		array_init(return_value);
		RETURN_MM();
	}
	zephir_create_array(return_value, 8, 0);
	ZEPHIR_INIT_VAR(&_0);
	ZVAL_LONG(&_0, ptr);
	zephir_array_update_string(return_value, SL("ptr"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, flags);
	zephir_array_update_string(return_value, SL("flags"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, format);
	zephir_array_update_string(return_value, SL("format"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, w);
	zephir_array_update_string(return_value, SL("w"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, h);
	zephir_array_update_string(return_value, SL("h"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, pitch);
	zephir_array_update_string(return_value, SL("pitch"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_VAR(&_1);
	zephir_create_array(&_1, 2, 0);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, pixels_ptr);
	zephir_array_update_string(&_1, SL("ptr"), &_0, PH_COPY | PH_SEPARATE);
	zephir_array_update_string(&_1, SL("data"), &pixels_data, PH_COPY | PH_SEPARATE);
	zephir_array_update_string(return_value, SL("pixels"), &_1, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, refcount);
	zephir_array_update_string(return_value, SL("refcount"), &_0, PH_COPY | PH_SEPARATE);
	RETURN_MM();
}

PHP_METHOD(Sdl3ttf_SDLTTF_SDLTTF, TTFOpenFont)
{
	zend_long ptr = 0, ptsize = 0, style = 0, outline = 0, hinting = 0, height = 0, ascent = 0, descent = 0, line_skip = 0, fixed_width = 0;
	zephir_method_globals *ZEPHIR_METHOD_GLOBALS_PTR = NULL;
	double size;
	zval *file_param = NULL, *size_param = NULL, _0;
	zval file;

	ZVAL_UNDEF(&file);
	ZVAL_UNDEF(&_0);
	ZEND_PARSE_PARAMETERS_START(2, 2)
		Z_PARAM_STR(file)
		Z_PARAM_ZVAL(size)
	ZEND_PARSE_PARAMETERS_END();
	ZEPHIR_METHOD_GLOBALS_PTR = pecalloc(1, sizeof(zephir_method_globals), 0);
	zephir_memory_grow_stack(ZEPHIR_METHOD_GLOBALS_PTR, __func__);
	zephir_fetch_params(1, 2, 0, &file_param, &size_param);
	zephir_get_strval(&file, file_param);
	size = zephir_get_doubleval(size_param);
	
            TTF_Font *font = TTF_OpenFont(Z_STRVAL(file), (float) size);

            if (!font) {
                ptr = 0; ptsize = 0; style = 0; outline = 0; hinting = 0;
                height = 0; ascent = 0; descent = 0; line_skip = 0; fixed_width = 0;
            } else {
                ptr         = (zend_long)(uintptr_t) font;
                ptsize      = (zend_long) TTF_GetFontSize(font);
                style       = (zend_long) TTF_GetFontStyle(font);
                outline     = (zend_long) TTF_GetFontOutline(font);
                hinting     = (zend_long) TTF_GetFontHinting(font);
                height      = (zend_long) TTF_GetFontHeight(font);
                ascent      = (zend_long) TTF_GetFontAscent(font);
                descent     = (zend_long) TTF_GetFontDescent(font);
                line_skip   = (zend_long) TTF_GetFontLineSkip(font);
                fixed_width = (zend_long) TTF_FontIsFixedWidth(font);
            }
        
	if (ptr == 0) {
		array_init(return_value);
		RETURN_MM();
	}
	zephir_create_array(return_value, 10, 0);
	ZEPHIR_INIT_VAR(&_0);
	ZVAL_LONG(&_0, ptr);
	zephir_array_update_string(return_value, SL("ptr"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, ptsize);
	zephir_array_update_string(return_value, SL("size"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, style);
	zephir_array_update_string(return_value, SL("style"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, outline);
	zephir_array_update_string(return_value, SL("outline"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, hinting);
	zephir_array_update_string(return_value, SL("hinting"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, height);
	zephir_array_update_string(return_value, SL("height"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, ascent);
	zephir_array_update_string(return_value, SL("ascent"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, descent);
	zephir_array_update_string(return_value, SL("descent"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, line_skip);
	zephir_array_update_string(return_value, SL("line_skip"), &_0, PH_COPY | PH_SEPARATE);
	ZEPHIR_INIT_NVAR(&_0);
	ZVAL_LONG(&_0, fixed_width);
	zephir_array_update_string(return_value, SL("fixed_width"), &_0, PH_COPY | PH_SEPARATE);
	RETURN_MM();
}

