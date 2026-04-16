namespace Sdl3ttf\SDLTTF;

%{
#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>
#include <stdio.h>
}%

class SDLTTF
{
    public static function TTFInit() -> bool
    {
        bool result;

        %{
            result = TTF_Init();
        }%

        return result;
    }

    public static function TTFQuit() -> void
    {
        %{
            TTF_Quit();
        }%
    }

    public static function TTFCloseFont(int ptr) -> void
    {
        %{
            TTF_CloseFont((TTF_Font *)(uintptr_t) ptr);
        }%
    }

    public static function TTFRenderTextBlended(int font, string text, int r, int g, int b, int a, int length = 0) -> array
    {
        int ptr;
        int flags;
        int format;
        int w;
        int h;
        int pitch;
        int pixels_ptr;
        array pixels_data;
        int refcount;

        %{
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
        }%

        if ptr == 0 {
            return [];
        }

        return ["ptr": ptr, "flags": flags, "format": format, "w": w, "h": h, "pitch": pitch, "pixels": ["ptr": pixels_ptr, "data": pixels_data], "refcount": refcount];
    }

    public static function TTFOpenFont(string file, double size) -> array
    {
        int ptr;
        int ptsize;
        int style;
        int outline;
        int hinting;
        int height;
        int ascent;
        int descent;
        int line_skip;
        int fixed_width;

        %{
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
        }%

        if ptr == 0 {
            return [];
        }

        return [
            "ptr":         ptr,
            "size":        ptsize,
            "style":       style,
            "outline":     outline,
            "hinting":     hinting,
            "height":      height,
            "ascent":      ascent,
            "descent":     descent,
            "line_skip":   line_skip,
            "fixed_width": fixed_width
        ];
    }
}