# php-sdl3-ttf

[![CI](https://github.com/php-sdl/sdl3-ttl/actions/workflows/ci.yml/badge.svg)](https://github.com/php-sdl/sdl3-ttl/actions/workflows/ci.yml)
[![PHP](https://img.shields.io/badge/php-%E2%89%A5%208.2-777bb4?logo=php&logoColor=white)](https://www.php.net)
[![SDL3](https://img.shields.io/badge/SDL3-%E2%89%A5%203.4.0-1d4ed8)](https://www.libsdl.org/)
[![SDL3_ttf](https://img.shields.io/badge/SDL3__ttf-%E2%89%A5%203.2-1d4ed8)](https://github.com/libsdl-org/SDL_ttf)
[![Built with Zephir](https://img.shields.io/badge/built%20with-Zephir-ff6a00)](https://zephir-lang.com/)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macOS-lightgrey)](#requirements)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](#license)

> PHP extension for SDL3_ttf — TrueType font rendering built with [Zephir](https://zephir-lang.com/).

`sdl3ttf` wraps [SDL3_ttf](https://github.com/libsdl-org/SDL_ttf) for
PHP 8.2+, giving you hardware-quality TrueType and OpenType font rendering
from plain PHP scripts. It links against the system `libSDL3` and
`libSDL3_ttf`, so glyph rasterisation is as fast as a native C program.

Pair it with [php-sdl/sdl3](https://github.com/php-sdl/sdl3) for windowing,
rendering, and event handling — both extensions share the `Sdl3*` top-level
namespace and can be loaded side-by-side.

---

## Table of contents

- [Requirements](#requirements)
- [Installation](#installation)
  - [Via PHP PIE (recommended)](#via-php-pie-recommended)
  - [Platform installers](#platform-installers)
  - [Manual build with `phpize`](#manual-build-with-phpize)
- [Verifying the install](#verifying-the-install)
- [Quick start](#quick-start)
- [API reference](#api-reference)
- [License](#license)

---

## Requirements

| Component            | Minimum version | Notes                                                                                            |
| -------------------- | --------------- | ------------------------------------------------------------------------------------------------ |
| PHP                  | 8.2             | ZTS and NTS builds both supported.                                                               |
| [php-sdl/sdl3]       | any             | **Required.** Provides the SDL3 window, renderer, and surface types this extension works with.   |
| SDL3                 | 3.4.0           | C library — must be discoverable via `pkg-config sdl3`.                                          |
| SDL3_ttf             | 3.2             | C library — must be discoverable via `pkg-config SDL3_ttf` (or `sdl3-ttf` / `sdl3_ttf`).        |
| OS                   | Linux / macOS   | Windows is not currently supported.                                                              |
| Compiler             | C11 toolchain   | `gcc`, `clang`, or Apple Clang.                                                                  |
| `php-dev` / `phpize` | matches PHP     | Required for any build path.                                                                     |

[php-sdl/sdl3]: https://github.com/php-sdl/sdl3

Tested on macOS (Apple Silicon + Intel), Debian Trixie, Raspberry Pi OS
(arm64 / armhf), and NVIDIA JetPack 6 (Jetson Orin).

---

## Installation

### Via PHP PIE (recommended)

Install [php-sdl/sdl3](https://github.com/php-sdl/sdl3) first (required), then install this extension:

```bash
pie install php-sdl/sdl3
pie install php-sdl/sdl3-ttf
```

PIE handles the full build pipeline (phpize → configure → make → install) automatically. Make sure SDL3 ≥ 3.4.0 and SDL3_ttf ≥ 3.2 are already installed on the system before running — use the platform scripts below if they are not.

### Platform installers

Three installer scripts live at the repository root. Each one installs SDL3
and SDL3_ttf if they are missing, builds the extension with Zephir, and
enables it for every detected PHP SAPI.

**macOS** (Homebrew):

```bash
bash install-macos.sh
```

**Debian Trixie / Raspberry Pi OS** (amd64, arm64, armhf):

```bash
bash install-debian-trixie.sh
```

**JetPack 6 / Ubuntu 22.04** (builds SDL3 + SDL3_ttf from source):

```bash
bash install-jetpack6.sh
```

Each script writes a full build log to `./build.log` and prints concise
failure diagnostics if anything goes wrong.

### Manual build with `phpize`

If the generated C source exists in `ext/`, you can build without Zephir:

```bash
cd ext
phpize
./configure --enable-sdl3ttf
make -j"$(nproc 2>/dev/null || sysctl -n hw.logicalcpu)"
sudo make install
```

Then enable the extension:

```ini
; /etc/php/8.4/cli/conf.d/30-sdl3ttf.ini
extension=sdl3ttf.so
```

If SDL3 or SDL3_ttf is installed in a non-standard prefix, export
`PKG_CONFIG_PATH=/usr/local/lib/pkgconfig` before `./configure`.

---

## Verifying the install

Run the bundled proof-of-work script — it opens a system font, renders text
to a surface, and reports dimensions. No display server required.

```bash
php examples/proof_of_work.php
```

Expected output:

```
✓  Extension 'sdl3ttf' is loaded
✓  Font: /System/Library/Fonts/Supplemental/Arial.ttf
✓  TTF_Init() → ok
✓  TTFOpenFont() → ptr=0x…
     height=27  ascent=22  descent=-5  line_skip=28  fixed=no
✓  TTFRenderTextBlended()
     surface ptr=0x…  size=263x27  pitch=1104
     pixels in data array: 7101  (expected 7101)
✓  Pixel data matches surface dimensions
     mid-row preview: [ ███ ░ ██░   ░  ░░ █  …  ]
✓  TTFCloseFont()
✓  TTFQuit()

✅  All checks passed — sdl3ttf is working correctly.
```

A one-liner sanity check:

```bash
php -m | grep sdl3ttf
```

---

## Quick start

```php
<?php

use Sdl3ttf\SDLTTF\SDLTTF;

// Initialise SDL3_ttf
SDLTTF::TTFInit();

// Open a font at 32pt
$font = SDLTTF::TTFOpenFont('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 32.0);
printf("Font height: %d  ascent: %d  descent: %d\n",
    $font['height'], $font['ascent'], $font['descent']);

// Render white text to an SDL_Surface
$surface = SDLTTF::TTFRenderTextBlended(
    $font['ptr'],       // font pointer
    'Hello, SDL3_ttf!', // text
    255, 255, 255, 255  // RGBA
);
printf("Rendered surface: %dx%d (%d pixels)\n",
    $surface['w'], $surface['h'],
    count($surface['pixels']['data'])
);

// Clean up
SDLTTF::TTFCloseFont($font['ptr']);
SDLTTF::TTFQuit();
```

To draw the rendered surface on screen, pass `$surface['ptr']` to the
[php-sdl/sdl3](https://github.com/php-sdl/sdl3) renderer via
`SDLRender::SDLCreateTextureFromSurface()`.

---

## API reference

All methods live on a single static class:

### `Sdl3ttf\SDLTTF\SDLTTF`

#### Lifecycle

| Method       | Returns | Description                          |
| ------------ | ------- | ------------------------------------ |
| `TTFInit()`  | `bool`  | Initialise SDL3_ttf. Call once.      |
| `TTFQuit()`  | `void`  | Shut down SDL3_ttf.                  |

#### Font loading

| Method                                       | Returns | Description                                              |
| -------------------------------------------- | ------- | -------------------------------------------------------- |
| `TTFOpenFont(string $file, float $size)`     | `array` | Open a `.ttf` / `.otf` file at the given point size.     |
| `TTFCloseFont(int $ptr)`                     | `void`  | Close a font previously opened with `TTFOpenFont`.       |

`TTFOpenFont` returns an associative array with font metadata:

```php
[
    'ptr'         => int,   // opaque TTF_Font pointer
    'size'        => int,   // resolved point size
    'style'       => int,   // TTF_STYLE_* bitmask
    'outline'     => int,   // outline thickness (0 = none)
    'hinting'     => int,   // TTF_HINTING_* value
    'height'      => int,   // max glyph height in pixels
    'ascent'      => int,   // pixels above baseline
    'descent'     => int,   // pixels below baseline (negative)
    'line_skip'   => int,   // recommended line spacing
    'fixed_width' => int,   // 1 if monospaced, 0 otherwise
]
```

Returns `[]` on failure.

#### Text rendering

| Method | Returns | Description |
| ------ | ------- | ----------- |
| `TTFRenderTextBlended(int $font, string $text, int $r, int $g, int $b, int $a, int $length = 0)` | `array` | Render UTF-8 text to an ARGB `SDL_Surface` with alpha blending. |

`$font` is the `ptr` value from `TTFOpenFont`. `$r/$g/$b/$a` are 0-255
colour components. `$length` is the byte length of text to render (0 = use
the full string).

Returns an associative array describing the surface:

```php
[
    'ptr'      => int,   // SDL_Surface pointer
    'flags'    => int,   // surface flags
    'format'   => int,   // pixel format enum
    'w'        => int,   // width in pixels
    'h'        => int,   // height in pixels
    'pitch'    => int,   // bytes per row
    'pixels'   => [
        'ptr'  => int,   // raw pixel buffer pointer
        'data' => int[], // flat array of packed ARGB pixels (row-major)
    ],
    'refcount' => int,
]
```

Returns `[]` on failure.

---

## Companion extension

This extension handles **font rendering only**. For windowing, input,
rendering, and the rest of SDL3, install
[php-sdl/sdl3](https://github.com/php-sdl/sdl3) alongside it.

Both extensions can be loaded simultaneously — they use separate PHP module
names (`sdl3` and `sdl3ttf`) and do not conflict.

---

## License

MIT &copy; Project Saturn Studios, LLC.
