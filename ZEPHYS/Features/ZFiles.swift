import SwiftUI

enum MO: String, Identifiable {
    case image, code, hex, audio
    var id: String { rawValue }
    var lb: String {
        switch self {
        case .image: return "ảnh"
        case .code: return "code"
        case .hex: return "hex"
        case .audio: return "audio"
        }
    }
}

struct V3: View {
    @StateObject private var s = S0.s
    let r: R0
    let back: () -> Void

    @State private var vw: F0?
    @State private var vm: MO = .code
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
    @State private var q = ""
    @State private var ex: EXI?

    private var list: [F0] {
        let a = (s.tr[r.key] ?? []).sorted { $0.p < $1.p }
        if q.isEmpty { return a }
        return a.filter { $0.p.lowercased().contains(q.lowercased()) }
    }

    private func later(_ f: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: f)
    }

    private func def(_ f: F0) -> MO {
        if H0.img(f.p) { return .image }
        if H0.aud(f.p) { return .audio }
        if f.bi { return .hex }
        return .code
    }

    private func open(_ f: F0, _ m: MO) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        vm = m
        withAnimation(.spring(response: 0.42, dampingFraction: 0.9)) { vw = f }
    }

    private func export(_ f: F0) {
        Task {
            guard let dd = await s.rd(r, f.p) else {
                s.er = "không tải được file để xuất"
                return
            }
            let u = FileManager.default.temporaryDirectory.appendingPathComponent(f.nm)
            try? FileManager.default.removeItem(at: u)
            do {
                try dd.write(to: u)
                ex = EXI(u: u)
            } catch {
                s.er = "không ghi được file tạm"
            }
        }
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
                V4(r: r, f: v, ini: vm) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { vw = nil }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)))
            } else {
                VStack(spacing: 11) {
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
                        GB(t: "reload", c: T0.dim) {
                            Task { await s.tree(r, true) }
                        }
                    }
                    .padding(.horizontal, 20)

                    HStack(spacing: 10) {
                        FD(p: "tìm file trong repo", v: $q)
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
                                HStack(spacing: 0) {
                                    Button {
                                        open(f, def(f))
                                    } label: {
                                        FR(f: f, staged: s.ch[r.key]?[f.p] != nil)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PS())

                                    Menu {
                                        Button("code editor") { open(f, .code) }
                                        Button("hex editor") { open(f, .hex) }
                                        if H0.img(f.p) {
                                            Button("xem ảnh") { open(f, .image) }
                                        }
                                        if H0.aud(f.p) {
                                            Button("nghe âm thanh") { open(f, .audio) }
                                        }
                                        Divider()
                                        Button("copy path") {
                                            UIPasteboard.general.string = f.p
                                            s.inf = "đã copy path · \(f.p)"
                                        }
                                        Button("copy raw link") {
                                            UIPasteboard.general.string =
                                                "https://raw.githubusercontent.com/\(r.o)/\(r.n)/\(r.br)/\(f.p)"
                                            s.inf = "đã copy link raw của \(f.nm)"
                                        }
                                        Button("xuất file (share)") { export(f) }
                                        Button("rename") {
                                            buf = f.nm
                                            rn = f
                                        }
                                        Button("xoá file", role: .destructive) {
                                            s.st(r, f.p, nil)
                                            s.inf = "đã đánh dấu xoá \(f.nm) · bấm UPDATE"
                                        }
                                    } label: {
                                        D3()
                                    }
                                    .padding(.trailing, 9)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                                        .fill(Color.white.opacity(0.034)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                                        .stroke(T0.ln, lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    }
                    .scrollIndicators(.visible)
                    .scrollDismissesKeyboard(.immediately)
                    .refreshable { await s.tree(r, true) }

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
        .sheet(item: $ex) { e in
            SC(u: e.u)
        }
        .sheet(isPresented: $nf) {
            SH1(t: "new file", p: "path/name.html", v: $buf) {
                let n = buf.trimmingCharacters(in: .whitespaces)
                if !n.isEmpty {
                    s.st(r, n, Data("".utf8))
                    s.inf = "đã tạo \(n) · bấm UPDATE để push"
                }
                nf = false
            } onCancel: { nf = false }
        }
        .sheet(isPresented: $nd) {
            SH1(t: "new folder", p: "assets", v: $buf2) {
                let n = buf2.trimmingCharacters(in: .whitespaces)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                if !n.isEmpty {
                    s.st(r, n + "/.gitkeep", Data())
                    s.inf = "đã tạo thư mục \(n) · bấm UPDATE để push"
                }
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
    var staged = false

    var body: some View {
        HStack(spacing: 11) {
            Rectangle()
                .fill(staged ? T0.wr : (f.ext == "deb" ? T0.wr :
                        (H0.img(f.p) ? T0.ok : (H0.aud(f.p) ? T0.acc : (f.bi ? T0.dim2 : T0.acc)))))
                .frame(width: 2.5, height: 26)
                .clipShape(RoundedRectangle(cornerRadius: 2))
            VStack(alignment: .leading, spacing: 3) {
                Text(f.nm)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(T0.ink)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    if !f.dir.isEmpty {
                        Text(f.dir)
                            .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(T0.dim.opacity(0.85))
                            .lineLimit(1)
                    }
                    if staged { BG(t: "staged", c: T0.wr) }
                }
            }
            Spacer(minLength: 6)
            Text(H0.hm(f.s))
                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                .foregroundStyle(T0.dim.opacity(0.7))
        }
        .padding(.leading, 13)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct V4: View {
    @StateObject private var s = S0.s
    let r: R0
    let f: F0
    let ini: MO
    let back: () -> Void

    @State private var d: Data?
    @State private var txt = ""
    @State private var ed = false
    @State private var ld = true
    @State private var sv = false
    @State private var md: MO = .code
    @State private var ex: EXI?

    private var code: String {
        guard let dd = d else { return "" }
        return H0.tx(dd) ?? String(decoding: dd, as: UTF8.self)
    }

    private var modes: [MO] {
        var o: [MO] = []
        if H0.img(f.p) { o.append(.image) }
        if H0.aud(f.p) { o.append(.audio) }
        if !H0.img(f.p) { o.append(.code) }
        o.append(.hex)
        return o
    }

    private func share() {
        guard let dd = d else { return }
        let u = FileManager.default.temporaryDirectory.appendingPathComponent(f.nm)
        try? FileManager.default.removeItem(at: u)
        do {
            try dd.write(to: u)
            ex = EXI(u: u)
        } catch {
            s.er = "không ghi được file tạm"
        }
    }

    private func save() {
        sv = true
        let t = txt
        Task {
            let ok = await s.sv(r, f.p, t)
            sv = false
            if ok {
                d = Data(t.utf8)
                withAnimation(.easeInOut(duration: 0.2)) { ed = false }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    var body: some View {
        VStack(spacing: 11) {
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
                if !ld { GB(t: "share", c: T0.acc) { share() } }
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
            } else if d != nil {
                HStack(spacing: 6) {
                    ForEach(modes) { m in
                        MC(t: m.lb, on: md == m) {
                            UISelectionFeedbackGenerator().selectionChanged()
                            if ed { txt = code }
                            withAnimation(.easeInOut(duration: 0.2)) {
                                md = m
                                ed = false
                            }
                        }
                    }
                    Spacer(minLength: 2)
                    if md == .code && !H0.img(f.p) {
                        GB(t: ed ? "hủy sửa" : "edit", c: ed ? T0.dim : T0.acc) {
                            if ed { txt = code }
                            withAnimation(.easeInOut(duration: 0.22)) { ed.toggle() }
                        }
                    }
                }
                .padding(.horizontal, 20)

                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(red: 0.024, green: 0.030, blue: 0.041))
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(T0.ln, lineWidth: 1)

                    if let dd = d {
                        if md == .image {
                            IM(d: dd)
                        } else if md == .audio {
                            AU(d: dd, ext: f.ext)
                        } else if md == .hex {
                            HX(d: dd)
                        } else if ed {
                            TextEditor(text: $txt)
                                .font(.system(size: 12.5, weight: .regular, design: .monospaced))
                                .foregroundStyle(T0.ink)
                                .scrollContentBackground(.hidden)
                                .background(Color(red: 0.024, green: 0.030, blue: 0.041))
                                .padding(8)
                        } else {
                            ScrollView {
                                Text(code.isEmpty ? " " : code)
                                    .font(.system(size: 12.5, weight: .regular, design: .monospaced))
                                    .foregroundStyle(T0.ink)
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(13)
                            }
                            .scrollIndicators(.visible)
                            .scrollDismissesKeyboard(.immediately)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
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
        .safeAreaInset(edge: .bottom) {
            if ed {
                HStack(spacing: 9) {
                    GB(t: "cancel", c: T0.dim) {
                        txt = code
                        withAnimation(.easeInOut(duration: 0.2)) { ed = false }
                    }
                    PB(t: sv ? "saving" : "save code", on: !sv) { save() }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 6)
                .background(T0.bg.opacity(0.97))
            }
        }
        .sheet(item: $ex) { e in
            SC(u: e.u)
        }
        .task {
            let dd = await s.rd(r, f.p)
            d = dd
            txt = (dd.flatMap { H0.tx($0) }) ?? dd.map { String(decoding: $0, as: UTF8.self) } ?? ""
            md = modes.contains(ini) ? ini : (modes.first ?? .code)
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
