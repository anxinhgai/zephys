import SwiftUI
import UniformTypeIdentifiers

struct V3: View {
    @StateObject private var s = S0.s
    let r: R0
    let back: () -> Void

    @State private var vw: F0?
    @State private var nf = false
    @State private var nd = false
    @State private var up = false
    @State private var rn: F0?
    @State private var buf = ""
    @State private var buf2 = ""

    private var list: [F0] {
        (s.tr[r.key] ?? []).sorted { $0.p < $1.p }
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
                        GB(t: "upload") { up = true }
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
                                        Task { await s.rn(r, f.p, f.p + ".zpdel") }
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
        .task { await s.tree(r) }
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
        .fileImporter(isPresented: $up, allowedContentTypes: [.item], allowsMultipleSelection: true) { res in
            guard case let .success(urls) = res else { return }
            Task {
                for u in urls {
                    let sc = u.startAccessingSecurityScopedResource()
                    defer { if sc { u.stopAccessingSecurityScopedResource() } }
                    guard let d = try? Data(contentsOf: u) else { continue }
                    let base = (s.tr[r.key] ?? []).contains { $0.p.hasPrefix("debs/") } ? "debs/" : ""
                    s.st(r, base + u.lastPathComponent, d)
                }
            }
        }
    }
}

struct FR: View {
    let f: F0
    let a: () -> Void

    var body: some View {
        Button(action: a) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(f.ext == "deb" ? T0.wr : (f.bi ? T0.dim2 : T0.acc))
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

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                GB(t: "back") { back() }
                VStack(alignment: .leading, spacing: 3) {
                    Text(f.nm)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(T0.ink)
                        .lineLimit(1)
                    Text(f.p)
                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(T0.dim)
                        .lineLimit(1)
                }
                Spacer()
                if H0.tx(d ?? Data()) != nil || d == nil {
                    GB(t: ed ? "cancel" : "edit", c: ed ? T0.dim : T0.acc) {
                        if ed { txt = H0.tx(d ?? Data()) ?? "" }
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
                .padding(.top, 20)
                Spacer()
            } else if let dt = d, let t = H0.tx(dt) {
                ScrollView {
                    Text(t.isEmpty ? " " : t)
                        .font(.system(size: 12.5, weight: .regular, design: .monospaced))
                        .foregroundStyle(T0.ink)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                }
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.30))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(T0.ln, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .overlay(alignment: .topTrailing) {
                    if ed {
                        TextEditor(text: $txt)
                            .font(.system(size: 12.5, weight: .regular, design: .monospaced))
                            .foregroundStyle(T0.ink)
                            .scrollContentBackground(.hidden)
                            .padding(10)
                            .background(Color.black.opacity(0.55))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                    }
                }
            } else {
                CD {
                    VStack(alignment: .leading, spacing: 10) {
                        SR(t: "binary", s: H0.hm(f.s))
                        HR()
                        Text("không hiển thị nội dung nhị phân — sửa trực tiếp không hỗ trợ")
                            .font(T0.mono)
                            .foregroundStyle(T0.dim)
                        if f.ext == "deb" {
                            Text("file deb: upload bản mới để thay thế")
                                .font(T0.mono)
                                .foregroundStyle(T0.wr)
                        }
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
        .presentationDetents([.height(230)])
        .presentationBackground(T0.bg)
        .onAppear { fs = true }
    }
}
