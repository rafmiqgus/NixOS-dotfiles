"""Replace Sidonia's red with another colour in every PNG under a directory.

Each reddish pixel is modelled as a mix of a neutral grey N and the accent red:
    pixel = (1 - t) * N + t * RED
t comes from how much R exceeds G/B; N is solved from the G/B channels.
The output is rebuilt from that model only:
    out = (1 - t) * N + t * target
so no residual red hue can survive (pixels redder than RED, like #FF0000
glows, are clamped to t = 1 -> pure target). Grey/black/white (t = 0) are
untouched. Alpha is preserved.

usage: recolor.py <dir> <#rrggbb>
"""
import sys
from pathlib import Path

from PIL import Image

RED = (213, 31, 29)  # #D51F1D, Sidonia's accent
RED_Q = (RED[1] + RED[2]) / 2
SPAN = RED[0] - RED_Q  # redness of pure accent


def recolor(path: Path, target: tuple[int, int, int]) -> None:
    img = Image.open(path)
    mode = img.mode
    img = img.convert("RGBA")
    px = img.load()
    changed = False
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            q = (g + b) / 2
            t = (r - q) / SPAN
            if t <= 0.02:
                continue
            t = min(t, 1.0)
            n = 0.0 if t > 0.98 else max(0.0, min(255.0, (q - t * RED_Q) / (1 - t)))
            px[x, y] = tuple(
                max(0, min(255, round((1 - t) * n + t * c))) for c in target
            ) + (a,)
            changed = True
    if changed:
        if mode not in ("RGBA", "LA", "PA") and "transparency" not in img.info:
            img = img.convert("RGB")
        img.save(path)


def main() -> None:
    root, hexcol = Path(sys.argv[1]), sys.argv[2].lstrip("#")
    target = tuple(int(hexcol[i : i + 2], 16) for i in (0, 2, 4))
    for png in sorted(root.rglob("*.png")):
        recolor(png, target)


if __name__ == "__main__":
    main()
