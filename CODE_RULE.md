# 📖 Quy tắc Code (Coding Rules) - Dự án Event Management

Chào mừng các thành viên đến với dự án! Để đảm bảo chất lượng code, sự nhất quán và giúp chúng ta làm việc song song (UI/Logic) một cách hiệu quả, tất cả các thành viên **bắt buộc** phải tuân thủ các quy tắc dưới đây.

---

## 1. Môi trường & Công cụ (Environment & Tooling)

**Quy tắc quan trọng nhất** để tránh "lỗi trên máy em chạy được":

### Bắt buộc sử dụng FVM (Flutter Version Management)

- Dự án này sử dụng FVM để "khóa" phiên bản Flutter.
- Phiên bản Flutter của dự án là **3.35.6** (theo settings.json).
- Sau khi clone dự án, hãy chạy `fvm install` để cài đặt.
- Luôn chạy các lệnh Flutter qua FVM (ví dụ: `fvm flutter pub get`, `fvm flutter run`).

---

## 2. Cài đặt VS Code (Bắt buộc)

Toàn bộ các quy tắc định dạng (formatting) của dự án đã được định nghĩa trong file `.vscode/settings.json`.

Để các cài đặt này tự động được áp dụng, hãy đảm bảo bạn đã:

- Cài đặt các Extension (Tiện ích) khuyến nghị mà VS Code gợi ý (thường là Flutter và Dart).
- Bật "Format on Save" và "Organize Imports on Save" trong VS Code.

File `settings.json` của dự án sẽ tự động cấu hình IDE của bạn:

- **Tab Size**: 2 Spaces.
- **Line Length**: Tối đa 80 ký tự.
- **Format on Save**: Tự động format và organizeImports khi lưu file.

---

## 3. Quy tắc Đặt tên (Naming Conventions)

| Hạng mục            | Quy tắc           | Ví dụ                                                               |
| ------------------- | ----------------- | ------------------------------------------------------------------- |
| Thư mục (Directory) | `snake_case`      | `core`, `features`, `user_profile`, `auth_service`                  |
| Files               | `snake_case.dart` | `login_screen.dart`, `event_model.dart`, `auth_repository.dart`     |
| Class               | `PascalCase`      | `User`, `LoginBloc`, `AuthService`, `EventRepositoryImpl`           |
| Biến & Hàm          | `camelCase`       | `userName`, `fetchUserData()`, `currentPage`                        |
| Biến private        | `_camelCase`      | `_userName`, `_fetchUserData()`                                     |
| Widget private      | `_PascalCase`     | `class _BuildAppBar extends StatelessWidget { ... }`                |
| Constants (Hằng số) | `kCamelCase`      | `const kDefaultPadding = 8.0;`, `static const kApiTimeout = 30000;` |

---

## 4. Tiêu chuẩn Code (Coding Standards)

### a. Imports (Thứ tự ưu tiên)

Luôn sắp xếp các import theo thứ tự sau. Sử dụng "Organize Imports" (có trong settings.json) sẽ tự động làm điều này.

```dart
// 1. Gói Dart
import 'dart:async';

// 2. Gói Flutter
import 'package:flutter/material.dart';

// 3. Gói bên thứ ba (Packages) - Sắp xếp theo alphabet
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// 4. Code của Dự án (Source) - Dùng relative path (đường dẫn tương đối)
import 'core/config/app_theme.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
```

### b. `const` là bắt buộc

Luôn sử dụng `const` cho các constructor của Widget và các biến hằng số bất cứ khi nào có thể. Điều này giúp tối ưu hiệu suất của Flutter.

```dart
// TỐT ✅
return const Scaffold(
  body: Center(
    child: Text('Hello'),
  ),
);

// KHÔNG TỐT ❌
return Scaffold(
  body: Center(
    child: Text('Hello'),
  ),
);
```

### c. Comments

- Sử dụng `///` (3 gạch chéo) để viết tài liệu (documentation) cho các class và hàm public.
- Sử dụng `//` (2 gạch chéo) để giải thích các logic phức tạp bên trong hàm.

