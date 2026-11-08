# Lab F6: Dialog, SnackBar, Menu & khung điều hướng Flutter

Bài tập thực hành môn Lập trình trên các thiết bị di động (INT4211).

## Thông tin sinh viên
- Họ và tên: Lê Hoàng Anh Kiệt
- MSSV: 241A030192

## Môi trường thử nghiệm
- Flutter 3.47.3, Dart 3.13.3
- Thiết bị: Android Emulator (Pixel LabA1 - sdk_gphone16k_x86_64)
- Hệ điều hành: Android 17 (API 37)

## Giới thiệu
Ứng dụng "Quản lý công việc" viết bằng Flutter (Material 3), gồm 3 tab: Công việc, Thống kê, Cài đặt. Bài dùng Scaffold để dựng khung màn hình, hộp thoại để hỏi lại và nhập dữ liệu, SnackBar để hoàn tác khi xóa.

## Chức năng chính
- Scaffold đủ AppBar, Drawer, NavigationBar và nút + (FAB).
- Drawer (NavigationDrawer) và thanh dưới (NavigationBar) dùng chung một biến `_tab`.
- Thêm công việc bằng hộp thoại nhập liệu, để trống thì báo lỗi và không đóng hộp thoại.
- Giữ lâu một dòng để xóa, có hộp thoại hỏi lại, chạm ra ngoài thì không xóa.
- Xóa xong có SnackBar với nút HOÀN TÁC, việc quay về đúng vị trí cũ.
- Menu ba chấm (PopupMenuButton): ẩn/hiện việc đã xong, xóa các việc đã xong.
- Chạm một dòng mở BottomSheet: đánh dấu xong/chưa xong hoặc xóa.
- Tab Thống kê hiện số việc đã xong / tổng số việc.
- Tab Cài đặt: bật tắt hiện việc đã xong, xóa toàn bộ danh sách.

## Bài nâng cao
- NC1: Dùng IndexedStack để mỗi tab giữ nguyên vị trí cuộn khi chuyển qua lại.
- NC2: Dùng Dismissible, vuốt một dòng sang trái để xóa, vẫn có Hoàn tác.

## Kết quả kiểm thử
1. Mở Drawer: Pass (hiện tên, email và đủ 3 mục).
2. Chọn Thống kê trong Drawer: Pass (Drawer đóng, thanh dưới sáng mục Thống kê).
3. Bấm Thêm khi để trống: Pass (báo "Không được để trống", hộp thoại không đóng).
4. Nhập tên việc rồi bấm Thêm: Pass (việc mới nằm đầu danh sách).
5. Giữ lâu một dòng rồi bấm Xóa: Pass (hộp thoại nêu đúng tên việc).
6. Bấm HOÀN TÁC: Pass (việc quay lại đúng vị trí cũ).
7. Menu ba chấm → Ẩn việc đã xong: Pass (Thống kê vẫn đếm đủ).
8. Chạm ra ngoài hộp thoại xác nhận: Pass (không xóa gì).

`flutter analyze`: No issues found!

## Cách chạy
```
flutter pub get
flutter run
```
