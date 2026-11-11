import SwiftUI
import UniformTypeIdentifiers

struct DK: UIViewControllerRepresentable {
    let mul: Bool
    let dir: Bool
    let done: ([URL]) -> Void

    func makeCoordinator() -> CO { CO(done) }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let vc: UIDocumentPickerViewController
        if dir {
            vc = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
        } else {
            vc = UIDocumentPickerViewController(forOpeningContentTypes: [.data, .zip, .archive, .item],
                                                asCopy: true)
        }
        vc.allowsMultipleSelection = mul && !dir
        vc.shouldShowFileExtensions = true
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ vc: UIDocumentPickerViewController, context: Context) {}

    final class CO: NSObject, UIDocumentPickerDelegate {
        private let cb: ([URL]) -> Void
        init(_ c: @escaping ([URL]) -> Void) { cb = c }

        func documentPicker(_ c: UIDocumentPickerViewController, didPickDocumentsAt u: [URL]) {
            cb(u)
        }

        func documentPickerWasCancelled(_ c: UIDocumentPickerViewController) {
            cb([])
        }
    }
}

struct PKS: View {
    let mul: Bool
    let dir: Bool
    let done: ([URL]) -> Void

    var body: some View {
        DK(mul: mul, dir: dir, done: done)
            .ignoresSafeArea()
            .background(T0.bg)
    }
}
