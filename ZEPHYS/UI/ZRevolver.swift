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

struct GUN: View {
    var rec: CGFloat
    var rot: Double
    var fl: CGFloat
    var fy: CGFloat

    var body: some View {
        Canvas { c, sz in
            let W = sz.width
            let H = sz.height
            let ax = H * 0.40
            let mx = W * 0.985
            let cx = W * 0.300
            let cr = W * 0.090

            var g = c
            g.translateBy(x: -rec * W * 0.030, y: 0)
            let base = CGPoint(x: W * 0.17, y: ax + W * 0.26)
            g.translateBy(x: base.x, y: base.y)
            g.rotate(by: .degrees(Double(-rec * 2.2)))
            g.translateBy(x: -base.x, y: -base.y)

            let steel = GraphicsContext.Shading.linearGradient(
                Gradient(colors: [Color(white: 0.97), Color(white: 0.80), Color(white: 0.66)]),
                startPoint: CGPoint(x: 0, y: ax - W * 0.11),
                endPoint: CGPoint(x: 0, y: ax + W * 0.10))

            func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) {
                g.fill(Path(roundedRect: CGRect(x: x, y: y, width: w, height: h),
                            cornerRadius: r), with: steel)
            }

            var grip = Path()
            grip.move(to: CGPoint(x: W * 0.245, y: ax + W * 0.010))
            grip.addLine(to: CGPoint(x: W * 0.318, y: ax + W * 0.060))
            grip.addCurve(to: CGPoint(x: W * 0.250, y: ax + W * 0.300),
                          control1: CGPoint(x: W * 0.330, y: ax + W * 0.170),
                          control2: CGPoint(x: W * 0.300, y: ax + W * 0.255))
            grip.addCurve(to: CGPoint(x: W * 0.128, y: ax + W * 0.258),
                          control1: CGPoint(x: W * 0.215, y: ax + W * 0.300),
                          control2: CGPoint(x: W * 0.160, y: ax + W * 0.286))
            grip.addCurve(to: CGPoint(x: W * 0.152, y: ax + W * 0.052),
                          control1: CGPoint(x: W * 0.108, y: ax + W * 0.190),
                          control2: CGPoint(x: W * 0.132, y: ax + W * 0.110))
            grip.closeSubpath()
            g.fill(grip, with: steel)

            var frame = Path()
            frame.move(to: CGPoint(x: W * 0.222, y: ax - W * 0.052))
            frame.addLine(to: CGPoint(x: W * 0.382, y: ax - W * 0.040))
            frame.addLine(to: CGPoint(x: W * 0.382, y: ax + W * 0.030))
            frame.addLine(to: CGPoint(x: W * 0.242, y: ax + W * 0.052))
            frame.closeSubpath()
            g.fill(frame, with: steel)

            var ham = Path()
            ham.move(to: CGPoint(x: W * 0.212, y: ax - W * 0.048))
            ham.addLine(to: CGPoint(x: W * 0.238, y: ax - W * 0.104))
            ham.addLine(to: CGPoint(x: W * 0.272, y: ax - W * 0.092))
            ham.addLine(to: CGPoint(x: W * 0.268, y: ax - W * 0.030))
            ham.closeSubpath()
            g.fill(ham, with: steel)

            g.fill(Path(ellipseIn: CGRect(x: cx - cr, y: ax - cr, width: cr * 2, height: cr * 2)),
                   with: steel)

            let dark = GraphicsContext.Shading.color(Color(red: 0.05, green: 0.06, blue: 0.09))
            for i in 0..<6 {
                let a = Double(i) * .pi / 3 + rot * .pi / 180
                let px = cx + CGFloat(cos(a)) * cr * 0.50
                let py = ax + CGFloat(sin(a)) * cr * 0.50
                let r2 = cr * 0.255
                g.fill(Path(ellipseIn: CGRect(x: px - r2, y: py - r2, width: r2 * 2, height: r2 * 2)),
                       with: dark)
            }
            g.stroke(Path(ellipseIn: CGRect(x: cx - cr * 0.62, y: ax - cr * 0.62,
                                            width: cr * 1.24, height: cr * 1.24)),
                     with: .color(Color(white: 0.45).opacity(0.55)), lineWidth: W * 0.004)

            rect(W * 0.330, ax - W * 0.048, mx - W * 0.330, W * 0.030, W * 0.006)
            rect(W * 0.330, ax - W * 0.030, mx - W * 0.330, W * 0.058, W * 0.008)
            rect(W * 0.400, ax + W * 0.028, W * 0.585, W * 0.034, W * 0.008)
            rect(W * 0.412, ax + W * 0.036, W * 0.545, W * 0.010, W * 0.004)

            var fsight = Path()
            fsight.move(to: CGPoint(x: W * 0.935, y: ax - W * 0.048))
            fsight.addLine(to: CGPoint(x: W * 0.958, y: ax - W * 0.086))
            fsight.addLine(to: CGPoint(x: W * 0.972, y: ax - W * 0.048))
            fsight.closeSubpath()
            g.fill(fsight, with: steel)

            g.stroke(Path(ellipseIn: CGRect(x: W * 0.168, y: ax + W * 0.030,
                                            width: W * 0.128, height: W * 0.100)),
                     with: .color(Color(white: 0.88)), lineWidth: W * 0.013)

            var trg = Path()
            trg.move(to: CGPoint(x: W * 0.222, y: ax + W * 0.026))
            trg.addCurve(to: CGPoint(x: W * 0.214, y: ax + W * 0.086),
                         control1: CGPoint(x: W * 0.205, y: ax + W * 0.044),
                         control2: CGPoint(x: W * 0.198, y: ax + W * 0.070))
            g.stroke(trg, with: .color(Color(white: 0.82)), lineWidth: W * 0.010)

            g.fill(Path(ellipseIn: CGRect(x: mx - W * 0.012, y: ax - W * 0.014,
                                          width: W * 0.024, height: W * 0.028)), with: dark)

            g.fill(Path(ellipseIn: CGRect(x: W * 0.196, y: ax + W * 0.150,
                                          width: W * 0.030, height: W * 0.030)),
                   with: .color(Color(red: 0.10, green: 0.12, blue: 0.16)))

            if fy > 0.001 && fy < 0.985 {
                var tr = Path()
                let bl = W * 0.42 * fy
                tr.addRoundedRect(in: CGRect(x: mx - bl, y: ax - W * 0.006, width: bl, height: W * 0.012),
                                  cornerRadius: W * 0.006)
                c.fill(tr, with: .linearGradient(
                    Gradient(colors: [Color(red: 0.98, green: 0.70, blue: 0.30).opacity(0),
                                      Color(red: 0.98, green: 0.70, blue: 0.30).opacity(0.45)]),
                    startPoint: CGPoint(x: mx - bl, y: ax),
                    endPoint: CGPoint(x: mx, y: ax)))

                let bx = mx + W * 0.90 * fy
                var b = Path()
                b.addRoundedRect(in: CGRect(x: bx, y: ax - W * 0.013, width: W * 0.040, height: W * 0.026),
                                 cornerRadius: W * 0.013)
                c.fill(b, with: .color(Color(red: 0.98, green: 0.72, blue: 0.34)))
                c.fill(Path(ellipseIn: CGRect(x: bx + W * 0.026, y: ax - W * 0.013,
                                              width: W * 0.026, height: W * 0.026)),
                       with: .color(Color(red: 1.0, green: 0.86, blue: 0.55)))
            }

            if fl > 0.01 {
                let R = W * (0.10 + 0.12 * fl)
                var star = Path()
                let n = 9
                for i in 0..<(n * 2) {
                    let a = Double(i) * .pi / Double(n)
                    let rad = (i % 2 == 0) ? R : R * 0.30
                    let pt = CGPoint(x: mx + CGFloat(cos(a)) * rad, y: ax + CGFloat(sin(a)) * rad)
                    if i == 0 { star.move(to: pt) } else { star.addLine(to: pt) }
                }
                star.closeSubpath()
                c.fill(star, with: .radialGradient(
                    Gradient(colors: [Color(red: 1, green: 0.98, blue: 0.85).opacity(Double(fl)),
                                      Color(red: 0.98, green: 0.62, blue: 0.22).opacity(Double(fl) * 0.75),
                                      Color(red: 0.95, green: 0.40, blue: 0.12).opacity(0)]),
                    center: CGPoint(x: mx, y: ax), startRadius: 0, endRadius: R))
                c.fill(Path(ellipseIn: CGRect(x: mx - W * 0.035, y: ax - W * 0.035,
                                              width: W * 0.070, height: W * 0.070)),
                       with: .color(Color.white.opacity(Double(fl) * 0.85)))
            }
        }
    }
}

