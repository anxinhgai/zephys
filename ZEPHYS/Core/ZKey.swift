import Foundation
import Security

enum K0 {
    private static let svc = H1.b("Y29tLnplcGh5cy5rZXk=")
    private static let acc = H1.b("enAuYXV0aA==")

    static func g() -> String {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: svc,
            kSecAttrAccount as String: acc,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var r: CFTypeRef?
        guard SecItemCopyMatching(q as CFDictionary, &r) == errSecSuccess,
              let d = r as? Data,
              let s = String(data: d, encoding: .utf8) else { return "" }
        return s
    }

    static func s(_ v: String) {
        cl()
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: svc,
            kSecAttrAccount as String: acc,
            kSecValueData as String: Data(v.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]
        SecItemAdd(q as CFDictionary, nil)
    }

    static func cl() {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: svc,
            kSecAttrAccount as String: acc,
        ]
        SecItemDelete(q as CFDictionary)
    }
}
