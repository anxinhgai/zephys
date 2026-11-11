import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

src = Image.open("/home/user/art/gun_raw.png").convert("RGB")
a = np.asarray(src).astype(np.float32)
g = a.max(axis=2)

bg = g < 12
lab, n = ndimage.label(bg)
edge = set(lab[0, :].tolist()) | set(lab[-1, :].tolist()) | set(lab[:, 0].tolist()) | set(lab[:, -1].tolist())
edge.discard(0)
outside = np.isin(lab, list(edge))
mask = (~outside).astype(np.float32)

al = Image.fromarray((mask * 255).astype(np.uint8), "L").filter(ImageFilter.GaussianBlur(1.4))
al = np.asarray(al).astype(np.float32) / 255.0
al = np.clip((al - 0.25) / 0.75, 0, 1)

ys, xs = np.nonzero(al > 0.5)
x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
pad = 4
x0 = max(0, x0 - pad); y0 = max(0, y0 - pad)
x1 = min(src.width - 1, x1 + pad); y1 = min(src.height - 1, y1 + pad)

rgba = np.dstack([a, al * 255]).astype(np.uint8)
im = Image.fromarray(rgba, "RGBA").crop((x0, y0, x1 + 1, y1 + 1))

w0, h0 = im.size
tw = 1000
im = im.resize((tw, int(h0 * tw / w0)), Image.LANCZOS)
im.save("/home/user/zephys/ZEPHYS/Res/gun.png")

W, H = im.size
arr = np.asarray(im)
alpha = arr[..., 3] > 128
cols = np.nonzero(alpha.any(axis=0))[0]
mx = int(cols.max())
lo = mx - int(W * 0.06)
sub = alpha[:, lo:mx + 1]
ys2, xs2 = np.nonzero(sub)
ay = ys2.mean()
print("size", im.size, "mxFrac", round(mx / (W - 1), 4), "ayFrac", round(ay / H, 4), "aspect", round(H / W, 4))
