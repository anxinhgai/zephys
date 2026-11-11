#!/usr/bin/env python3
import json, os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

S = 1024
F = 3
BG = (10, 13, 19)
INK = (245, 247, 250)
ACC = (76, 157, 252)
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "ZEPHYS", "Assets.xcassets", "AppIcon.appiconset")

font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf", 96 * F)


def gradient(size):
    img = Image.new("RGBA", (size, size), BG + (255,))
    d = ImageDraw.Draw(img)
    top = (17, 23, 36)
    for y in range(size):
        t = y / (size - 1)
        c = tuple(int(top[i] + (BG[i] - top[i]) * (t ** 0.8)) for i in range(3))
        d.line([(0, y), (size, y)], fill=c + (255,))
    return img


def soft(img, cx, cy, rad, color, alpha):
    lay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    steps = 60
    for i in range(steps):
        t = i / (steps - 1)
        r = rad * (1 - 0.94 * t)
        a = int(alpha * (1 - t) ** 2.1)
        if a <= 0:
            continue
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=color + (a,))
    lay = lay.filter(ImageFilter.GaussianBlur(rad * 0.16))
    return Image.alpha_composite(img, lay)


def build():
    s = S * F
    img = gradient(s)
    img = soft(img, s * 0.24, s * 0.14, s * 0.60, ACC, 58)
    img = soft(img, s * 0.88, s * 0.90, s * 0.52, (150, 118, 255), 34)

    lay = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    for i in range(14):
        x = -s * 0.30 + i * s * 0.13
        d.line([(x, s), (x + s * 0.40, 0)], fill=(255, 255, 255, 7), width=2 * F)
    img = Image.alpha_composite(img, lay)

    lay = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    cx, cy, R = s / 2, s * 0.405, s * 0.258
    d.ellipse([cx - R, cy - R, cx + R, cy + R], fill=INK + (255,))
    img = Image.alpha_composite(img, lay)

    sh = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    sd = ImageDraw.Draw(sh)
    sd.ellipse([cx - R * 0.98, cy - R * 0.94, cx + R * 0.98, cy + R * 1.04], outline=(0, 0, 0, 46), width=int(3 * F))
    sh = sh.filter(ImageFilter.GaussianBlur(3 * F))
    img = Image.alpha_composite(img, sh)

    lay = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    col = BG + (255,)
    hr = R * 0.505
    hy = cy + R * 0.055
    d.ellipse([cx - hr, hy - hr, cx + hr, hy + hr], fill=col)
    d.polygon([(cx - hr * 1.04, hy - hr * 0.14), (cx - hr * 1.30, hy - hr * 1.86),
               (cx - hr * 0.16, hy - hr * 0.52)], fill=col)
    d.polygon([(cx + hr * 1.04, hy - hr * 0.14), (cx + hr * 1.30, hy - hr * 1.86),
               (cx + hr * 0.16, hy - hr * 0.52)], fill=col)
    ew, eh = hr * 0.30, hr * 0.38
    for sx in (-1, 1):
        ex = cx + sx * hr * 0.42
        d.ellipse([ex - ew / 2, hy + hr * 0.02 - eh / 2, ex + ew / 2, hy + hr * 0.02 + eh / 2],
                  fill=INK + (255,))
    img = Image.alpha_composite(img, lay)

    d = ImageDraw.Draw(img)
    word = "ZEPHYS"
    sizes = [d.textlength(c, font=font) for c in word]
    track = 26 * F
    total = sum(sizes) + track * (len(word) - 1)
    x = (s - total) / 2
    y = s * 0.726
    for c, w in zip(word, sizes):
        d.text((x, y), c, font=font, fill=INK + (255,))
        x += w + track
    d.rounded_rectangle([s * 0.385, s * 0.885, s * 0.615, s * 0.885 + 5 * F],
                        radius=3 * F, fill=ACC + (215,))

    out = img.resize((S, S), Image.LANCZOS).convert("RGB")
    os.makedirs(OUT, exist_ok=True)
    out.save(os.path.join(OUT, "icon-1024.png"), "PNG")
    out.resize((512, 512), Image.LANCZOS).save(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "icon-512.png"), "PNG")

    contents = {
        "images": [{"filename": "icon-1024.png", "idiom": "universal",
                    "platform": "ios", "size": "1024x1024"}],
        "info": {"author": "xcode", "version": 1},
    }
    with open(os.path.join(OUT, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
    print("wrote", OUT)


if __name__ == "__main__":
    build()
