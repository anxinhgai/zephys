import SwiftUI

struct OP: Identifiable {
    let p: String
    let d: Data?
    var id: String { p }
}

@MainActor
final class S0: ObservableObject {
    static let s = S0()

    struct SS: Identifiable {
        let id = UUID()
        let t: String
        var k: Int
    }

    struct DX {
        var kd: Int
        var fl: [String: Data]
        var frm: String
        var sz: Int { fl.values.reduce(0) { $0 + $1.count } }
    }

    @Published var tk = ""
    @Published var lg = ""
    @Published var rp: [R0] = []
    @Published var wb: [R0] = []
    @Published var bs = false
    @Published var bt = true
    @Published var er: String?
    @Published var tr: [String: [F0]] = [:]
    @Published var ch: [String: [String: OP]] = [:]
    @Published var stp: [SS] = []
    @Published var res: String?
    @Published var dx: DX?
    @Published var nm = ""
    @Published var tick = 0
    @Published var inf: String?

    func b00() async {
        let t = K0.g()
        if !t.isEmpty {
            tk = t
            N0.s.tk = t
            do {
                lg = try await N0.s.me()
                await load()
            } catch {
                tk = ""
                N0.s.tk = ""
                K0.cl()
            }
        }
        try? await Task.sleep(nanoseconds: 1_100_000_000)
        withAnimation(.easeInOut(duration: 0.45)) { bt = false }
    }

    func ck(_ t: String) async -> Bool {
        bs = true
        defer { bs = false }
        N0.s.tk = t
        do {
            let l = try await N0.s.me()
            K0.s(t)
            tk = t
            lg = l
            await load()
            return true
        } catch {
            er = (error as? GE)?.m ?? error.localizedDescription
            N0.s.tk = ""
            return false
        }
    }

    func out() {
        K0.cl()
        tk = ""
        lg = ""
        N0.s.tk = ""
        rp = []
        wb = []
        tr = [:]
        ch = [:]
        er = nil
        res = nil
        dx = nil
    }

    func load() async {
        do {
            let a = try await N0.s.repos()
            var r: [R0] = []
            var w: [R0] = []
            var cache: [String: [F0]] = [:]
            await withTaskGroup(of: (R0, Int, [F0]?).self) { g in
                for x in a.prefix(40) {
                    let client = N0.s
                    g.addTask {
                        let f = try? await client.tree(x.o, x.n, x.br)
                        return (x, H0.kf(f ?? []), f)
                    }
                }
                for await (x, k, f) in g {
                    if let f = f, !f.isEmpty { cache[x.key] = f }
                    if k == 2 { w.append(x) } else { r.append(x) }
                }
            }
            tr = cache
            rp = r.sorted { $0.up > $1.up }
            wb = w.sorted { $0.up > $1.up }
            tick += 1
        } catch {
            er = (error as? GE)?.m ?? error.localizedDescription
        }
    }

    func tree(_ r: R0, _ force: Bool = false) async {
        if !force, let c = tr[r.key], !c.isEmpty { return }
        if let f = try? await N0.s.tree(r.o, r.n, r.br) { tr[r.key] = f }
    }

    func rd(_ r: R0, _ p: String) async -> Data? {
        try? await N0.s.file(r.o, r.n, p, r.br)
    }

    func st(_ r: R0, _ p: String, _ d: Data?) {
        var m = ch[r.key] ?? [:]
        m[p] = OP(p: p, d: d)
        ch[r.key] = m
    }

    func drop(_ r: R0, _ p: String) {
        var m = ch[r.key] ?? [:]
        m.removeValue(forKey: p)
        ch[r.key] = m
    }

    func cnt(_ r: R0) -> Int { (ch[r.key] ?? [:]).count }

    func push(_ r: R0) async -> Bool {
        let m = ch[r.key] ?? [:]
        if m.isEmpty { inf = "không có thay đổi nào để cập nhật"; return true }
        bs = true
        defer { bs = false }
        er = nil
        do {
            let ops = m.values.map { ($0.p, $0.d) }.sorted { $0.0 < $1.0 }
            try await N0.s.cm(r.o, r.n, r.br, "ZEPHYS update", ops)
            ch[r.key] = [:]
            await tree(r, true)
            inf = "đã cập nhật \(r.n) · \(ops.count) file lên github"
            await load()
            return true
        } catch {
            er = (error as? GE)?.m ?? error.localizedDescription
            return false
        }
    }

    func mk2(_ n: String, _ ds: String) async -> Bool {
        bs = true
        defer { bs = false }
        er = nil
        do {
            let r = try await N0.s.mk(n, ds)
            inf = "đã tạo repo \(r.full)"
            await load()
            return true
        } catch {
            er = (error as? GE)?.m ?? error.localizedDescription
            return false
        }
    }

    func sv(_ r: R0, _ p: String, _ t: String) async -> Bool {
        bs = true
        defer { bs = false }
        er = nil
        let dd = Data(t.utf8)
        do {
            try await N0.s.change(r.o, r.n, r.br, p, dd, "ZEPHYS edit " + (p as NSString).lastPathComponent)
            if var c = tr[r.key], let i = c.firstIndex(where: { $0.p == p }) {
                c[i] = F0(p: p, s: dd.count)
                tr[r.key] = c
            } else {
                await tree(r, true)
            }
            inf = "đã lưu code · \(p)"
            return true
        } catch {
            er = "save thất bại: " + ((error as? GE)?.m ?? error.localizedDescription)
            return false
        }
    }

