import numpy as np, wave, os

SR = 44100
n = int(SR * 0.85)
t = np.arange(n) / SR
rng = np.random.default_rng(7)

def env(x, a, d):
    return (np.exp(-t / d) * (1 - np.exp(-t / a)))

noise = rng.standard_normal(n)

def lp(x, k):
    y = np.zeros_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc += k * (x[i] - acc)
        y[i] = acc
    return y

def hp(x, k):
    return x - lp(x, k)

sig = np.zeros(n)
sig += hp(noise, 0.55) * env(t, 0.0004, 0.020) * 0.95
sig += lp(hp(noise, 0.05), 0.55) * env(t, 0.0008, 0.075) * 0.55
body = np.sin(2 * np.pi * 92 * t) + 0.55 * np.sin(2 * np.pi * 143 * t + 0.7)
sig += body * env(t, 0.001, 0.085) * 0.55
sig += lp(noise, 0.22) * env(t, 0.004, 0.28) * 0.30
sig += lp(noise, 0.06) * env(t, 0.02, 0.55) * 0.10

sig *= np.clip((1 - t / t[-1]) ** 0.35, 0, 1)
sig = np.tanh(sig * 1.6)
sig /= np.max(np.abs(sig)) + 1e-9
sig *= 0.92
pcm = (sig * 32767).astype(np.int16)

os.makedirs("ZEPHYS/Res", exist_ok=True)
with wave.open("ZEPHYS/Res/shot.wav", "wb") as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes(pcm.tobytes())
print("shot.wav", os.path.getsize("ZEPHYS/Res/shot.wav"), "bytes", round(n / SR, 3), "s")
