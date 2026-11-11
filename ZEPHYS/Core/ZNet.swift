import Foundation

struct GE: LocalizedError {
    let m: String
    var errorDescription: String? { m }
}

struct R0: Identifiable, Hashable {
    let id: Int
    let o: String
    let n: String
    let br: String
    let up: Double
    let ds: String
    var key: String { o + "/" + n }
    var full: String { o + "/" + n }
}

struct F0: Identifiable, Hashable {
    let p: String
    let s: Int
    var id: String { p }
    var nm: String { (p as NSString).lastPathComponent }
    var dir: String {
        let d = (p as NSString).deletingLastPathComponent
        return d.isEmpty ? "" : d
    }
    var ext: String { (p as NSString).pathExtension.lowercased() }
    var bi: Bool {
        if ["deb", "zip", "png", "jpg", "jpeg", "gif", "pdf", "ico", "gz", "xz", "zst", "ttf", "otf", "webp", "mp4", "mov", "dylib", "ipa"].contains(ext) { return true }
        return false
    }
}

private struct JU: Decodable { let login: String }
private struct JO: Decodable { let login: String }
private struct JR: Decodable {
    let id: Int
    let name: String
    let owner: JO
    let defaultBranch: String
    let updatedAt: String
    let description: String?
}
private struct JT: Decodable { let tree: [JN] }
private struct JN: Decodable { let path: String; let type: String; let size: Int? }
private struct JC: Decodable { let content: String?; let encoding: String?; let sha: String; let size: Int }
private struct JB: Decodable { let content: String; let encoding: String }
private struct JS: Decodable { let sha: String }
private struct JRF: Decodable { let object: JS }
private struct JCM: Decodable { let sha: String; let tree: JS }
private struct JP: Decodable { let htmlUrl: String?; let status: String? }
private struct JBd: Decodable { let status: String? }

final class N0 {
    static let s = N0()
    var tk = ""

    private let jd: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    private func rq(_ p: String, _ m: String = "GET", _ b: Any? = nil) async throws -> Data {
        let full = H1.bs + p
        guard let u = URL(string: full) else { throw GE(m: "bad url") }
        var r = URLRequest(url: u)
        r.httpMethod = m
        r.timeoutInterval = 70
        r.setValue("Bearer " + tk, forHTTPHeaderField: "Authorization")
        r.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        r.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        r.setValue(H1.ua, forHTTPHeaderField: "User-Agent")
        if let b = b {
            r.httpBody = try? JSONSerialization.data(withJSONObject: b)
            r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (d, s) = try await URLSession.shared.data(for: r)
        guard let h = s as? HTTPURLResponse else { throw GE(m: "no response") }
        guard h.statusCode < 300 else {
            var msg = "HTTP \(h.statusCode)"
            if let o = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any],
               let e = o["message"] as? String { msg = e }
            throw GE(m: msg)
        }
        return d
    }

    private func en(_ p: String) -> String {
        var a = CharacterSet.urlPathAllowed
        a.insert(charactersIn: "._-")
        return p.addingPercentEncoding(withAllowedCharacters: a) ?? p
    }

    func me() async throws -> String {
        let d = try await rq("/user")
        return try jd.decode(JU.self, from: d).login
    }

    func repos() async throws -> [R0] {
        let d = try await rq("/user/repos?per_page=100&sort=updated&affiliation=owner")
        let a = try jd.decode([JR].self, from: d)
        let f = ISO8601DateFormatter()
        return a.map { r in
            R0(id: r.id, o: r.owner.login, n: r.name, br: r.defaultBranch,
               up: f.date(from: r.updatedAt)?.timeIntervalSince1970 ?? 0,
               ds: r.description ?? "")
        }
    }

    func tree(_ o: String, _ n: String, _ b: String) async throws -> [F0] {
        let d = try await rq("/repos/\(o)/\(n)/git/trees/\(b)?recursive=1")
        let t = try jd.decode(JT.self, from: d)
        return t.tree.filter { $0.type == "blob" }.map { F0(p: $0.path, s: $0.size ?? 0) }
    }

