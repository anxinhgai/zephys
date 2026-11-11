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

struct GM {
    let w: CGFloat
    let h: CGFloat
    let ax: CGFloat
    let mx: CGFloat
    let cx: CGFloat
    let cr: CGFloat
    let steel: GraphicsContext.Shading

    init(_ s: CGSize) {
        let ww = s.width
        w = ww
        h = s.height
        ax = s.height * 0.40
        mx = ww * 0.985
        cx = ww * 0.300
        cr = ww * 0.090
        let a = s.height * 0.40
        steel = GraphicsContext.Shading.linearGradient(
            Gradient(colors: [Color(white: 0.97), Color(white: 0.80), Color(white: 0.65)]),
            startPoint: CGPoint(x: 0, y: a - ww * 0.11),
            endPoint: CGPoint(x: 0, y: a + ww * 0.10))
    }

    var dark: GraphicsContext.Shading {
        GraphicsContext.Shading.color(Color(red: 0.05, green: 0.06, blue: 0.09))
    }

    var hi: GraphicsContext.Shading {
        GraphicsContext.Shading.color(Color(white: 0.88))
    }

    var hi2: GraphicsContext.Shading {
        GraphicsContext.Shading.color(Color(white: 0.78))
    }

    func rr(_ x: CGFloat, _ y: CGFloat, _ ww: CGFloat, _ hh: CGFloat, _ r: CGFloat) -> Path {
        Path(roundedRect: CGRect(x: x, y: y, width: ww, height: hh), cornerRadius: r)
    }
}

private func gripP(_ m: GM) -> Path {
    let w = m.w
    let ax = m.ax
    var p = Path()
    p.move(to: CGPoint(x: w * 0.245, y: ax + w * 0.010))
    p.addLine(to: CGPoint(x: w * 0.318, y: ax + w * 0.060))
    p.addCurve(to: CGPoint(x: w * 0.250, y: ax + w * 0.300),
               control1: CGPoint(x: w * 0.330, y: ax + w * 0.170),
               control2: CGPoint(x: w * 0.300, y: ax + w * 0.255))
    p.addCurve(to: CGPoint(x: w * 0.128, y: ax + w * 0.258),
               control1: CGPoint(x: w * 0.215, y: ax + w * 0.300),
               control2: CGPoint(x: w * 0.160, y: ax + w * 0.286))
    p.addCurve(to: CGPoint(x: w * 0.152, y: ax + w * 0.052),
               control1: CGPoint(x: w * 0.108, y: ax + w * 0.190),
               control2: CGPoint(x: w * 0.132, y: ax + w * 0.110))
    p.closeSubpath()
    return p
}

private func frameP(_ m: GM) -> Path {
    let w = m.w
    let ax = m.ax
    var p = Path()
    p.move(to: CGPoint(x: w * 0.222, y: ax - w * 0.052))
    p.addLine(to: CGPoint(x: w * 0.382, y: ax - w * 0.040))
    p.addLine(to: CGPoint(x: w * 0.382, y: ax + w * 0.030))
    p.addLine(to: CGPoint(x: w * 0.242, y: ax + w * 0.052))
    p.closeSubpath()
    return p
}

private func hamP(_ m: GM) -> Path {
    let w = m.w
    let ax = m.ax
    var p = Path()
    p.move(to: CGPoint(x: w * 0.212, y: ax - w * 0.048))
    p.addLine(to: CGPoint(x: w * 0.238, y: ax - w * 0.104))
    p.addLine(to: CGPoint(x: w * 0.272, y: ax - w * 0.092))
    p.addLine(to: CGPoint(x: w * 0.268, y: ax - w * 0.030))
    p.closeSubpath()
    return p
}

private func sightP(_ m: GM) -> Path {
    let w = m.w
    let ax = m.ax
    var p = Path()
    p.move(to: CGPoint(x: w * 0.935, y: ax - w * 0.048))
    p.addLine(to: CGPoint(x: w * 0.958, y: ax - w * 0.086))
    p.addLine(to: CGPoint(x: w * 0.972, y: ax - w * 0.048))
    p.closeSubpath()
    return p
}