struct V8: View {
    var tx = "preparing"
    @AppStorage("zpsnd") private var snd = true
    @State private var fy: CGFloat = 0
    @State private var rc: CGFloat = 0
    @State private var fl: CGFloat = 0
    @State private var rot: Double = 0
    @State private var bar: CGFloat = 0
    @State private var shotCount = 0

    var body: some View {
        GeometryReader { g in
            let w = min(g.size.width * 0.92, 360)
            VStack(spacing: 26) {
                Spacer()
                GUN(rec: rc, rot: rot, fl: fl, fy: fy)
                    .frame(width: w, height: w * 0.52)
                    .shadow(color: .black.opacity(0.55), radius: 18, y: 12)

                VStack(spacing: 14) {
                    Text("ZEPHYS")
                        .font(.system(size: 22, weight: .heavy))
                        .kerning(10)
                        .foregroundStyle(T0.ink)
                    Text(tx.uppercased())
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .kerning(2.8)
                        .foregroundStyle(T0.dim)

                    VStack(spacing: 7) {
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.07)).frame(width: 176, height: 3)
                            Capsule()
                                .fill(LinearGradient(colors: [T0.acc, T0.ok],
                                                     startPoint: .leading, endPoint: .trailing))
                                .frame(width: 176 * bar, height: 3)
                                .shadow(color: T0.acc.opacity(0.55), radius: 7)
                        }
                        HStack(spacing: 3) {
                            ForEach(0..<6, id: \.self) { i in
                                Capsule()
                                    .fill(Double(i) < (Double(shotCount) * 0.7).truncatingRemainder(dividingBy: 6.0) ? T0.ok : Color.white.opacity(0.13))
                                    .frame(width: 12, height: 2)
                            }
                        }
                        .opacity(0.9)
                    }
                }
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .task { await loop() }
    }

    private func loop() async {
        SND.s.load()
        withAnimation(.easeInOut(duration: 1.8)) { bar = 0.95 }
        while !Task.isCancelled {
            withAnimation(.easeOut(duration: 0.06)) {
                fl = 1
                rc = 1
            }
            if snd { SND.s.fire() }
            shotCount += 1
            withAnimation(.easeOut(duration: 0.55)) { fy = 1 }
            withAnimation(.spring(response: 0.36, dampingFraction: 0.6)) { rot += 60 }
            try? await Task.sleep(nanoseconds: 95_000_000)
            withAnimation(.easeOut(duration: 0.26)) {
                fl = 0
                rc = 0
            }
            try? await Task.sleep(nanoseconds: 780_000_000)
            fy = 0
            try? await Task.sleep(nanoseconds: 60_000_000)
        }
    }
}
