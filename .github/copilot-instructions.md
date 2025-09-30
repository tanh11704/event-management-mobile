## Tổng quan dự án

Kho lưu trữ này là **ứng dụng di động Flutter** có tên `event_management`.
Ứng dụng được xây dựng bằng Flutter (Dart SDK >= 3.9.0) với **Riverpod** để quản lý trạng thái, **go_router** để điều hướng và **dio + retrofit** để kết nối mạng.

Ứng dụng được thiết kế để quản lý các sự kiện: xác thực, tạo sự kiện, điểm danh, quét mã QR, v.v.

### Mục tiêu

- Duy trì kiến ​​trúc sạch và nhất quán (Kiến trúc sạch + Ưu tiên tính năng nếu có).
- Đảm bảo khả năng kiểm thử, khả năng mở rộng và khả năng đọc của cơ sở mã.
- Tuân thủ các tiêu chuẩn mã hóa chung cho tất cả các thành viên trong nhóm.

---

## Cấu trúc thư mục

- `lib/core/` – cấu hình toàn cục và các tiện ích dùng chung (hằng số, giao diện, mạng, DI, tiện ích).
- `lib/data/` – lớp dữ liệu: nguồn dữ liệu, mô hình DTO, triển khai kho lưu trữ.
- `lib/domain/` – lớp miền: các thực thể, giao diện kho lưu trữ, trường hợp sử dụng.
- `lib/presentation/` – lớp trình bày: UI (trang, tiện ích), trạng thái (nhà cung cấp), định tuyến.
- `lib/presentation/features/<feature_name>/` – các trang, tiện ích, nhà cung cấp dành riêng cho tính năng.
- `lib/generated/` – các tệp được tạo (`.g.dart`, `.freezed.dart`) → KHÔNG chỉnh sửa hoặc cam kết.
- `test/` – sao chép `lib/` cho các bài kiểm tra đơn vị, tiện ích và tích hợp.

---

## Thư viện và Khung

- **flutter_riverpod** (quản lý trạng thái, với riverpod_generator).
- **go_router** (điều hướng & bảo vệ tuyến đường).
- **dio + retrofit** (mạng).
- **freezed + json_serializable** (mô hình bất biến và JSON).

- **flutter_dotenv** (cấu hình môi trường).
- **package_info_plus**, **logger** (tiện ích).
- **very_good_analysis** (kiểm tra lỗi và chất lượng mã).
- **flutter_launcher_icons**, **flutter_native_splash** (tài sản và thương hiệu).

---

## Tiêu chuẩn mã hóa

- **Đặt tên**
- Tệp và thư mục: `snake_case`.
- Lớp và enum: `PascalCase`.
- Biến và phương thức: `camelCase`.
- Hằng số: `kCamelCase` hoặc `SCREAMING_SNAKE_CASE`.
- Nhà cung cấp: hậu tố `Provider` (ví dụ: `authRepositoryProvider`).
- **Định dạng**
- Độ dài dòng: 100 ký tự.
- Sử dụng dấu phẩy cuối trong cây tiện ích và danh sách tham số.
- Luôn ưu tiên `const` khi có thể.
- **Kiến trúc**
- Phân tách Kiến trúc Sạch: `domain` (logic nghiệp vụ), `data` (triển khai), `presentation` (UI/state).
- Ánh xạ DTO ↔ Thực thể tại lớp kho lưu trữ. Không để DTO tiếp xúc với UI.
- **Xử lý lỗi**
- Sử dụng mẫu `Result<T>` hoặc `Either<Failure, T>` thay vì đưa ngoại lệ vào UI.
- **Kiểm thử**
- Độ bao phủ kiểm thử tối thiểu 70%.
- Phản chiếu cấu trúc thư mục `lib/` trong `test/`.

---

## Xây dựng & Chạy

- Phát triển:

```bash
flutter run --flavor dev --target lib/main_dev.dart
```
