import SwiftUI

struct RV: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let w = r.width
        let h = r.height
        p.addRoundedRect(in: CGRect(x: w * 0.36, y: h * 0.31, width: w * 0.62, height: h * 0.155),
                         cornerSize: CGSize(width: h * 0.05, height: h * 0.05))
        p.addRoundedRect(in: CGRect(x: w * 0.27, y: h * 0.245, width: w * 0.71, height: h * 0.075),
                         cornerSize: CGSize(width: h * 0.03, height: h * 0.03))
        p.addEllipse(in: CGRect(x: w * 0.215, y: h * 0.285, width: w * 0.25, height: h * 0.315))
        p.move(to: CGPoint(x: w * 0.105, y: h * 0.30))
        p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.30))
        p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.53))
        p.addLine(to: CGPoint(x: w * 0.175, y: h * 0.615))
        p.closeSubpath()
        p.move(to: CGPoint(x: w * 0.145, y: h * 0.355))
        p.addLine(to: CGPoint(x: w * 0.255, y: h * 0.465))
        p.addLine(to: CGPoint(x: w * 0.135, y: h * 0.905))
        p.addLine(to: CGPoint(x: w * 0.015, y: h * 0.815))
        p.closeSubpath()
        p.addRoundedRect(in: CGRect(x: w * 0.115, y: h * 0.205, width: h * 0.075, height: h * 0.075),
                         cornerSize: CGSize(width: 2, height: 2))
        return p
    }
}

struct RG: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let w = r.width
        let h = r.height
        p.addEllipse(in: CGRect(x: w * 0.02, y: h * 0.30, width: w * 0.20, height: h * 0.26))
        p.move(to: CGPoint(x: w * 0.42, y: h * 0.40))
        p.addLine(to: CGPoint(x: w * 0.99, y: h * 0.40))
        return p
    }
}

struct FZ: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: r.midX, y: r.midY)
        let n = 7
        for i in 0..<(n * 2) {
            let ang: CGFloat = CGFloat(i) * .pi / CGFloat(n)
            let rad: CGFloat = (i % 2 == 0) ? r.width * 0.5 : r.width * 0.17
            let pt = CGPoint(x: c.x + cos(ang) * rad, y: c.y + sin(ang) * rad)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

struct V8: View {
    var tx = "preparing"
    @State private var fy: CGFloat = 0
    @State private var rc: CGFloat = 0
    @State private var fl: CGFloat = 0
    @State private var cy: Double = 0
    @State private var bar: CGFloat = 0

    var body: some View {
        GeometryReader { g in
            let w = min(g.size.width * 0.74, 330)
            VStack(spacing: 30) {
                Spacer()
                ZStack {
                    RV()
                        .fill(LinearGradient(colors: [.white.opacity(0.97), .white.opacity(0.70)],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: w, height: w * 0.62)
                        .offset(x: -rc * 9)
                        .shadow(color: .black.opacity(0.55), radius: 22, y: 12)
                    RG()
                        .stroke(Color.white.opacity(0.55), lineWidth: 2)
                        .frame(width: w, height: w * 0.62)
                        .offset(x: -rc * 9)
                    ZStack {
                        ForEach(0..<6, id: \.self) { i in
                            Circle()
                                .fill(Color.black.opacity(0.55))
                                .frame(width: w * 0.052, height: w * 0.052)
                                .offset(y: -w * 0.062)
                                .rotationEffect(.degrees(Double(i) * 60))
                        }
                    }
                    .rotationEffect(.degrees(cy))
                    .offset(x: -w * 0.155 + -rc * 9, y: w * 0.13)
                    FZ()
                        .fill(T0.wr)
                        .frame(width: w * 0.34, height: w * 0.34)
                        .offset(x: w * 0.50, y: -w * 0.02)
                        .scaleEffect(0.5 + fl * 0.7)
                        .opacity(Double(fl) * 0.95)
                        .blur(radius: 1)
                    Capsule()
                        .fill(LinearGradient(colors: [T0.wr.opacity(0), T0.wr.opacity(0.5)],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: w * 0.45 * fy, height: 2)
                        .offset(x: w * 0.55 + w * 0.225 * fy)
                    Capsule()
                        .fill(T0.wr)
                        .frame(width: 21, height: 6.5)
                        .offset(x: w * 0.58 + w * 0.95 * fy, y: -w * 0.02)
                        .opacity(fy > 0.001 && fy < 0.985 ? 1 : 0)
                        .shadow(color: T0.wr.opacity(0.85), radius: 10)
                }
                .frame(height: w * 0.72)

                VStack(spacing: 13) {
                    Text("ZEPHYS")
                        .font(.system(size: 22, weight: .heavy))
                        .kerning(10)
                        .foregroundStyle(T0.ink)
                    Text(tx.uppercased())
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .kerning(2.8)
                        .foregroundStyle(T0.dim)
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08)).frame(width: 140, height: 2)
                        Capsule().fill(T0.acc).frame(width: 140 * bar, height: 2)
                            .shadow(color: T0.acc.opacity(0.6), radius: 6)
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
        withAnimation(.easeInOut(duration: 1.6)) { bar = 0.94 }
        while !Task.isCancelled {
            withAnimation(.easeOut(duration: 0.07)) {
                fl = 1
                rc = 1
            }
            withAnimation(.easeOut(duration: 0.52)) { fy = 1 }
            withAnimation(.spring(response: 0.34, dampingFraction: 0.55)) { cy += 62 }
            try? await Task.sleep(nanoseconds: 95_000_000)
            withAnimation(.easeOut(duration: 0.24)) {
                fl = 0
                rc = 0
            }
            try? await Task.sleep(nanoseconds: 700_000_000)
            fy = 0
            try? await Task.sleep(nanoseconds: 70_000_000)
        }
    }
}
