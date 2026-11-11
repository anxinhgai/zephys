import SwiftUI
import UIKit

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
