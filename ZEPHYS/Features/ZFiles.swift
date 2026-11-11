import SwiftUI
import UniformTypeIdentifiers

struct V3: View {
    @StateObject private var s = S0.s
    let r: R0
    let back: () -> Void

    @State private var vw: F0?
    @State private var nf = false
    @State private var nd = false
    @State private var pkf = false
    @State private var pkd = false
    @State private var sh2 = false
    @State private var ibc = 0
    @State private var rn: F0?
    @State private var buf = ""
    @State private var buf2 = ""
    @State private var pf = "debs/"

    private var list: [F0] {
        (s.tr[r.key] ?? []).sorted { $0.p < $1.p }
    }

    private func later(_ f: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: f)
    }

    private func fromInbox() {
        let u = H0.ibf()
        if u.isEmpty { return }
        Task {
            await s.up(r, u, pf)
            s.drop2(u)
            ibc = H0.ibf().count
        }
    }

    var body: some View {
        ZStack {
            if let v = vw {
                V4(r: r, f: v) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { vw = nil }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)))
            } else {
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        GB(t: "back") { back() }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(r.n)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(T0.ink)
                                .lineLimit(1)
                            Text("\(list.count) file · \(r.br)")
                                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                                .kerning(1.2)
                                .foregroundStyle(T0.dim)
                        }
                        Spacer()
                        if s.cnt(r) > 0 {
                            BG(t: "\(s.cnt(r)) staged", c: T0.wr)
                        }
                    }
                    .padding(.horizontal, 20)

                    HStack(spacing: 8) {
                        GB(t: "new file") {
                            buf = ""
                            nf = true
                        }
                        GB(t: "folder") {
                            buf2 = ""
                            nd = true
                        }
                        GB(t: "upload", c: T0.acc) { sh2 = true }
                        if ibc > 0 {
                            GB(t: "inbox \(ibc)", c: T0.ok) { fromInbox() }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(list) { f in
                                FR(f: f) {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.42, dampingFraction: 0.9)) { vw = f }
                                }
                                .contextMenu {
                                    Button("rename") {
                                        buf = f.nm
                                        rn = f
                                    }
                                    Button("delete", role: .destructive) {
                                        s.st(r, f.p, nil)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    }
                    .scrollIndicators(.visible)

                    HStack(spacing: 10) {
                        PB(t: s.bs ? "updating" : "update", on: s.cnt(r) > 0 && !s.bs) {
                            Task {
                                let ok = await s.push(r)
                                if ok { UINotificationFeedbackGenerator().notificationOccurred(.success) }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
                }
                .transition(.opacity)
            }
        }
        .task {
            await s.tree(r)
            ibc = H0.ibf().count
        }
        .sheet(isPresented: $nf) {
            SH1(t: "new file", p: "path/name.html", v: $buf) {
                let n = buf.trimmingCharacters(in: .whitespaces)
                if !n.isEmpty { s.st(r, n, Data("".utf8)) }
                nf = false
            } onCancel: { nf = false }
        }
        .sheet(isPresented: $nd) {
            SH1(t: "new folder", p: "assets", v: $buf2) {
                let n = buf2.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                if !n.isEmpty { s.st(r, n + "/.gitkeep", Data()) }
                nd = false
            } onCancel: { nd = false }
        }
        .sheet(item: $rn) { f in
            SH1(t: "rename", p: f.nm, v: $buf) {
                let n = buf.trimmingCharacters(in: .whitespaces)
                if !n.isEmpty, n != f.nm {
                    Task { await s.rn(r, f.p, f.dir.isEmpty ? n : f.dir + "/" + n) }
                }
                rn = nil
            } onCancel: { rn = nil }
        }
        .sheet(isPresented: $sh2) {
            SH2(pf: $pf, ibc: ibc,
                f1: { sh2 = false; later { pkf = true } },
                f2: { sh2 = false; later { pkd = true } },
                f3: { sh2 = false; later { fromInbox() } },
                onCancel: { sh2 = false })
        }
        .sheet(isPresented: $pkf) {
            PKS(mul: true, dir: false) { urls in
                pkf = false
                if !urls.isEmpty { Task { await s.up(r, urls, pf) } }
            }
        }
        .sheet(isPresented: $pkd) {
            PKS(mul: false, dir: true) { urls in
                pkd = false
                if !urls.isEmpty { Task { await s.up(r, urls, pf) } }
            }
        }
    }
}

struct SH2: View {
    @Binding var pf: String
    let ibc: Int
    let f1: () -> Void
    let f2: () -> Void
    let f3: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            TX()
            VStack(alignment: .leading, spacing: 13) {
                Text("UPLOAD")
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .kerning(2.4)
                    .foregroundStyle(T0.dim)
                FD(p: "thư mục đích (trống = gốc)", v: $pf, big: true)
                HStack(spacing: 8) {
                    GB(t: "root") { pf = "" }
                    GB(t: "debs/") { pf = "debs/" }
                    GB(t: "assets/") { pf = "assets/" }
                    Spacer()
                }
                HStack(spacing: 9) {
                    PB(t: "files", on: true) { f1() }
                    GB(t: "folder", c: T0.acc) { f2() }
                }
                HStack(spacing: 9) {
                    GB(t: ibc > 0 ? "inbox (\(ibc))" : "inbox", c: ibc > 0 ? T0.ok : T0.dim) { f3() }
                    Spacer()
                    GB(t: "cancel", c: T0.dim) { onCancel() }
                }
                Text("mọi loại file: deb · dylib · zip · xz · zst · ảnh · txt. Hoặc thả file vào Files → On My iPhone → ZEPHYS rồi bấm INBOX.")
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(T0.dim.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
        .presentationDetents([.height(360)])
    }
}

struct FR: View {
    let f: F0
    let a: () -> Void

