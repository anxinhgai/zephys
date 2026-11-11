import SwiftUI
import UIKit
import AVFoundation
import Combine

struct HX: View {
    let d: Data
    @State private var pg = 1
    private let per = 1500

    private var rows: Int { (d.count + 15) / 16 }

    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(0..<min(rows, per * pg), id: \.self) { i in
                    line(i)
                }
                if rows > per * pg {
                    HStack {
                        GB(t: "load more", c: T0.acc) { pg += 1 }
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .padding(.vertical, 6)
        }
        .scrollIndicators(.visible)
    }

    private func line(_ i: Int) -> some View {
        let s = i * 16
        let e = min(s + 16, d.count)
        var hx = ""
        var asc = ""
        for k in s..<e {
            let b = d[k]
            hx += String(format: "%02X ", b)
            asc += (b >= 32 && b < 127) ? String(UnicodeScalar(b)) : "."
        }
        while hx.count < 48 { hx += " " }
        return HStack(spacing: 10) {
            Text(String(format: "%08X", s))
                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                .foregroundStyle(T0.dim.opacity(0.5))
                .frame(width: 64, alignment: .leading)
            Text(hx)
                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                .foregroundStyle(T0.ink.opacity(0.92))
            Text(asc)
                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                .foregroundStyle(T0.acc.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 1)
    }
}

struct IM: View {
    let d: Data
    @State private var z: CGFloat = 1
    @State private var b: CGFloat = 1

    var body: some View {
        GeometryReader { g in
            ScrollView([.horizontal, .vertical]) {
                if let u = UIImage(data: d) {
                    Image(uiImage: u)
                        .resizable()
                        .scaledToFit()
                        .frame(width: g.size.width * z)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { v in z = min(6, max(1, b * v)) }
                                .onEnded { _ in b = z }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                                z = 1
                                b = 1
                            }
                        }
                } else {
                    Text("NO IMAGE DATA")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .kerning(2)
                        .foregroundStyle(T0.dim)
                        .frame(width: g.size.width, height: 160)
                }
            }
            .scrollIndicators(.visible)
        }
    }
}

struct AU: View {
    let d: Data
    let ext: String

    @State private var pl: AVAudioPlayer?
    @State private var on = false
    @State private var pos: Double = 0
    @State private var dur: Double = 0
    @State private var loop = false
    @State private var bad = false
    @State private var vol: Double = 0.9

    private let tick = Timer.publish(every: 0.09, on: .main, in: .common).autoconnect()

    private var pr: Double { dur > 0 ? min(1, max(0, pos / dur)) : 0 }

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 3.4) {
                ForEach(0..<36, id: \.self) { i in
                    let hh: CGFloat = 9 + CGFloat((i * 41 + 17) % 30)
                    Capsule()
                        .fill(Double(i) / 36.0 <= pr ? T0.acc : Color.white.opacity(0.15))
                        .frame(width: 3.2, height: hh)
                }
            }
            .frame(height: 42)
            .animation(.linear(duration: 0.09), value: pr)

            HStack(spacing: 14) {
                Button {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    tog()
                } label: {
                    ZStack {
                        Circle().fill(on ? T0.acc : Color.white.opacity(0.10))
                        if on {
                            HStack(spacing: 4) {
                                Capsule().fill(Color.black.opacity(0.8)).frame(width: 3.4, height: 13)
                                Capsule().fill(Color.black.opacity(0.8)).frame(width: 3.4, height: 13)
                            }
                        } else {
                            Path { p in
                                p.move(to: CGPoint(x: 0, y: 0))
                                p.addLine(to: CGPoint(x: 0, y: 17))
                                p.addLine(to: CGPoint(x: 14, y: 8.5))
                                p.closeSubpath()
                            }
                            .fill(Color.black.opacity(0.8))
                            .frame(width: 14, height: 17)
                            .offset(x: 2)
                        }
                    }
                    .frame(width: 46, height: 46)
                }
                .buttonStyle(PS())

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(tt(pos))
                        Spacer()
                        Text(tt(dur))
                    }
                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                    .foregroundStyle(T0.dim)

                    Slider(value: $pos, in: 0...max(dur, 0.01)) { e in
                        if !e { pl?.currentTime = pos }
                    }
                    .tint(T0.acc)
                }
            }

            HStack(spacing: 8) {
                GB(t: loop ? "loop on" : "loop", c: loop ? T0.ok : T0.dim) {
                    loop.toggle()
                    pl?.numberOfLoops = loop ? -1 : 0
                }
                GB(t: "-5s", c: T0.dim) { jump(-5) }
                GB(t: "+5s", c: T0.dim) { jump(5) }
                Spacer()
            }

            HStack(spacing: 6) {
                Text("VOL")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(T0.dim.opacity(0.8))
                Slider(value: $vol, in: 0...1) { _ in pl?.volume = Float(vol) }
                    .tint(T0.dim)
            }

            if bad {
                Text("không phát được định dạng này")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(T0.wr)
            }
        }
        .padding(16)
        .onReceive(tick) { _ in
            guard let p = pl, on else { return }
            pos = p.currentTime
            if !p.isPlaying {
                on = false
                pos = 0
            }
        }
        .onDisappear {
            pl?.stop()
            on = false
        }
    }

    private func tt(_ s: Double) -> String {
        if s.isNaN || s < 0 { return "0:00" }
        let i = Int(s.rounded())
        return String(format: "%d:%02d", i / 60, i % 60)
    }

    private func mk() {
        guard pl == nil else { return }
        let e = ext.isEmpty ? "dat" : ext
        let u = FileManager.default.temporaryDirectory
            .appendingPathComponent("zp-au-\(UUID().uuidString)." + e)
        try? d.write(to: u)
        let a = AVAudioSession.sharedInstance()
        try? a.setCategory(.playback, mode: .default, options: [])
        try? a.setActive(true)
        let p = try? AVAudioPlayer(contentsOf: u)
        p?.volume = Float(vol)
        p?.numberOfLoops = loop ? -1 : 0
        p?.prepareToPlay()
        dur = p?.duration ?? 0
        bad = p == nil
        pl = p
    }

    private func tog() {
        mk()
        guard let p = pl else { return }
        if on {
            p.pause()
            on = false
        } else {
            if p.currentTime >= p.duration - 0.05 { p.currentTime = 0 }
            p.play()
            on = true
        }
    }

    private func jump(_ s: Double) {
        mk()
        guard let p = pl else { return }
        let t = max(0, min(p.duration - 0.05, p.currentTime + s))
        p.currentTime = t
        pos = t
    }
}

struct EXI: Identifiable {
    let u: URL
    var id: String { u.path }
}

struct SC: UIViewControllerRepresentable {
    let u: URL
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [u], applicationActivities: nil)
    }
    func updateUIViewController(_ c: UIActivityViewController, context: Context) {}
}

struct D3: View {
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { _ in
                Circle().fill(T0.ink.opacity(0.72)).frame(width: 3.4, height: 3.4)
            }
        }
        .frame(width: 34, height: 34)
        .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(Color.white.opacity(0.05)))
        .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).stroke(T0.ln, lineWidth: 1))
    }
}

struct MC: View {
    let t: String
    let on: Bool
    let a: () -> Void

    var body: some View {
        Button(action: a) {
            Text(t.uppercased())
                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                .kerning(1.2)
                .foregroundStyle(on ? Color.black.opacity(0.85) : T0.dim)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Capsule().fill(on ? T0.ink : Color.white.opacity(0.055)))
                .overlay(Capsule().stroke(T0.ln, lineWidth: on ? 0 : 1))
        }
        .buttonStyle(PS())
    }
}