```dart
/// Lấy thông tin người dùng từ server.
/// Ném ra một [NetworkException] nếu có lỗi xảy ra.
Future<User> fetchUser(String id) async {
  // TODO: Implement logic
}
```

---

## 5. Kiến trúc Dự án (Project Architecture)

Dự án tuân theo cấu trúc thư mục **Clean Architecture** (`core`, `data`, `features`).

### a. `lib/core`

Chứa code được sử dụng chung bởi toàn bộ ứng dụng (ví dụ: theme, router, dependency_injection, constants, core_widgets).

**⚠️ QUY TẮC VÀNG**: Code trong `core` **KHÔNG được phép** import bất kỳ file nào từ `features` hay `data`.

### b. `lib/features`

Chứa các màn hình và logic nghiệp vụ. Mỗi feature là một "ứng dụng nhỏ" độc lập.

Mỗi feature (ví dụ: `login`) nên có 3 thư mục con:

- **`presentation`**: Chứa UI (screens, widgets) và BLoC (bloc).
- **`domain`**: Chứa Entities (POCO - các class data thuần túy) và Repositories (abstract class - giao diện).
- **`data`**: Chứa Models (class data có fromJson/toJson), DataSources (nơi gọi API), và RepositoryImpl (nơi implement domain/Repositories).

**⚠️ QUY TẮC VÀNG (Dependency Rule)**:

- Một feature **KHÔNG được** import trực tiếp một feature khác.
- Ví dụ: `features/login` **KHÔNG được** `import 'features/profile/...'`.
- **Cách giao tiếp**: Hai feature giao tiếp với nhau thông qua `core` (ví dụ: `core/router` để điều hướng).

### c. `lib/data` (Global)

Chứa các DataSources hoặc Repositories được dùng chung bởi nhiều feature (ví dụ: `AuthRepositoryImpl`).

---

## 6. BLoC & State Management

File `settings.json` đã chỉ định: `"bloc.newCubitTemplate.type": "equatable"`

**⚠️ QUY TẮC**: Tất cả các BLoC State và Cubit State **BẮT BUỘC** phải kế thừa từ `Equatable`.

Điều này giúp BLoC/Cubit nhận biết được khi nào state thực sự thay đổi và rebuild UI một cách hiệu quả.

```dart
// TỐT ✅
class LoginState extends Equatable {
  final bool isLoading;
  const LoginState({this.isLoading = false});

  @override
  List<Object> get props => [isLoading];
}

// KHÔNG TỐT ❌
class LoginState {
  final bool isLoading;
  const LoginState({this.isLoading = false});
}
```

---

## 7. Quy trình Git (Git Workflow)

Chúng ta sử dụng **Simplified Git-Flow**.

### Nhánh Chính

- **`main`**: Nhánh ổn định, code chạy được (chỉ merge khi nộp bài/demo).
- **`develop`**: Nhánh làm việc chính. Tất cả Pull Request (PR) đều phải merge vào đây.

### Quy trình làm việc (cho 1 User Story, ví dụ EM-32)

#### Dev Logic 1 (Integrator)

```bash
git checkout develop
git checkout -b feature/EM-32-login
git push -u origin feature/EM-32-login  # Đẩy nhánh lên để team thấy
```

#### Dev UI 1 (UI)

```bash
git fetch origin
git checkout feature/EM-32-login
git checkout -b feature/EM-32-login-ui
# ... (Code UI) ...
git push -u origin feature/EM-32-login-ui
```

#### Dev Logic 2 (Logic)

```bash
git fetch origin
git checkout feature/EM-32-login
git checkout -b feature/EM-32-login-logic
# ... (Code BLoC/Service) ...
git push -u origin feature/EM-32-login-logic
```

#### Dev Logic 1 (Integrator - Sau khi 2 bạn kia xong)

```bash
git checkout feature/EM-32-login  # Quay lại nhánh chính của feature
git pull origin feature/EM-32-login-ui  # Merge code UI vào
git pull origin feature/EM-32-login-logic  # Merge code Logic vào
# ... (Code tích hợp, giải quyết conflict) ...
```

