# ZEPHYS

Ứng dụng iOS (SwiftUI) để đăng website / APT repo lên GitHub Pages bằng token, quản lý file trực tiếp trên repo.

## Tải IPA

- Link trực tiếp (luôn là bản mới nhất):
  **https://github.com/anxinhgai/zephys/releases/latest/download/ZEPHYS.ipa**
- Hoặc tab **Actions** → workflow **ipa** → run mới nhất → artifact **ZEPHYS-ipa**.

Build chạy tự động bằng GitHub Actions (`macos-15` + Xcode mới nhất, XcodeGen sinh project, SPM resolve ZIPFoundation, `xcodebuild` Release cho `iphoneos` rồi đóng gói `Payload/` thành ipa).

IPA là **unsigned** (không có chứng chỉ Apple). Cách cài:

- **Sideloadly / AltStore / SideStore**: kéo file ipa, đăng nhập Apple ID → app được ký bằng cert free (hết hạn sau 7 ngày, cài lại).
- **ESign / Feather / Scarlet** trên máy: import ipa + cert (dùng cert free hoặc cert trả phí).
- Nếu bạn có Mac + tài khoản developer: mở project, chọn team, Product → Archive → export ipa (bản này ký thật).

`bundle id`: `com.zephys.app` · tối thiểu iOS 16.0 · icon + tên hiển thị **ZEPHYS**.

## Dùng

1. Mở app → dán GitHub token vào ô, bấm **AUTHORIZE**. Token cần scope `repo` + `workflow` + `pages` (classic PAT). Token lưu trong Keychain, không gửi đi đâu ngoài `api.github.com`.
2. Tab **REPO** / **WEB**: danh sách repo của bạn, app tự phân loại (có file `.deb` hoặc `Packages` → repo, có `index.html` → web). Bấm 1 dòng để mở cây file; bấm 1 file để xem text/code, bấm **EDIT** để sửa và **SAVE** để commit.
3. Trong cây file: **NEW FILE**, **FOLDER**, **UPLOAD** (deb/ảnh/tài liệu), giữ 1 dòng để **rename / delete**; các thay đổi được xếp hàng chờ, bấm **UPDATE** để commit một lần.
4. Tab **PUSH**: chọn zip / folder / file → app giải nén, tự nhận dạng web hay repo → đặt tên URL (sửa được cả lúc đang chạy) → **PUBLISH**. App tạo repo, upload toàn bộ file, bật GitHub Pages và trả về link.
   - Nếu folder có file `.deb` mà chưa có `Packages`, app tự sinh `Packages` (flat repo) từ tên file deb.

## Build tay trên máy Mac

```sh
brew install xcodegen
xcodegen generate
open ZEPHYS.xcodeproj
```

SPM dependency: ZIPFoundation (đọc/giải nén zip).

## Cấu trúc

```
project.yml                  khai báo project cho XcodeGen
tools/icon.py                sinh AppIcon 1024
ZEPHYS/ZApp.swift            entry + router + màn hình token & shell
ZEPHYS/Core/ZNet.swift       GitHub REST (repos, trees, contents, git data, pages)
ZEPHYS/Core/ZStore.swift     state, cache, staged changes, publish flow
ZEPHYS/Core/ZKey.swift       keychain
ZEPHYS/Core/ZUtil.swift      zip, đọc folder, phát hiện loại, sinh Packages
ZEPHYS/UI/ZTheme.swift       màu, texture, component
ZEPHYS/UI/ZRevolver.swift    hoạt ảnh loading súng lục
ZEPHYS/Features/ZFiles.swift cây file + xem/sửa file
ZEPHYS/Features/ZPush.swift  import & publish
```

## Ghi chú

- GitHub Pages cho repo mới có thể mất 30–90 giây mới live; app chờ và trả link khi Pages báo built.
- Repo tạo ra là **public** (Pages free yêu cầu public).
- Token lộ = mất repo: dùng PAT riêng, hạn ngắn, xong thì revoke.
