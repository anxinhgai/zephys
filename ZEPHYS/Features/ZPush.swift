import SwiftUI
import UniformTypeIdentifiers

struct V5: View {
    @StateObject private var s = S0.s
    @State private var pkf = false
    @State private var pkd = false
    @State private var cp = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if s.dx == nil, s.stp.isEmpty, s.res == nil { src }
                if let d = s.dx { staged(d) }
                if !s.stp.isEmpty { steps }
                if let u = s.res { done(u) }
            }
            .padding(.horizontal, 20)
            .padding(.top, 2)
            .padding(.bottom, 26)
        }
        .scrollIndicators(.visible)
        .sheet(isPresented: $pkf) {
            PKS(mul: true, dir: false) { urls in
                pkf = false
                if !urls.isEmpty { Task { await s.cnt2(urls) } }
            }
        }
        .sheet(isPresented: $pkd) {
            PKS(mul: false, dir: true) { urls in
                pkd = false
                if !urls.isEmpty { Task { await s.cnt2(urls) } }
            }
        }
    }

    private var ibc: Int { H0.ibf().count }

    private var src: some View {
        VStack(spacing: 12) {
            CD {
                VStack(alignment: .leading, spacing: 13) {
                    SR(t: "import", s: s.bs ? "reading" : "zip · folder · file")
                    HR()
                    Text("chọn 1 file zip, 1 folder chứa site/repo, hoặc 1 file đơn. app tự nhận dạng: có index.html → web, có file deb → repo.")
                        .font(.system(size: 11.5, weight: .regular, design: .monospaced))
                        .foregroundStyle(T0.dim)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        BG(t: "zip")
                        BG(t: "folder", c: T0.ok)
                        BG(t: "deb", c: T0.wr)
                    }
                }
            }
            HStack(spacing: 9) {
                PB(t: s.bs ? "reading" : "files / zip", on: !s.bs) { pkf = true }
                GB(t: "folder", c: T0.acc) { pkd = true }
            }
            if ibc > 0 {
                HStack(spacing: 9) {
                    GB(t: "inbox (\(ibc))", c: T0.ok) {
                        let u = H0.ibf()
                        Task { await s.cnt2(u) }
                    }
                    Spacer()
                }
            }
        }
        .transition(.opacity)
    }

    private func staged(_ d: S0.DX) -> some View {
        VStack(spacing: 12) {
            CD {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        SR(t: "staged", s: "\(d.fl.count) file")
                        Spacer()
                        BG(t: d.kd == 2 ? "web" : "repo", c: d.kd == 2 ? T0.ok : T0.acc)
                    }
                    HR()
                    HStack {
                        Text("total")
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .kerning(1.8)
                            .foregroundStyle(T0.dim)
                        Spacer()
                        Text(H0.hm(d.sz))
                            .font(T0.mono)
                            .foregroundStyle(T0.ink)
                    }
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(d.fl.keys.sorted().prefix(40), id: \.self) { k in
                                HStack(spacing: 6) {
                                    Rectangle().fill(k.hasSuffix(".deb") ? T0.wr : T0.dim2)
                                        .frame(width: 2, height: 9)
                                    Text(k)
                                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                                        .foregroundStyle(T0.dim)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 110)
                    .scrollIndicators(.visible)
                }
            }

            CD {
                VStack(alignment: .leading, spacing: 10) {
                    SR(t: "url name", s: "github pages")
                    FD(p: "ten-url", v: $s.nm, big: true)
                    Text("https://\(s.lg).github.io/\(H0.sl(s.nm))/")
                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(T0.dim)
                        .lineLimit(1)
                }
            }

            HStack(spacing: 9) {
                GB(t: "discard", c: T0.dim) {
                    withAnimation { s.dx = nil; s.stp = []; s.res = nil }
                }
                PB(t: s.bs ? "working" : "publish", on: !s.bs && s.nm.count > 0) {
                    Task { await s.go() }
                }
            }
        }
        .transition(.opacity.combined(with: .offset(y: 8)))
    }

    private var steps: some View {
        CD {
            VStack(alignment: .leading, spacing: 11) {
                SR(t: "process", s: s.bs ? "running" : "done")
                HR()
                ForEach(s.stp) { st in
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(st.k == 0 ? T0.dim2 : (st.k == 1 ? T0.acc : (st.k == 2 ? T0.ok : T0.rd)))
                            .frame(width: 8, height: 8)
                        Text(st.t)
                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                            .kerning(1.7)
                            .foregroundStyle(st.k == 0 ? T0.dim : T0.ink)
                        Spacer()
                        Text(st.k == 0 ? "·" : (st.k == 1 ? "run" : (st.k == 2 ? "ok" : "err")))
                            .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(st.k == 3 ? T0.rd : T0.dim)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: s.stp.map { $0.k })
    }

    private func done(_ u: String) -> some View {
        CD {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    SR(t: "live", s: "pages")
                    Spacer()
                    BG(t: "online", c: T0.ok)
                }
                HR()
                Text(u)
                    .font(.system(size: 12.5, weight: .semibold, design: .monospaced))
                    .foregroundStyle(T0.acc)
                    .textSelection(.enabled)
                    .lineLimit(3)
                HStack(spacing: 9) {
                    GB(t: cp ? "copied" : "copy") {
                        UIPasteboard.general.string = u
                        cp = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { cp = false }
                    }
                    if let link = URL(string: u) {
                        Link(destination: link) {
                            Text("OPEN")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .kerning(1.5)
                                .foregroundStyle(T0.ink)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 9)
                                .background(RoundedRectangle(cornerRadius: 9).fill(Color.white.opacity(0.05)))
                                .overlay(RoundedRectangle(cornerRadius: 9).stroke(T0.ln, lineWidth: 1))
                        }
                    }
                    Spacer()
                    GB(t: "again", c: T0.dim) {
                        withAnimation { s.res = nil; s.stp = []; s.dx = nil }
                    }
                }
            }
        }
        .transition(.scale(scale: 0.97).combined(with: .opacity))
    }
}