    func rn(_ r: R0, _ f: String, _ t: String) async {
        let all = tr[r.key] ?? []
        let hit = all.filter { $0.p == f || $0.p.hasPrefix(f + "/") }
        if hit.isEmpty { return }
        bs = true
        defer { bs = false }
        inf = "đang đổi tên \(hit.count) file"
        for x in hit {
            guard let d = await rd(r, x.p) else { continue }
            let np = x.p == f ? t : t + String(x.p.dropFirst(f.count))
            st(r, np, d)
            st(r, x.p, nil)
        }
    }

    func cnt2(_ us: [URL]) async {
        bs = true
        defer { bs = false }
        var files: [String: Data] = [:]
        var tag = "site"
        for u in us {
            let sc = u.startAccessingSecurityScopedResource()
            defer { if sc { u.stopAccessingSecurityScopedResource() } }
            let t = H0.tmp("imp")
            let ext = u.pathExtension.lowercased()
            var dir = false
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: u.path, isDirectory: &isDir) { dir = isDir.boolValue }
            if ext == "zip" {
                try? H0.un(u, t)
                tag = u.deletingPathExtension().lastPathComponent
            } else if dir {
                try? H0.cp(u, t)
                tag = u.lastPathComponent
            } else {
                let f = t.appendingPathComponent(u.lastPathComponent)
                try? FileManager.default.createDirectory(at: t, withIntermediateDirectories: true)
                if FileManager.default.fileExists(atPath: f.path) { try? FileManager.default.removeItem(at: f) }
                try? FileManager.default.copyItem(at: u, to: f)
                tag = u.deletingPathExtension().lastPathComponent
            }
            var f = H0.rd(t)
            let roots = Set(f.keys.compactMap { $0.split(separator: "/").first.map(String.init) })
            if roots.count == 1, let r0 = roots.first, f.keys.contains(where: { $0.contains("/") }), f[r0] == nil {
                var g: [String: Data] = [:]
                for (k, v) in f { g[String(k.dropFirst(r0.count + 1))] = v }
                f = g
            }
            files.merge(f) { a, _ in a }
            try? FileManager.default.removeItem(at: t)
        }
        if files.isEmpty { er = "no readable file found"; return }
        dx = DX(kd: H0.kd(files), fl: files, frm: tag)
        nm = H0.sl(tag)
        inf = "đã đọc \(files.count) file · sẵn sàng đăng"
    }

    func drop2(_ us: [URL]) {
        for u in us { try? FileManager.default.removeItem(at: u) }
    }

    func up(_ r: R0, _ us: [URL], _ pre: String) async {
        bs = true
        var n = 0
        var bad: [String] = []
        let pfx = pre.isEmpty ? "" : (pre.hasSuffix("/") ? pre : pre + "/")
        for u in us {
            var isD: ObjCBool = false
            let ex = FileManager.default.fileExists(atPath: u.path, isDirectory: &isD)
            if ex, isD.boolValue {
                for (k, v) in H0.rf(u) {
                    st(r, pfx + k, v)
                    n += 1
                }
            } else if let d = await H0.pick(u) {
                st(r, pfx + u.lastPathComponent, d)
                n += 1
            } else {
                bad.append(u.lastPathComponent)
            }
        }
        bs = false
        if !bad.isEmpty {
            er = "không đọc được: " + bad.joined(separator: ", ")
        } else if n == 0 {
            er = "không có file nào được thêm"
        } else {
            inf = "đã thêm \(n) file · bấm UPDATE để push"
        }
    }

    func go() async {
        guard let d = dx else { return }
        bs = true
        res = nil
        er = nil
        stp = [SS(t: "SCAN", k: 2), SS(t: "REPOSITORY", k: 0), SS(t: "UPLOAD", k: 0), SS(t: "PAGES", k: 0), SS(t: "LIVE", k: 0)]
        var fl = d.fl
        if d.kd == 1, let g = H0.pk(fl) {
            fl = g
            stp[0] = SS(t: "PACKAGES", k: 2)
        }
        do {
            stp[1].k = 1
            let r = try await N0.s.mk(H0.sl(nm), d.kd == 1 ? "ZEPHYS APT repository" : "ZEPHYS website")
            stp[1].k = 2
            stp[2].k = 1
            let ops = fl.map { ($0.key, Optional($0.value)) }.sorted { $0.0 < $1.0 }
            var i = 0
            while i < ops.count {
                let sl = Array(ops[i..<min(i + 45, ops.count)])
                try await N0.s.cm(r.o, r.n, r.br, "ZEPHYS publish", sl)
                i += 45
            }
            stp[2].k = 2
            stp[3].k = 1
            try? await N0.s.pg(r.o, r.n, r.br)
            stp[3].k = 2
            stp[4].k = 1
            let u = await N0.s.pgw(r.o, r.n)
            res = u ?? "https://\(r.o).github.io/\(r.n)/"
            stp[4].k = 2
            dx = nil
            await load()
        } catch {
            if let i = stp.firstIndex(where: { $0.k == 1 }) { stp[i].k = 3 }
            er = (error as? GE)?.m ?? error.localizedDescription
        }
        bs = false
    }
}