    func blob(_ o: String, _ n: String, _ sha: String) async throws -> Data {
        let d = try await rq("/repos/\(o)/\(n)/git/blobs/\(sha)")
        let b = try jd.decode(JB.self, from: d)
        return Data(base64Encoded: b.content.replacingOccurrences(of: "\n", with: "")) ?? Data()
    }

    func file(_ o: String, _ n: String, _ p: String, _ ref: String) async throws -> Data {
        let d = try await rq("/repos/\(o)/\(n)/contents/\(en(p))?ref=\(ref)")
        let c = try jd.decode(JC.self, from: d)
        if let s = c.content, !s.isEmpty,
           let b = Data(base64Encoded: s.replacingOccurrences(of: "\n", with: "")) {
            return b
        }
        return try await blob(o, n, c.sha)
    }

    func mk(_ name: String, _ ds: String) async throws -> R0 {
        let d = try await rq("/user/repos", "POST", [
            "name": name,
            "description": ds,
            "private": false,
            "auto_init": true,
            "has_issues": true,
            "has_wiki": false,
        ])
        let r = try jd.decode(JR.self, from: d)
        let f = ISO8601DateFormatter()
        return R0(id: r.id, o: r.owner.login, n: r.name, br: r.defaultBranch,
                  up: f.date(from: r.updatedAt)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970,
                  ds: r.description ?? "")
    }

    func cm(_ o: String, _ n: String, _ br: String, _ msg: String, _ ops: [(String, Data?)]) async throws {
        if ops.isEmpty { return }
        let rd = try await rq("/repos/\(o)/\(n)/git/ref/heads/\(br)")
        let head = try jd.decode(JRF.self, from: rd).object.sha
        let cd = try await rq("/repos/\(o)/\(n)/git/commits/\(head)")
        let base = try jd.decode(JCM.self, from: cd).tree.sha
        var nodes: [[String: Any]] = []
        for (p, d) in ops {
            if let d = d {
                let bd = try await rq("/repos/\(o)/\(n)/git/blobs", "POST", [
                    "content": d.base64EncodedString(),
                    "encoding": "base64",
                ])
                let sha = try jd.decode(JS.self, from: bd).sha
                nodes.append(["path": p, "mode": "100644", "type": "blob", "sha": sha])
            } else {
                nodes.append(["path": p, "mode": "100644", "type": "blob", "sha": NSNull()])
            }
        }
        let td = try await rq("/repos/\(o)/\(n)/git/trees", "POST", [
            "base_tree": base,
            "tree": nodes,
        ])
        let tree = try jd.decode(JS.self, from: td).sha
        let nc = try await rq("/repos/\(o)/\(n)/git/commits", "POST", [
            "message": msg,
            "tree": tree,
            "parents": [head],
        ])
        let cm = try jd.decode(JS.self, from: nc).sha
        _ = try await rq("/repos/\(o)/\(n)/git/refs/heads/\(br)", "PATCH", ["sha": cm])
    }

    func pg(_ o: String, _ n: String, _ br: String) async throws {
        let body: [String: Any] = ["source": ["branch": br, "path": "/"]]
        do {
            _ = try await rq("/repos/\(o)/\(n)/pages", "POST", body)
        } catch {
            _ = try await rq("/repos/\(o)/\(n)/pages", "PUT", body)
        }
    }

    func pgw(_ o: String, _ n: String) async -> String? {
        for _ in 0..<25 {
            if let d = try? await rq("/repos/\(o)/\(n)/pages") {
                let p = try? jd.decode(JP.self, from: d)
                let st = p?.status ?? ""
                if st == "built" || st == "building" {
                    if let h = p?.htmlUrl { return h + "/" }
                }
                if let h = p?.htmlUrl, st.isEmpty { return h + "/" }
            }
            try? await Task.sleep(nanoseconds: 3_000_000_000)
        }
        return nil
    }

    func change(_ o: String, _ n: String, _ br: String, _ p: String, _ d: Data, _ msg: String) async throws {
        var last: Error?
        for i in 0..<3 {
            do {
                try await cm(o, n, br, msg, [(p, Optional(d))])
                return
            } catch {
                last = error
                if i < 2 { try? await Task.sleep(nanoseconds: 800_000_000) }
            }
        }
        throw last ?? GE(m: "commit failed")
    }
}
