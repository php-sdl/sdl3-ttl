<?php

/**
 * proof_of_work.php — sdl3ttf extension smoke test
 *
 * Verifies that sdl3ttf loaded, initialises SDL3_ttf, opens a system font,
 * renders a line of text to a surface, and reports the surface dimensions.
 * No window or display is required — the software renderer works headless.
 *
 * Usage:
 *   php examples/proof_of_work.php
 */

declare(strict_types=1);

// ── 1. Extension present? ─────────────────────────────────────────────────────

if (!extension_loaded('sdl3ttf')) {
    fwrite(STDERR, "❌  Extension 'sdl3ttf' is not loaded.\n");
    fwrite(STDERR, "    Run one of the install scripts first, then check:\n");
    fwrite(STDERR, "      php -m | grep sdl3ttf\n");
    exit(1);
}

echo "✓  Extension 'sdl3ttf' is loaded\n";

// ── 2. Find a TTF font ────────────────────────────────────────────────────────

$fontCandidates = [
    // macOS (system)
    '/System/Library/Fonts/Supplemental/Arial.ttf',
    '/System/Library/Fonts/Supplemental/Courier New.ttf',
    '/Library/Fonts/Arial.ttf',

    // Debian / Ubuntu / Pi OS / JetPack
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    '/usr/share/fonts/truetype/freefont/FreeSans.ttf',
    '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',
    '/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf',
    '/usr/share/fonts/truetype/ubuntu/Ubuntu-R.ttf',
    '/usr/share/fonts/TTF/DejaVuSans.ttf',            // Arch / Manjaro
    '/usr/share/fonts/dejavu/DejaVuSans.ttf',          // Fedora
];

$fontPath = null;
foreach ($fontCandidates as $candidate) {
    if (file_exists($candidate)) {
        $fontPath = $candidate;
        break;
    }
}

if ($fontPath === null) {
    fwrite(STDERR, "❌  No TTF font found in common paths.\n");
    fwrite(STDERR, "    On Debian/Ubuntu: sudo apt-get install fonts-dejavu-core\n");
    fwrite(STDERR, "    On Fedora:        sudo dnf install dejavu-sans-fonts\n");
    fwrite(STDERR, "    On macOS:         fonts are pre-installed — this shouldn't happen.\n");
    exit(1);
}

echo "✓  Font: {$fontPath}\n";

// ── 3. TTF_Init ───────────────────────────────────────────────────────────────

$ok = \Sdl3ttf\SDLTTF\SDLTTF::TTFInit();
if (!$ok) {
    fwrite(STDERR, "❌  TTF_Init() failed\n");
    exit(1);
}
echo "✓  TTF_Init() → ok\n";

// ── 4. TTFOpenFont ────────────────────────────────────────────────────────────

$font = \Sdl3ttf\SDLTTF\SDLTTF::TTFOpenFont($fontPath, 24.0);

if (empty($font) || ($font['ptr'] ?? 0) === 0) {
    \Sdl3\SDLTTF\SDLTTF::TTFQuit();
    fwrite(STDERR, "❌  TTFOpenFont('{$fontPath}', 24) failed\n");
    exit(1);
}

echo "✓  TTFOpenFont() → ptr=0x" . dechex($font['ptr']) . "\n";
printf("     height=%d  ascent=%d  descent=%d  line_skip=%d  fixed=%s\n",
    $font['height'],
    $font['ascent'],
    $font['descent'],
    $font['line_skip'],
    $font['fixed_width'] ? 'yes' : 'no'
);

// ── 5. TTFRenderTextBlended ───────────────────────────────────────────────────

$text   = 'Hello from sdl3ttf + PHP!';
$r      = 255; $g = 220; $b = 0; $a = 255;

$surface = \Sdl3ttf\SDLTTF\SDLTTF::TTFRenderTextBlended(
    $font['ptr'], $text, $r, $g, $b, $a
);

if (empty($surface) || ($surface['ptr'] ?? 0) === 0) {
    \Sdl3ttf\SDLTTF\SDLTTF::TTFCloseFont($font['ptr']);
    \Sdl3ttf\SDLTTF\SDLTTF::TTFQuit();
    fwrite(STDERR, "❌  TTFRenderTextBlended() failed\n");
    exit(1);
}

echo "✓  TTFRenderTextBlended()\n";
printf("     surface ptr=0x%x  size=%dx%d  pitch=%d\n",
    $surface['ptr'],
    $surface['w'],
    $surface['h'],
    $surface['pitch']
);

$pixelCount = count($surface['pixels']['data'] ?? []);
printf("     pixels in data array: %d  (expected %d)\n",
    $pixelCount,
    $surface['w'] * $surface['h']
);

// Sanity check: dimensions must be non-zero and pixels must match w*h
if ($surface['w'] <= 0 || $surface['h'] <= 0) {
    fwrite(STDERR, "⚠   Surface has zero dimension — text render may have produced an empty glyph.\n");
} elseif ($pixelCount !== $surface['w'] * $surface['h']) {
    fwrite(STDERR, "⚠   Pixel count mismatch: got {$pixelCount}, expected " . ($surface['w'] * $surface['h']) . "\n");
} else {
    echo "✓  Pixel data matches surface dimensions\n";
}

// Show a tiny ASCII preview of the centre row
if ($surface['w'] > 0 && $surface['h'] > 0 && $pixelCount > 0) {
    $midRow  = (int)($surface['h'] / 2);
    $rowData = array_slice($surface['pixels']['data'], $midRow * $surface['w'], $surface['w']);
    $preview = '';
    $step    = max(1, (int)($surface['w'] / 60));
    foreach (array_filter(array_keys($rowData), fn($i) => $i % $step === 0) as $i) {
        $pixel = $rowData[$i] ?? 0;
        $alpha = ($pixel >> 24) & 0xFF;
        $preview .= $alpha > 128 ? '█' : ($alpha > 20 ? '░' : ' ');
    }
    echo "     mid-row preview: [{$preview}]\n";
}

// ── 6. Cleanup ────────────────────────────────────────────────────────────────

\Sdl3ttf\SDLTTF\SDLTTF::TTFCloseFont($font['ptr']);
echo "✓  TTFCloseFont()\n";

\Sdl3ttf\SDLTTF\SDLTTF::TTFQuit();
echo "✓  TTFQuit()\n";

echo "\n✅  All checks passed — sdl3ttf is working correctly.\n\n";