    var body: some View {
        Button(action: a) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(f.ext == "deb" ? T0.wr : (H0.img(f.p) ? T0.ok : (f.bi ? T0.dim2 : T0.acc)))
                    .frame(width: 2.5, height: 26)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                VStack(alignment: .leading, spacing: 3) {
                    Text(f.nm)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(T0.ink)
                        .lineLimit(1)
                    if !f.dir.isEmpty {
                        Text(f.dir)
                            .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(T0.dim.opacity(0.85))
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 6)
                Text(H0.hm(f.s))
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(T0.dim.opacity(0.7))
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(Color.white.opacity(0.034))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(T0.ln, lineWidth: 1)
            )
        }
        .buttonStyle(PS())
    }
}

struct V4: View {
    @StateObject private var s = S0.s
    let r: R0
    let f: F0
    let back: () -> Void

    @State private var d: Data?
    @State private var txt = ""
    @State private var ed = false
    @State private var ld = true
    @State private var sv = false

    private var isTxt: Bool { H0.tx(d ?? Data()) != nil }
    private var isImg: Bool { H0.img(f.p) }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 9) {
                GB(t: "back") { back() }
                VStack(alignment: .leading, spacing: 3) {
                    Text(f.nm)
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundStyle(T0.ink)
                        .lineLimit(1)
                    Text(f.p)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(T0.dim)
                        .lineLimit(1)
                }
                Spacer(minLength: 4)
                Text(H0.hm(f.s))
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(T0.dim.opacity(0.7))
            }
            .padding(.horizontal, 20)

            if ld {
                HStack(spacing: 10) {
                    Capsule().fill(T0.acc).frame(width: 3, height: 16)
                    Text("LOADING")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .kerning(2)
                        .foregroundStyle(T0.dim)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                Spacer()
            } else if let dt = d {
                HStack(spacing: 7) {
                    if isImg {
                        BG(t: "image", c: T0.ok)
                    } else if isTxt {
                        BG(t: "text", c: T0.acc)
                    } else {
                        BG(t: "hex", c: T0.wr)
                    }
                    if isTxt {
                        GB(t: ed ? "cancel" : "edit", c: ed ? T0.dim : T0.acc) {
                            if ed { txt = H0.tx(dt) ?? "" }
                            withAnimation(.easeInOut(duration: 0.22)) { ed.toggle() }
                        }
                    }
                    if ed {
                        GB(t: sv ? "saving" : "save", c: T0.ok) {
                            sv = true
                            Task {
                                let ok = await s.sv(r, f.p, txt)
                                sv = false
                                if ok {
                                    d = Data(txt.utf8)
                                    withAnimation { ed = false }
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)

                if isImg {
                    IM(d: dt)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.34)))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(T0.ln, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                } else if let t = H0.tx(dt) {
                    ScrollView {
                        Text(t.isEmpty ? " " : t)
                            .font(.system(size: 12.5, weight: .regular, design: .monospaced))
                            .foregroundStyle(T0.ink)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                    }
                    .scrollIndicators(.visible)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.30)))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(T0.ln, lineWidth: 1))
                    .padding(.horizontal, 20)
                    .overlay {
                        if ed {
                            TextEditor(text: $txt)
                                .font(.system(size: 12.5, weight: .regular, design: .monospaced))
                                .foregroundStyle(T0.ink)
                                .scrollContentBackground(.hidden)
                                .padding(10)
                                .background(Color.black.opacity(0.62))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .padding(.horizontal, 20)
                                .transition(.opacity)
                        }
                    }
                    .padding(.bottom, 10)
                } else {
                    HX(d: dt)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.34)))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(T0.ln, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                }
            } else {
                CD {
                    VStack(alignment: .leading, spacing: 10) {
                        SR(t: "error", s: H0.hm(f.s))
                        HR()
                        Text("không tải được nội dung file — kiểm tra quyền token")
                            .font(T0.mono)
                            .foregroundStyle(T0.wr)
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
            }
        }
        .task {
            d = await s.rd(r, f.p)
            txt = H0.tx(d ?? Data()) ?? ""
            withAnimation(.easeOut(duration: 0.28)) { ld = false }
        }
    }
}

struct SH1: View {
    let t: String
    let p: String
    @Binding var v: String
    let ok: () -> Void
    let onCancel: () -> Void
    @FocusState private var fs: Bool

    var body: some View {
        ZStack {
            TX()
            VStack(alignment: .leading, spacing: 16) {
                Text(t.uppercased())
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .kerning(2.4)
                    .foregroundStyle(T0.dim)
                FD(p: p, v: $v, big: true)
                    .focused($fs)
                HStack(spacing: 10) {
                    GB(t: "cancel", c: T0.dim) { onCancel() }
                    PB(t: "ok", on: !v.isEmpty) { ok() }
                }
            }
            .padding(22)
        }
        .presentationDetents([.height(240)])
        .onAppear { fs = true }
    }
}
