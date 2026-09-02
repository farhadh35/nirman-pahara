"""Draws the launcher icon.

The mark is a plumb bob hanging over a brick course: the oldest tool for
checking whether something built is true, over the thing being checked. It
reads at 48 px, which is the only size that really matters on a launcher.
"""
import pathlib
from PIL import Image, ImageDraw

GREEN = (0, 106, 78, 255)
WHITE = (255, 255, 255, 255)
FAINT = (255, 255, 255, 90)

def draw(size: int, bleed: float = 1.0) -> Image.Image:
    """bleed > 1 leaves room for adaptive-icon masking."""
    s = size
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, s, s], fill=GREEN)

    u = s / 100.0 / bleed
    cx = s / 2
    off = (s - 100 * u) / 2

    def X(v): return off + v * u
    def Y(v): return off + v * u

    # Brick courses across the lower half.
    brick_h = 11
    for i, top in enumerate((52, 52 + brick_h, 52 + 2 * brick_h)):
        y0, y1 = Y(top), Y(top + brick_h - 2.5)
        d.rectangle([X(14), y0, X(86), y1], fill=FAINT)
        # Staggered perpends.
        step = 24
        start = 14 + (0 if i % 2 == 0 else step / 2)
        x = start
        while x < 86:
            if x > 14:
                d.rectangle([X(x - 1.1), y0, X(x + 1.1), y1], fill=GREEN)
            x += step

    # Plumb bob, drawn twice: once oversized in the background colour so it
    # cuts a clean gap through the brickwork, then the mark itself inside it.
    # Without the gap the white bob dissolves into the white bricks and the
    # shape stops reading at launcher size.
    bob_top = 44
    bob_w = 9

    def bob(width: float, top: float, length: float):
        return [
            (X(50 - width), Y(top)),
            (X(50 + width), Y(top)),
            (X(50 + width * 0.72), Y(top + length * 0.52)),
            (cx, Y(top + length)),
            (X(50 - width * 0.72), Y(top + length * 0.52)),
        ]

    halo = 3.4
    d.polygon(bob(bob_w + halo, bob_top - halo, 27 + halo * 2), fill=GREEN)
    d.rectangle(
        [X(50 - 3.2), Y(8), X(50 + 3.2), Y(bob_top)], fill=GREEN)

    # Plumb line and its hanging point.
    d.line([(cx, Y(10)), (cx, Y(bob_top + 1))], fill=WHITE,
           width=max(2, int(2.2 * u)))
    d.ellipse([X(46.5), Y(6.5), X(53.5), Y(13.5)], fill=WHITE)

    d.polygon(bob(bob_w, bob_top, 27), fill=WHITE)
    return img

ROOT = pathlib.Path("android/app/src/main/res")
DENSITIES = {
    "mipmap-mdpi": 48, "mipmap-hdpi": 72, "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144, "mipmap-xxxhdpi": 192,
}

for folder, px in DENSITIES.items():
    out = ROOT / folder
    out.mkdir(parents=True, exist_ok=True)
    draw(px).save(out / "ic_launcher.png")
    # Adaptive foreground sits inside a safe zone, so the mark is drawn smaller.
    fg = Image.new("RGBA", (px, px), (0, 0, 0, 0))
    mark = draw(px, bleed=1.5)
    mark.putalpha(
        Image.eval(mark.split()[3], lambda a: a)
    )
    # Strip the background from the foreground layer.
    px_data = mark.load()
    for y in range(px):
        for x in range(px):
            r, g, b, a = px_data[x, y]
            if (r, g, b) == GREEN[:3]:
                px_data[x, y] = (0, 0, 0, 0)
    fg.alpha_composite(mark)
    fg.save(out / "ic_launcher_foreground.png")

# Play listing icon.
pathlib.Path("store").mkdir(exist_ok=True)
draw(512).save("store/icon-512.png")
print("icons written")
