import SwiftUI

enum T0 {
    static let bg = Color(red: 0.039, green: 0.047, blue: 0.063)
    static let bg2 = Color(red: 0.075, green: 0.086, blue: 0.114)
    static let ink = Color(red: 0.910, green: 0.925, blue: 0.949)
    static let dim = Color.white.opacity(0.40)
    static let dim2 = Color.white.opacity(0.16)
    static let ln = Color.white.opacity(0.075)
    static let acc = Color(red: 0.298, green: 0.616, blue: 0.988)
    static let ok = Color(red: 0.478, green: 0.867, blue: 0.647)
    static let wr = Color(red: 0.976, green: 0.639, blue: 0.302)
    static let rd = Color(red: 0.949, green: 0.400, blue: 0.400)
    static let mono = Font.system(size: 12, weight: .medium, design: .monospaced)
    static let mong = Font.system(size: 11, weight: .bold, design: .monospaced)
    static func h(_ s: CGFloat) -> Font { .system(size: s, weight: .semibold, design: .default) }
}

struct TX: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [T0.bg2, T0.bg, T0.bg], startPoint: .topLeading, endPoint: .bottomTrailing)
            Canvas { c, sz in
                var p = Path()
                var y: CGFloat = 0
                while y < sz.height {
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: sz.width, y: y))
                    y += 4
                }
                c.stroke(p, with: .color(.white.opacity(0.014)), lineWidth: 1)
                var seed: UInt64 = 0x9E37_79B9_7F4A_7C15
                func rn() -> CGFloat {
                    seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
                    return CGFloat((seed >> 33) & 0xFF_FFFF) / CGFloat(0xFF_FFFF)
                }
                for _ in 0..<820 {
                    let x = rn() * sz.width
                    let yy = rn() * sz.height
                    let r = 0.6 + rn() * 1.2
                    c.fill(Path(ellipseIn: CGRect(x: x, y: yy, width: r, height: r)),
                           with: .color(.white.opacity(0.055 * rn())))
                }
                var g = Path()
                g.move(to: CGPoint(x: 0, y: sz.height * 0.18))
                g.addLine(to: CGPoint(x: sz.width, y: sz.height * 0.44))
                c.stroke(g, with: .color(.white.opacity(0.02)), lineWidth: 1)
            }
            RadialGradient(colors: [T0.acc.opacity(0.11), .clear], center: .topLeading, startRadius: 6, endRadius: 440)
        }
        .ignoresSafeArea()
    }
}

struct PS: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.966 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct PB: View {
    let t: String
    var on = true
    var c: Color = T0.acc
    var w: CGFloat = .infinity
    let a: () -> Void

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            a()
        }) {
            Text(t.uppercased())
                .font(.system(size: 12.5, weight: .bold, design: .monospaced))
                .kerning(1.9)
                .foregroundStyle(on ? Color.black.opacity(0.86) : T0.dim)
                .frame(maxWidth: w)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(on ? c : Color.white.opacity(0.055))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(.white.opacity(on ? 0.14 : 0.07), lineWidth: 1)
                )
                .shadow(color: on ? c.opacity(0.24) : .clear, radius: 16, y: 5)
        }
        .buttonStyle(PS())
        .disabled(!on)
    }
}

struct GB: View {
    let t: String
    var c: Color = T0.ink
    let a: () -> Void

    var body: some View {
        Button(action: a) {
            Text(t.uppercased())
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .kerning(1.5)
                .foregroundStyle(c)
                .padding(.horizontal, 13)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(T0.ln, lineWidth: 1)
                )
        }
        .buttonStyle(PS())
    }
}

struct CD<C: View>: View {
    let c: C
    init(@ViewBuilder _ c: () -> C) { self.c = c() }

    var body: some View {
        c.padding(15)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.036))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(T0.ln, lineWidth: 1)
            )
    }
}

struct FD: View {
    let p: String
    @Binding var v: String
    var sec = false
    var big = false

    var body: some View {
        Group {
            if sec {
                SecureField("", text: $v, prompt: Text(p).foregroundColor(T0.dim))
            } else {
                TextField("", text: $v, prompt: Text(p).foregroundColor(T0.dim))
            }
        }
        .font(big ? .system(size: 15, weight: .semibold, design: .monospaced) : T0.mono)
        .foregroundStyle(T0.ink)
        .tint(T0.acc)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .padding(.horizontal, 13)
        .padding(.vertical, big ? 14 : 12)
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color.black.opacity(0.34))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .stroke(T0.ln, lineWidth: 1)
        )
    }
}

struct BG: View {
    let t: String
    var c: Color = T0.acc

    var body: some View {
        Text(t.uppercased())
            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
            .kerning(1.3)
            .foregroundStyle(c)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().fill(c.opacity(0.13)))
            .overlay(Capsule().stroke(c.opacity(0.26), lineWidth: 1))
    }
}

struct HR: View {
    var body: some View { Rectangle().fill(T0.ln).frame(height: 1) }
}

struct WM: View {
    var s = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 9) {
                Rectangle().fill(T0.acc).frame(width: 3, height: 15)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                Text("ZEPHYS")
                    .font(.system(size: 18, weight: .heavy))
                    .kerning(6)
                    .foregroundStyle(T0.ink)
            }
            if !s.isEmpty {
                Text(s.uppercased())
                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                    .kerning(2.4)
                    .foregroundStyle(T0.dim)
            }
        }
    }
}

struct SR: View {
    let t: String
    let s: String
    var c: Color = T0.dim
    var body: some View {
        HStack {
            Text(t.uppercased())
                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                .kerning(2.2)
                .foregroundStyle(c)
            Spacer()
            Text(s)
                .font(T0.mono)
                .foregroundStyle(T0.dim)
        }
    }
}