private func guardP(_ m: GM) -> Path {
    let w = m.w
    let ax = m.ax
    return Path(ellipseIn: CGRect(x: w * 0.168, y: ax + w * 0.030,
                                  width: w * 0.128, height: w * 0.100))
}

private func trigP(_ m: GM) -> Path {
    let w = m.w
    let ax = m.ax
    var p = Path()
    p.move(to: CGPoint(x: w * 0.222, y: ax + w * 0.026))
    p.addCurve(to: CGPoint(x: w * 0.214, y: ax + w * 0.086),
               control1: CGPoint(x: w * 0.205, y: ax + w * 0.044),
               control2: CGPoint(x: w * 0.198, y: ax + w * 0.070))
    return p
}

private func pistol(_ g: inout GraphicsContext, _ m: GM, _ rot: Double) {
    let w = m.w
    let ax = m.ax
    let mx = m.mx
    let cx = m.cx
    let cr = m.cr

    g.fill(gripP(m), with: m.steel)
    g.fill(frameP(m), with: m.steel)
    g.fill(hamP(m), with: m.steel)
    let cyl = CGRect(x: cx - cr, y: ax - cr, width: cr * 2, height: cr * 2)
    g.fill(Path(ellipseIn: cyl), with: m.steel)

    let step = Double.pi / 3.0
    let off = rot * Double.pi / 180.0
    for i in 0..<6 {
        let a = Double(i) * step + off
        let px = cx + CGFloat(cos(a)) * cr * 0.50
        let py = ax + CGFloat(sin(a)) * cr * 0.50
        let r2 = cr * 0.255
        let hole = CGRect(x: px - r2, y: py - r2, width: r2 * 2, height: r2 * 2)
        g.fill(Path(ellipseIn: hole), with: m.dark)
    }

    let ring = CGRect(x: cx - cr * 0.62, y: ax - cr * 0.62,
                      width: cr * 1.24, height: cr * 1.24)
    g.stroke(Path(ellipseIn: ring), with: .color(Color(white: 0.45).opacity(0.5)), lineWidth: w * 0.004)

    g.fill(m.rr(w * 0.330, ax - w * 0.048, mx - w * 0.330, w * 0.030, w * 0.006), with: m.steel)
    g.fill(m.rr(w * 0.330, ax - w * 0.030, mx - w * 0.330, w * 0.058, w * 0.008), with: m.steel)
    g.fill(m.rr(w * 0.400, ax + w * 0.028, w * 0.585, w * 0.034, w * 0.008), with: m.steel)
    g.fill(m.rr(w * 0.412, ax + w * 0.036, w * 0.545, w * 0.010, w * 0.004), with: m.hi2)

    g.fill(sightP(m), with: m.steel)

    var notch = Path()
    notch.addRect(CGRect(x: w * 0.240, y: ax - w * 0.070, width: w * 0.026, height: w * 0.024))
    g.fill(notch, with: m.dark)

    g.stroke(guardP(m), with: m.hi, lineWidth: w * 0.012)
    g.stroke(trigP(m), with: m.hi2, lineWidth: w * 0.010)

    let muz = CGRect(x: mx - w * 0.012, y: ax - w * 0.014, width: w * 0.024, height: w * 0.028)
    g.fill(Path(ellipseIn: muz), with: m.dark)

    let med = CGRect(x: w * 0.196, y: ax + w * 0.150, width: w * 0.030, height: w * 0.030)
    g.fill(Path(ellipseIn: med), with: .color(Color(red: 0.10, green: 0.12, blue: 0.16)))
}

