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
        let e = FileManager.default.enumerator(at: s, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
        while let u = e?.nextObject() as? URL {
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
        let e = FileManager.default.enumerator(at: s, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey], options: [.skipsHiddenFiles])
        while let u = e?.nextObject() as? URL {
            let v = try? u.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey])
            if v?.isDirectory == true { continue }
            let n = (v?.fileSize ?? 0)
            if n > 24 * 1024 * 1024 { continue }
            if total + n > 90 * 1024 * 1024 { break }
            guard let d = try? Data(contentsOf: u) else { continue }
            let r = u.path.replacingOccurrences(of: s.path, with: "")
            let p = String(r.dropFirst())
            if p.isEmpty || p.hasPrefix(".") { continue }
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