### Pull Request

- Dev Logic 1 tạo **1 Pull Request duy nhất** từ `feature/EM-32-login` vào `develop`.
- Cần ít nhất 1 người (Dev UI 1 hoặc Dev Logic 2) review và Approve.
- Sau khi Approve, tiến hành Merge.

---

## 8. Các Nguyên tắc Thiết kế Cốt lõi

Đây là các triết lý giúp "Nhóm Logic" và "Nhóm UI" viết code hiệu quả.

### a. KISS (Keep It Simple, Stupid) - Giữ nó đơn giản

**Là gì**: Luôn chọn giải pháp đơn giản nhất có thể. Đừng phức tạp hóa vấn đề (over-engineer).

**Cách áp dụng thực tế trong dự án này**:

- **BLoC**: Nếu một màn hình chỉ cần "tải dữ liệu và hiển thị", hãy dùng Cubit (đơn giản hơn BLoC). Chỉ dùng BLoC khi có logic nghiệp vụ phức tạp với nhiều Events.
- **UI**: Đừng tạo một StatefulWidget khổng lồ quản lý 10 trạng thái khác nhau. Hãy chia nó thành nhiều StatelessWidget con, nhận dữ liệu từ BlocBuilder.
- **Hàm (Function)**: Một hàm chỉ nên làm một việc và làm tốt việc đó. Nếu hàm của bạn dài quá 30 dòng, hãy nghĩ cách tách nó ra.

### b. DRY (Don't Repeat Yourself) - Đừng lặp lại chính mình

**Là gì**: Không bao giờ lặp lại một đoạn code hoặc một logic ở nhiều nơi.

**Cách áp dụng thực tế trong dự án này**:

#### UI (Task của Dev UI)

**Phát hiện**: Bạn thấy `TextFormField` "Email" (với validator, icon, hint text) xuất hiện ở 3 màn hình: Đăng nhập, Đăng ký, Quên mật khẩu.

**Hành động**: Tạo một widget mới `EmailTextFormField.dart` trong `lib/core/widgets` và tái sử dụng nó ở cả 3 nơi.

**Phát hiện**: Cả 3 màn hình đều có nút "Xác nhận" màu tím, bo góc.

**Hành động**: Tạo một widget `PrimaryButton.dart` trong `lib/core/widgets`.

#### Logic (Task của Dev Logic)

**Phát hiện**: Cả `EventService` và `PollService` đều cần xử lý lỗi API (ví dụ: 401 - Unauthenticated).

**Hành động**: Viết một hàm `handleApiError(Response response)` chung trong `lib/core/network` (hoặc trong Dio Interceptor).

### c. SOLID

Đây là 5 nguyên tắc nền tảng của Lập trình Hướng đối tượng, và nó là lý do chính tại sao chúng ta sử dụng kiến trúc Clean Architecture và BLoC.

#### S - Single Responsibility Principle (Nguyên tắc Đơn trách nhiệm)

**Là gì**: Một class (lớp) chỉ nên chịu một trách nhiệm duy nhất.

**Cách áp dụng thực tế**:

- **Kiến trúc**: Đây chính là lý do chúng ta chia dự án thành 3 sub-task song song ([UI], [Logic], [Integration]).

**Ví dụ**:

- `login_screen.dart` (UI) chỉ chịu trách nhiệm hiển thị (build widget).
- `LoginBloc` (Logic) chỉ chịu trách nhiệm quản lý state (biến isLoading thành true/false).
- `AuthService` (Data) chỉ chịu trách nhiệm gọi API và trả về data.

**⚠️ Cảnh báo**: Nếu bạn thấy mình `import 'package:http/http.dart'` (gọi API) ngay trong file `login_screen.dart` (UI), là bạn đang vi phạm nguyên tắc này!

#### O - Open/Closed Principle (Nguyên tắc Đóng/Mở)

**Là gì**: Một class nên **Mở (Open)** cho việc mở rộng, nhưng **Đóng (Closed)** cho việc sửa đổi.