private func proj(_ c: inout GraphicsContext, _ m: GM, _ fy: CGFloat) {
    if fy <= 0.001 || fy >= 0.985 { return }
    let w = m.w
    let ax = m.ax
    let mx = m.mx

    let bl = w * 0.42 * fy
    let trail = CGRect(x: mx - bl, y: ax - w * 0.006, width: bl, height: w * 0.012)
    let tr = Path(roundedRect: trail, cornerRadius: w * 0.006)
    c.fill(tr, with: .linearGradient(
        Gradient(colors: [Color(red: 0.98, green: 0.70, blue: 0.30).opacity(0),
                          Color(red: 0.98, green: 0.70, blue: 0.30).opacity(0.42)]),
        startPoint: CGPoint(x: mx - bl, y: ax),
        endPoint: CGPoint(x: mx, y: ax)))

    let bx = mx + w * 0.90 * fy
    let body = CGRect(x: bx, y: ax - w * 0.013, width: w * 0.040, height: w * 0.026)
    c.fill(Path(roundedRect: body, cornerRadius: w * 0.013),
           with: .color(Color(red: 0.98, green: 0.72, blue: 0.34)))
    let tip = CGRect(x: bx + w * 0.026, y: ax - w * 0.013, width: w * 0.026, height: w * 0.026)
    c.fill(Path(ellipseIn: tip), with: .color(Color(red: 1.0, green: 0.86, blue: 0.55)))
}

private func flash(_ c: inout GraphicsContext, _ m: GM, _ fl: CGFloat) {
    if fl <= 0.01 { return }
    let w = m.w
    let ax = m.ax
    let mx = m.mx
    let R = w * (0.10 + 0.12 * fl)

    var star = Path()
    let n = 9
    for i in 0..<(n * 2) {
        let a = Double(i) * Double.pi / Double(n)
        let rad = (i % 2 == 0) ? R : R * 0.30
        let pt = CGPoint(x: mx + CGFloat(cos(a)) * rad, y: ax + CGFloat(sin(a)) * rad)
        if i == 0 { star.move(to: pt) } else { star.addLine(to: pt) }
    }
    star.closeSubpath()

    let k = Double(fl)
    let gr = Gradient(colors: [Color(red: 1, green: 0.98, blue: 0.85).opacity(k),
                               Color(red: 0.98, green: 0.62, blue: 0.22).opacity(k * 0.72),
                               Color(red: 0.95, green: 0.40, blue: 0.12).opacity(0)])
    c.fill(star, with: .radialGradient(gr, center: CGPoint(x: mx, y: ax),
                                       startRadius: 0, endRadius: R))
    let core = CGRect(x: mx - w * 0.035, y: ax - w * 0.035, width: w * 0.070, height: w * 0.070)
    c.fill(Path(ellipseIn: core), with: .color(Color.white.opacity(k * 0.85)))
}

struct GUN: View {
    var rec: CGFloat
    var rot: Double
    var fl: CGFloat
    var fy: CGFloat

    var body: some View {
        Canvas { c, sz in
            let m = GM(sz)
            let base = CGPoint(x: m.w * 0.17, y: m.ax + m.w * 0.26)
            var g = c
            let dx = -rec * m.w * 0.030
            let ang = -Double(rec) * 2.2
            g.translateBy(x: dx, y: 0)
            g.translateBy(x: base.x, y: base.y)
            g.rotate(by: Angle.degrees(ang))
            g.translateBy(x: -base.x, y: -base.y)
            pistol(&g, m, rot)
            proj(&c, m, fy)
            flash(&c, m, fl)
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
    @State private var n: Int = 0

    var body: some View {
        GeometryReader { g in
            let w = min(g.size.width * 0.92, 360)
            VStack(spacing: 26) {
                Spacer()
                GUN(rec: rc, rot: rot, fl: fl, fy: fy)
                    .frame(width: w, height: w * 0.52)
                    .shadow(color: Color.black.opacity(0.55), radius: 18, y: 12)

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
                            Capsule()
                                .fill(Color.white.opacity(0.07))
                                .frame(width: 176, height: 3)
                            Capsule()
                                .fill(LinearGradient(colors: [T0.acc, T0.ok],
                                                     startPoint: .leading, endPoint: .trailing))
                                .frame(width: 176 * bar, height: 3)
                                .shadow(color: T0.acc.opacity(0.55), radius: 7)
                        }
                        HStack(spacing: 3) {
                            ForEach(0..<6, id: \.self) { i in
                                Capsule()
                                    .fill(slot(i))
                                    .frame(width: 12, height: 2)
                            }
                        }
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
            withAnimation(.easeOut(duration: 0.06)) {
                fl = 1
                rc = 1
            }
            if snd { SND.s.fire() }
            n += 1
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
