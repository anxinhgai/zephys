import SwiftUI

@main
struct ZM: App {
    var body: some Scene {
        WindowGroup {
            V9()
                .preferredColorScheme(.dark)
                .tint(T0.acc)
        }
    }
}

struct V9: View {
    @StateObject private var s = S0.s

    var body: some View {
        ZStack {
            TX()
            if s.bt {
                V8(tx: "handshake")
                    .transition(.opacity)
            } else if s.tk.isEmpty {
                V0()
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
            } else {
                V1()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.42), value: s.bt)
        .animation(.easeInOut(duration: 0.42), value: s.tk.isEmpty)
        .task { await s.b00() }
    }
}

struct V0: View {
    @StateObject private var s = S0.s
    @State private var t = ""
    @State private var w = false
    @FocusState private var f: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            WM(s: "github publish console")
                .padding(.bottom, 34)

            CD {
                VStack(alignment: .leading, spacing: 14) {
                    SR(t: "access token", s: "required")
                    FD(p: "ghp_ · · · · · · · ·", v: $t, sec: true, big: true)
                        .focused($f)
                    HStack(spacing: 9) {
                        GB(t: "paste") {
                            if let v = UIPasteboard.general.string { t = v }
                        }
                        GB(t: "clear") { t = "" }
                        Spacer()
                        BG(t: "keychain", c: T0.ok)
                    }
                    HR()
                    Text("scopes: repo · workflow · pages")
                        .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                        .kerning(0.8)
                        .foregroundStyle(T0.dim)
                }
            }

            if let e = s.er {
                Text(e)
                    .font(T0.mono)
                    .foregroundStyle(T0.rd)
                    .padding(.top, 14)
                    .transition(.opacity)
            }

            PB(t: w ? "verifying" : "authorize", on: t.count > 12 && !w) {
                w = true
                Task {
                    let ok = await s.ck(t.trimmingCharacters(in: .whitespacesAndNewlines))
                    withAnimation { w = false }
                    if ok { UINotificationFeedbackGenerator().notificationOccurred(.success) }
                }
            }
            .padding(.top, 18)

            HStack {
                Text("token chỉ lưu trong keychain máy này")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(T0.dim.opacity(0.8))
                Spacer()
            }
            .padding(.top, 12)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 22)
        .onAppear { f = true }
    }
}

struct V1: View {
    @StateObject private var s = S0.s
    @State private var tab = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                WM(s: s.lg.isEmpty ? "console" : s.lg)
                Spacer()
                GB(t: "sync") {
                    Task { await s.load() }
                }
                GB(t: "out", c: T0.dim) { s.out() }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)

            Group {
                if tab == 0 {
                    V2(k: 1)
                } else if tab == 1 {
                    V2(k: 2)
                } else {
                    V5()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TB(i: $tab, t: ["Repo", "Web", "Push"])
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 6)
        }
        .overlay(alignment: .top) {
            if let e = s.er {
                HStack(spacing: 10) {
                    Rectangle().fill(T0.rd).frame(width: 2, height: 22)
                    Text(e)
                        .font(T0.mono)
                        .foregroundStyle(T0.ink)
                        .lineLimit(2)
                    Spacer()
                    GB(t: "ok", c: T0.dim) { s.er = nil }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.16, green: 0.08, blue: 0.09)))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(T0.rd.opacity(0.35)))
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: s.er)
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 75_000_000_000)
                if !s.bs, s.er == nil { await s.load() }
            }
        }
    }
}

struct TB: View {
    @Binding var i: Int
    let t: [String]
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 5) {
            ForEach(t.indices, id: \.self) { k in
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) { i = k }
                } label: {
                    Text(t[k].uppercased())
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .kerning(1.9)
                        .foregroundStyle(i == k ? T0.bg : T0.dim)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if i == k {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(T0.ink)
                                    .matchedGeometryEffect(id: "tb", in: ns)
                            }
                        }
                }
                .buttonStyle(PS())
            }
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.white.opacity(0.045))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(T0.ln, lineWidth: 1)
        )
    }
}

struct V2: View {
    @StateObject private var s = S0.s
    let k: Int
    @State private var open: R0?
    @State private var q = ""

    private var src: [R0] {
        let a = k == 2 ? s.wb : s.rp
        if q.isEmpty { return a }
        return a.filter { $0.n.lowercased().contains(q.lowercased()) }
    }

    var body: some View {
        ZStack {
            if let r = open {
                V3(r: r) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { open = nil }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)))
            } else {
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        FD(p: k == 2 ? "search site" : "search repository", v: $q)
                        BG(t: k == 2 ? "web" : "repo", c: k == 2 ? T0.ok : T0.acc)
                    }
                    .padding(.horizontal, 20)

                    if s.rp.isEmpty, s.wb.isEmpty, !s.bs {
                        EMPTY()
                    }

                    ScrollView {
                        LazyVStack(spacing: 9) {
                            ForEach(Array(src.enumerated()), id: \.element.key) { idx, r in
                                RW(r: r, k: k) {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.42, dampingFraction: 0.9)) { open = r }
                                }
                                .opacity(1)
                                .transition(.opacity.combined(with: .offset(y: 10)))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .padding(.top, 2)
                    }
                    .scrollIndicators(.visible)
                }
                .transition(.opacity)
            }
        }
    }
}

struct EMPTY: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("—")
                .font(.system(size: 30, weight: .light, design: .monospaced))
                .foregroundStyle(T0.dim2)
            Text("NO ENTRY IN THIS TAB")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .kerning(2.2)
                .foregroundStyle(T0.dim)
            Text("dùng tab push để đăng site hoặc repo")
                .font(.system(size: 11.5, weight: .medium, design: .monospaced))
                .foregroundStyle(T0.dim.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 46)
    }
}

struct RW: View {
    let r: R0
    let k: Int
    let a: () -> Void

    var body: some View {
        Button(action: a) {
            HStack(spacing: 13) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(r.n)
                        .font(.system(size: 14.5, weight: .semibold))
                        .foregroundStyle(T0.ink)
                        .lineLimit(1)
                    HStack(spacing: 7) {
                        Text(r.o)
                            .font(T0.mono)
                            .foregroundStyle(T0.dim)
                        Text("·").foregroundStyle(T0.dim2)
                        Text(r.br)
                            .font(T0.mono)
                            .foregroundStyle(T0.dim)
                        if !r.ds.isEmpty {
                            Text("·").foregroundStyle(T0.dim2)
                            Text(r.ds)
                                .font(T0.mono)
                                .foregroundStyle(T0.dim.opacity(0.75))
                                .lineLimit(1)
                        }
                    }
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 6) {
                    BG(t: k == 2 ? "web" : "repo", c: k == 2 ? T0.ok : T0.acc)
                    Text(H0.nl(r.up))
                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(T0.dim.opacity(0.7))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.038))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(T0.ln, lineWidth: 1)
            )
        }
        .buttonStyle(PS())
    }
}