**Cách áp dụng thực tế**:

- **Kiến trúc**: Đây là lý do chúng ta dùng Repository (abstract class) trong domain.

**Ví dụ**:

- `EventListBloc` của bạn import `event_repository.dart` (một abstract class).
- Ban đầu (Sprint 1), `EventRepositoryImpl` (implement class) gọi API để lấy data.
- Sau này (Sprint 4), chúng ta thêm tính năng Offline (EM-57).
  - Chúng ta không cần sửa 1 dòng code nào trong `EventListBloc` (nó đã "Đóng").
  - Chúng ta chỉ cần sửa `EventRepositoryImpl` để nó kiểm tra mạng: "Nếu có mạng, gọi API. Nếu không, đọc từ Hive." (Nó "Mở" cho việc mở rộng logic).

#### L - Liskov Substitution Principle (Nguyên tắc Thay thế Liskov)

**Là gì**: (Nói đơn giản) Các lớp con (child classes) phải có khả năng thay thế hoàn toàn lớp cha (base class) mà không gây ra lỗi.

**Cách áp dụng thực tế**:

- **BLoC**: Đây là lý do chúng ta dùng abstract class cho State.

**Ví dụ**:

- Cả `LoginSuccess` và `LoginFailure` đều kế thừa (extends) từ `LoginState`.
- `BlocBuilder` của bạn lắng nghe `LoginState`.
- Khi BLoC phát ra `LoginSuccess` hay `LoginFailure`, `BlocBuilder` đều xử lý được mà không bị lỗi.

#### I - Interface Segregation Principle (Nguyên tắc Phân tách Interface)

**Là gì**: Đừng tạo ra các "interface" (abstract class) "béo phì" (chứa quá nhiều hàm mà class con không cần dùng). Hãy chia nhỏ chúng.

**Cách áp dụng thực tế**:

- **Ví Dụ (Không tốt)**: Tạo một `UserRepository` khổng lồ chứa: `login()`, `register()`, `updateProfile()`, `changePassword()`, `getAvatar()`, `uploadBanner()`.
- **Ví Dụ (TỐT)**: Chia nhỏ thành 2 interface:
  - `AuthRepository` (chỉ chứa `login()`, `register()`, `changePassword()`).
  - `ProfileRepository` (chỉ chứa `updateProfile()`, `getAvatar()`).

#### D - Dependency Inversion Principle (Nguyên tắc Đảo ngược Phụ thuộc)

**Là gì**: Lớp cấp cao (ví dụ: BLoC) không nên phụ thuộc vào lớp cấp thấp (ví dụ: Service). Cả hai nên phụ thuộc vào một "Hợp đồng" (Abstraction, hay abstract class).

**Cách áp dụng thực tế**:

- Đây là **CỐT LÕI** của toàn bộ kiến trúc Clean Architecture.

**Ví dụ (TỐT)**:

- `LoginBloc` (cấp cao) import `auth_repository.dart` (Hợp đồng/Abstraction).
- `AuthRepositoryImpl` (cấp thấp) implement `auth_repository.dart`.
- **Kết quả**: `LoginBloc` không hề biết `AuthService` hay API là gì. Nó chỉ biết "Tôi cần một ai đó tuân thủ 'Hợp đồng AuthRepository' để lấy data cho tôi". Điều này giúp việc thay thế (ví dụ: đổi `AuthService` sang `FirebaseAuth`) hoặc viết Unit Test (mock repository) trở nên cực kỳ dễ dàng.

---

## 📝 Tóm tắt

- ✅ Luôn dùng FVM để đảm bảo phiên bản Flutter nhất quán
- ✅ Tuân thủ quy tắc đặt tên và coding standards
- ✅ Sử dụng `const` và Equatable cho State
- ✅ Tôn trọng kiến trúc Clean Architecture và Dependency Rule
- ✅ Áp dụng KISS, DRY, và SOLID trong mọi tình huống
- ✅ Làm việc song song hiệu quả với Git workflow

**Chúc các bạn code vui vẻ! 🚀**
