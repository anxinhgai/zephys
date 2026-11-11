import Foundation
import CryptoKit
import ZIPFoundation

enum H1 {
    static func b(_ s: String) -> String {
        guard let d = Data(base64Encoded: s), let r = String(data: d, encoding: .utf8) else { return "" }
        return r
    }
    static let ua = b("WkVQSFlT")
    static let bs = b("aHR0cHM6Ly9hcGkuZ2l0aHViLmNvbQ==")
    static let gl = b("aHR0cHM6Ly9naXRodWIuY29t")
}

enum H0 {
    static func sh(_ d: Data) -> String {
        SHA256.hash(data: d).map { String(format: "%02x", $0) }.joined()
    }

    static func sl(_ s: String) -> String {
        let a = s.lowercased().map { c -> Character in
            if c.isLetter || c.isNumber || c == "-" || c == "." || c == "_" { return c }
            return "-"
        }
        var r = String(a)
        while r.contains("--") { r = r.replacingOccurrences(of: "--", with: "-") }
        r = r.trimmingCharacters(in: CharacterSet(charactersIn: "-._"))
        return r.isEmpty ? "zephys-site" : String(r.prefix(90))
    }

    static func hm(_ n: Int) -> String {
        if n < 1024 { return "\(n) B" }
        if n < 1048576 { return String(format: "%.0f KB", Double(n) / 1024) }
        return String(format: "%.1f MB", Double(n) / 1048576)
    }

    static let ige: Set<String> = ["png", "jpg", "jpeg", "gif", "heic", "heif", "webp", "bmp", "tiff", "ico"]

    static func img(_ p: String) -> Bool {
        ige.contains((p as NSString).pathExtension.lowercased())
    }

    static let iae: Set<String> = ["mp3", "m4a", "wav", "caf", "aac", "aiff", "aif", "flac", "opus", "ogg", "amr"]

    static func aud(_ p: String) -> Bool {
        iae.contains((p as NSString).pathExtension.lowercased())
    }

    static func ib() -> URL {
        let d = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }

    static func ibf() -> [URL] {
        var o: [URL] = []
        let e = FileManager.default.enumerator(at: ib(), includingPropertiesForKeys: [.isDirectoryKey], options: [])
        while let u = e?.nextObject() as? URL {
            var d: ObjCBool = false
            FileManager.default.fileExists(atPath: u.path, isDirectory: &d)
            if !d.boolValue { o.append(u) }
        }
        return o.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    static func save(_ d: Data, _ nm: String) -> String? {
        let base = (nm as NSString).deletingPathExtension
        let ext = (nm as NSString).pathExtension
        var name = nm
        var i = 2
        while FileManager.default.fileExists(atPath: ib().appendingPathComponent(name).path) {
            name = ext.isEmpty ? "\(base)-\(i)" : "\(base)-\(i).\(ext)"
            i += 1
        }
        let u = ib().appendingPathComponent(name)
        do { try d.write(to: u) } catch { return nil }
        return name
    }

    static func take(_ u: URL) -> String? {
        let sc = u.startAccessingSecurityScopedResource()
        defer { if sc { u.stopAccessingSecurityScopedResource() } }
        let d = ib()
        var nm = u.lastPathComponent
        var t = d.appendingPathComponent(nm)
        var i = 1
        while FileManager.default.fileExists(atPath: t.path) {
            nm = "\(i)-\(u.lastPathComponent)"
            t = d.appendingPathComponent(nm)
            i += 1
        }
        do {
            try FileManager.default.copyItem(at: u, to: t)
            return nm
        } catch {
            return nil
        }
    }

    static func pick(_ u: URL) async -> Data? {
        let sc = u.startAccessingSecurityScopedResource()
        defer { if sc { u.stopAccessingSecurityScopedResource() } }
        if let d = try? Data(contentsOf: u), !d.isEmpty { return d }
        if let v = try? u.resourceValues(forKeys: [.isUbiquitousItemKey, .ubiquitousItemDownloadingStatusKey]),
           v.isUbiquitousItem == true {
            try? FileManager.default.startDownloadingUbiquitousItem(at: u)
            for _ in 0..<30 {
                try? await Task.sleep(nanoseconds: 400_000_000)
                if let d = try? Data(contentsOf: u), !d.isEmpty { return d }
            }
        }
        let t = FileManager.default.temporaryDirectory.appendingPathComponent("zp-pick-" + u.lastPathComponent)
        try? FileManager.default.removeItem(at: t)
        var e: NSError?
        NSFileCoordinator().coordinate(readingItemAt: u, options: [], error: &e) { x in
            try? FileManager.default.copyItem(at: x, to: t)
        }
        if let d = try? Data(contentsOf: t), !d.isEmpty {
            try? FileManager.default.removeItem(at: t)
            return d
        }
        return nil
    }

    static func rf(_ u: URL) -> [String: Data] {
        let sc = u.startAccessingSecurityScopedResource()
        defer { if sc { u.stopAccessingSecurityScopedResource() } }
        var o: [String: Data] = [:]
        let e = FileManager.default.enumerator(at: u, includingPropertiesForKeys: [.isDirectoryKey], options: [])
        while let x = e?.nextObject() as? URL {
            if x.lastPathComponent == ".git" || x.lastPathComponent == ".DS_Store" { continue }
            var isD: ObjCBool = false
            FileManager.default.fileExists(atPath: x.path, isDirectory: &isD)
            if isD.boolValue { continue }
            if let d = try? Data(contentsOf: x) {
                let r = x.path.replacingOccurrences(of: u.path, with: "")
                let p = String(r.dropFirst())
                if !p.isEmpty { o[p] = d }
            }
        }
        return o
    }

    static func tx(_ d: Data) -> String? {
        if d.isEmpty { return "" }
        let k = d.prefix(4096)
        if k.contains(0) { return nil }
        return String(data: d, encoding: .utf8)
    }

    static func tmp(_ tag: String) -> URL {
        let u = FileManager.default.temporaryDirectory.appendingPathComponent("zp-\(tag)-\(Int(Date().timeIntervalSince1970))")
        try? FileManager.default.createDirectory(at: u, withIntermediateDirectories: true)
        return u
    }

    static func un(_ s: URL, _ t: URL) throws {
        let a = try Archive(url: s, accessMode: .read)
        for e in a {
            if e.path.contains("__MACOSX") || e.path.hasPrefix(".") || e.path.contains("/.") { continue }
            let o = t.appendingPathComponent(e.path)
            if e.type == .directory {
                try FileManager.default.createDirectory(at: o, withIntermediateDirectories: true)
                continue
            }
            try FileManager.default.createDirectory(at: o.deletingLastPathComponent(), withIntermediateDirectories: true)
            _ = try a.extract(e, to: o)
        }
    }

    static func cp(_ s: URL, _ t: URL) throws {
        let e = FileManager.default.enumerator(at: s, includingPropertiesForKeys: [.isDirectoryKey], options: [])
        while let u = e?.nextObject() as? URL {
            if u.lastPathComponent == ".git" { continue }
            let r = u.path.replacingOccurrences(of: s.path, with: "")
            let p = t.appendingPathComponent(String(r.dropFirst()))
            let d = (try? u.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            if d {
                try FileManager.default.createDirectory(at: p, withIntermediateDirectories: true)
            } else {
                try FileManager.default.createDirectory(at: p.deletingLastPathComponent(), withIntermediateDirectories: true)
                if FileManager.default.fileExists(atPath: p.path) { try FileManager.default.removeItem(at: p) }
                try FileManager.default.copyItem(at: u, to: p)
            }
        }
    }

    static func rd(_ s: URL) -> [String: Data] {
        var o: [String: Data] = [:]
        var total = 0
        let e = FileManager.default.enumerator(at: s, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey], options: [])
        while let u = e?.nextObject() as? URL {
            let v = try? u.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey])
            if v?.isDirectory == true { continue }
            let n = (v?.fileSize ?? 0)
            if n > 24 * 1024 * 1024 { continue }
            if total + n > 90 * 1024 * 1024 { break }
            guard let d = try? Data(contentsOf: u) else { continue }
            let r = u.path.replacingOccurrences(of: s.path, with: "")
            let p = String(r.dropFirst())
            if p.isEmpty || p.hasPrefix(".git/") || p == ".git" { continue }
            if (p as NSString).lastPathComponent == ".DS_Store" { continue }
            if p.contains("__MACOSX") { continue }
            o[p] = d
            total += n
        }
        return o
    }

    static func kd(_ f: [String: Data]) -> Int {
        if f.keys.contains(where: { $0.hasSuffix(".deb") }) { return 1 }
        if f.keys.contains(where: { $0 == "Packages" || $0.hasSuffix("/Packages") }) { return 1 }
        if f.keys.contains(where: { $0 == "index.html" || $0.hasSuffix("/index.html") }) { return 2 }
        return 1
    }

    static func kf(_ f: [F0]) -> Int {
        if f.contains(where: { $0.ext == "deb" }) { return 1 }
        if f.contains(where: { $0.nm == "Packages" }) { return 1 }
        if f.contains(where: { $0.p == "index.html" }) { return 2 }
        return 1
    }

    static func pk(_ f: [String: Data]) -> [String: Data]? {
        var o = f
        let debs = o.keys.filter { $0.hasSuffix(".deb") }.sorted()
        if debs.isEmpty { return nil }
        if o.keys.contains("Packages") { return nil }
        var b: [String] = []
        for p in debs {
            guard let d = o[p] else { continue }
            let n = (p as NSString).lastPathComponent
            let s = (n as NSString).deletingPathExtension
            let a = s.split(separator: "_").map(String.init)
            let pk = a.count >= 3 ? a[0].replacingOccurrences(of: "%2B", with: "+") : s
            let vr = a.count >= 3 ? a[1] : "1.0"
            let ar = a.count >= 3 ? a[2] : "iphoneos-arm64e"
            b.append("Package: \(pk)\nVersion: \(vr)\nArchitecture: \(ar)\nMaintainer: ZEPHYS\nSection: Tweaks\nDescription: \(pk)\nFilename: \(p)\nSize: \(d.count)\nSHA256: \(sh(d))")
        }
        o["Packages"] = (b.joined(separator: "\n\n") + "\n").data(using: .utf8)
        return o
    }

    static func nl(_ s: Double) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM HH:mm"
        return f.string(from: Date(timeIntervalSince1970: s))
    }
}
