import SwiftUI
import AVFoundation

final class SND {
    static let s = SND()
    private var p: AVAudioPlayer?
    private var ok = false

    func load() {
        guard !ok else { return }
        let a = AVAudioSession.sharedInstance()
        try? a.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? a.setActive(true)
        guard let u = Bundle.main.url(forResource: "shot", withExtension: "wav") else { return }
        p = try? AVAudioPlayer(contentsOf: u)
        p?.prepareToPlay()
        ok = p != nil
    }

    func fire() {
        guard ok, let p = p else { return }
        p.currentTime = 0
        p.play()
    }
}

struct FS: View {
    var k: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [Color(red: 1, green: 0.98, blue: 0.86),
                             Color(red: 0.99, green: 0.62, blue: 0.20),
                             Color(red: 0.95, green: 0.42, blue: 0.12).opacity(0)],
                    center: .center, startRadius: 0, endRadius: 46))
                .frame(width: 92, height: 92)
                .blur(radius: 3)
            ForEach(0..<7, id: \.self) { i in
                Capsule()
                    .fill(LinearGradient(
                        colors: [Color(red: 1, green: 0.95, blue: 0.80).opacity(0.95),
                                 Color(red: 1, green: 0.66, blue: 0.22).opacity(0)],
                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: 78, height: 6)
                    .offset(x: 39)
                    .rotationEffect(.degrees(Double(i) * 51.4))
            }
        }
        .scaleEffect(0.55 + 0.65 * k)
        .opacity(Double(k))
    }
}

struct BL: View {
    var body: some View {
        HStack(spacing: 0) {
            Capsule()
                .fill(LinearGradient(colors: [Color(red: 0.80, green: 0.50, blue: 0.16),
                                              Color(red: 0.99, green: 0.80, blue: 0.42)],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(width: 36, height: 15)
            Circle()
                .fill(Color(red: 1, green: 0.89, blue: 0.60))
                .frame(width: 15, height: 15)
        }
        .shadow(color: Color(red: 1, green: 0.70, blue: 0.30).opacity(0.7), radius: 7)
    }
}

struct GUN: View {
    var rec: CGFloat
    var fl: CGFloat
    var fy: CGFloat

    private let ar: CGFloat = 0.464
    private let fx: CGFloat = 0.997
    private let ay: CGFloat = 0.1457

    var body: some View {
        GeometryReader { g in
            let gw = g.size.width * 0.78
            let gh = gw * ar
            let px = gw * fx
            let py = ay * gh
            let end = g.size.width + 26
            ZStack(alignment: .leading) {
                RadialGradient(colors: [Color(red: 0.20, green: 0.32, blue: 0.52).opacity(0.30), .clear],
                               center: .leading, startRadius: 10, endRadius: gw * 1.05)
                    .frame(width: g.size.width, height: gh)
                    .blur(radius: 12)

                Image("gun")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: gw, height: gh)
                    .offset(x: -rec * gw * 0.034)
                    .rotationEffect(.degrees(-Double(rec) * 1.7), anchor: .bottomLeading)
                    .shadow(color: Color.black.opacity(0.6), radius: 14, x: 0, y: 10)

                Circle()
                    .fill(Color.white.opacity(0.13))
                    .frame(width: 46 + 120 * fy, height: 46 + 120 * fy)
                    .blur(radius: 18)
                    .position(x: px + 14 + 40 * fy, y: py)
                    .opacity(fy > 0.01 ? 0.9 : 0)

                FS(k: fl)
                    .frame(width: 110, height: 110)
                    .position(x: px, y: py)

                BL()
                    .position(x: px + (end - px) * fy, y: py)
                    .opacity(fy > 0.004 && fy < 0.998 ? 1 : 0)
            }
            .frame(width: g.size.width, height: gh)
        }
    }
}

struct V8: View {
    var tx = "preparing"
    @AppStorage("zpsnd") private var snd = true
    @State private var fy: CGFloat = 0
    @State private var rc: CGFloat = 0
    @State private var fl: CGFloat = 0
    @State private var bar: CGFloat = 0
    @State private var n: Int = 0

    var body: some View {
        GeometryReader { g in
            let w = min(g.size.width * 0.96, 400)
            VStack(spacing: 22) {
                Spacer()
                GUN(rec: rc, fl: fl, fy: fy)
                    .frame(width: w, height: w * 0.464)

                VStack(spacing: 13) {
                    Text("ZEPHYS")
                        .font(.system(size: 22, weight: .heavy))
                        .kerning(10)
                        .foregroundStyle(T0.ink)
                    Text(tx.uppercased())
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .kerning(2.8)
                        .foregroundStyle(T0.dim)

                    VStack(spacing: 8) {
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.07))
                                .frame(width: 186, height: 3)
                            Capsule()
                                .fill(LinearGradient(colors: [T0.acc, T0.ok],
                                                     startPoint: .leading, endPoint: .trailing))
                                .frame(width: 186 * bar, height: 3)
                                .shadow(color: T0.acc.opacity(0.6), radius: 7)
                        }
                        HStack(spacing: 3) {
                            ForEach(0..<6, id: \.self) { i in
                                Capsule()
                                    .fill(slot(i))
                                    .frame(width: 12, height: 2)
                            }
                        }
                        .opacity(0.85)
                    }
                }
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .task { await loop() }
    }

    private func slot(_ i: Int) -> Color {
        let k = n % 6
        return i < k ? T0.ok : Color.white.opacity(0.13)
    }

    private func loop() async {
        SND.s.load()
        withAnimation(.easeInOut(duration: 1.8)) { bar = 0.95 }
        while !Task.isCancelled {
            withAnimation(.easeOut(duration: 0.055)) {
                fl = 1
                rc = 1
            }
            if snd { SND.s.fire() }
            n += 1
            withAnimation(.easeOut(duration: 0.5)) { fy = 1 }
            try? await Task.sleep(nanoseconds: 90_000_000)
            withAnimation(.easeOut(duration: 0.24)) {
                fl = 0
                rc = 0
            }
            try? await Task.sleep(nanoseconds: 640_000_000)
            fy = 0
            try? await Task.sleep(nanoseconds: 90_000_000)
        }
    }
}
