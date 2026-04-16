<?php

namespace Sdl3ttf\SDLTTF;

class SDLTTF
{


    /**
     * @return bool
     */
    public static function TTFInit(): bool
    {
    }

    /**
     * @return void
     */
    public static function TTFQuit(): void
    {
    }

    /**
     * @param int $ptr
     * @return void
     */
    public static function TTFCloseFont(int $ptr): void
    {
    }

    /**
     * @param int $font
     * @param string $text
     * @param int $r
     * @param int $g
     * @param int $b
     * @param int $a
     * @param int $length
     * @return array
     */
    public static function TTFRenderTextBlended(int $font, string $text, int $r, int $g, int $b, int $a, int $length = 0): array
    {
    }

    /**
     * @param string $file
     * @param double $size
     * @return array
     */
    public static function TTFOpenFont(string $file, float $size): array
    {
    }
}
