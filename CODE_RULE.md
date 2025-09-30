# Quy tắc Viết mã (Coding Rules)

Chào mừng đến với dự án! Tài liệu này định nghĩa các quy tắc và tiêu chuẩn viết mã cho toàn bộ dự án. Việc tuân thủ các quy tắc này là bắt buộc để đảm bảo code base của chúng ta luôn nhất quán, dễ đọc, dễ bảo trì và dễ dàng cho các thành viên mới tham gia.

---

## Mục lục

1. [Quy ước Đặt tên (Naming Convention)](#1-quy-ước-đặt-tên-naming-convention)
2. [Cấu trúc Thư mục (Folder Structure)](#2-cấu-trúc-thư-mục-folder-structure)
3. [Định dạng Code (Formatting)](#3-định-dạng-code-formatting)
4. [Kiến trúc & Cấu trúc](#4-kiến-trúc--cấu-trúc)
5. [Quản lý State (Riverpod)](#5-quản-lý-state-riverpod)
6. [Models & Entities](#6-models--entities)
7. [Error Handling](#7-error-handling)
8. [Networking](#8-networking)
9. [UI & Widgets](#9-ui--widgets)
10. [Constants & Strings](#10-constants--strings)
11. [Quy trình làm việc với Git](#11-quy-trình-làm-việc-với-git)
12. [Testing](#12-testing)
13. [CI/CD](#13-cicd)
14. [Review Rules](#14-review-rules)
15. [Ghi chú & Bình luận](#15-ghi-chú--bình-luận)

---

## 1. Quy ước Đặt tên (Naming Convention)

| Loại                     | Quy tắc                                  | Ví dụ                                                             |
| ------------------------ | ---------------------------------------- | ----------------------------------------------------------------- |
| **Folder & File**        | `snake_case`                             | `user_repository.dart`, `event_detail_page.dart`, `auth_api.dart` |
| **Class, Enum, Typedef** | `PascalCase`                             | `UserRepository`, `AuthApi`, `NetworkStatus`, `JsonMap`           |
| **Hàm, Biến**            | `camelCase`                              | `fetchUserData`, `userName`, `isLoading`, `fetchEvents()`         |
| **Hằng số (Constants)**  | `kCamelCase` hoặc `SCREAMING_SNAKE_CASE` | `kDefaultPadding`, `kApiTimeout`, `DEFAULT_TIMEOUT`               |
| **Thành viên private**   | `_camelCase`                             | `_fetchData()`, `_internalState`                                  |
| **Provider**             | `camelCase` + suffix `Provider`          | `authRepositoryProvider`, `homeControllerProvider`                |

---

## 2. Cấu trúc Thư mục (Folder Structure)

```
lib/
├── core/                          # Config & utilities dùng chung
│   ├── constants/                 # app_strings.dart, app_colors.dart, app_sizes.dart
│   ├── theme/                     # AppTheme
│   ├── network/                   # Dio setup, interceptors
│   ├── di/                        # Dependency injection (Riverpod providers)
│   └── utils/                     # Helper functions
├── data/                          # Data layer
│   ├── datasources/               # Remote/Local datasources
│   ├── models/                    # DTOs (với json_serializable)
│   └── repositories/              # Repository implementations
├── domain/                        # Domain layer
│   ├── entities/                  # Pure Dart classes (immutable)
│   ├── repositories/              # Repository interfaces
│   └── usecases/                  # Business logic
├── presentation/                  # Presentation layer
│   ├── common_widgets/            # Reusable widgets
│   ├── features/                  # Feature modules
│   │   └── <feature_name>/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/
│   └── router/                    # go_router configuration
├── generated/                     # ❌ KHÔNG commit (*.g.dart, *.freezed.dart)
└── main.dart
```

### Quy tắc thư mục:

- **`core/`**: Chứa config & utilities dùng chung (theme, network, DI, constants).
- **`data/`**: Datasource, models (DTO), repository implement.
- **`domain/`**: Entities (pure), repository interface, usecases.
- **`presentation/`**: UI (pages, widgets), state (providers), navigation.
- **`features/`**: Khi có module lớn, group tất cả tầng vào một feature riêng.
- **`generated/`**: KHÔNG commit. Ignore các file `.g.dart`, `.freezed.dart`.

---

## 3. Định dạng Code (Formatting)

### Công cụ duy nhất: `dart format`

Mọi đoạn code trước khi commit phải được format.

**💡 Tip:** Cấu hình IDE của bạn để tự động format file mỗi khi lưu.

### Quy tắc:

- **Độ dài dòng:** Tối đa **100 ký tự** một dòng.
- **Dấu phẩy cuối (Trailing commas):** Luôn luôn sử dụng dấu phẩy ở cuối trong danh sách tham số, collection... Điều này giúp cho Git diff sạch sẽ hơn rất nhiều khi thêm một phần tử mới.

### Analyzer:

- Sử dụng `very_good_analysis` + custom rule trong `analysis_options.yaml`.
- Không ignore warnings trừ khi có lý do chính đáng.

---

## 4. Kiến trúc & Cấu trúc

### Clean Architecture

Tuân thủ 3 tầng:

1. **Domain Layer** (business logic thuần túy, không phụ thuộc framework)
2. **Data Layer** (implement repositories, call API/Database)
3. **Presentation Layer** (UI + State Management)

### Nguyên tắc:

- **Tuân thủ cấu trúc boilerplate:** Luôn tuân theo kiến trúc đã được định sẵn (domain → data → presentation).
- **Ưu tiên theo tính năng (Feature-First):** Mọi màn hình, widget, provider liên quan đến một tính năng phải được đặt trong thư mục của tính năng đó: `lib/presentation/features/<feature_name>/`.
- **Thư mục core:** Chỉ chứa những thành phần được sử dụng chung cho toàn bộ ứng dụng và không thuộc về một tính năng cụ thể nào.

---

## 5. Quản lý State (Riverpod)

### Đặt tên Provider

Tên provider phải có hậu tố `Provider`.

**Ví dụ:** `authRepositoryProvider`, `homeControllerProvider`.

### Provider chia 2 loại:

- **Hạ tầng (Infrastructure):** Đặt trong `core/di`.
- **Theo feature:** Đặt trong `features/<feature>/presentation/providers/`.

### State phải bất biến (Immutable)

Luôn tạo một state mới thay vì thay đổi trực tiếp state hiện tại. Sử dụng hàm `copyWith` do `freezed` tạo ra.

### `ref.watch` vs `ref.read`

- **`ref.watch`:** Sử dụng trong phương thức `build` để lắng nghe sự thay đổi của state và tự động rebuild widget.
- **`ref.read`:** Sử dụng bên trong các hàm callback (như `onPressed`, `onTap`) để lấy giá trị state tại một thời điểm mà không gây rebuild widget.

### Không sử dụng `get_it`

Riverpod đã hỗ trợ DI đầy đủ.

---

## 6. Models & Entities

### Entities

- **Immutable**, không phụ thuộc JSON.
- Đặt trong `domain/entities/`.
- Không chứa logic serialize/deserialize.

```dart
// ✅ Tốt - Entity
class User {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });
}
```

### Models (DTO)

- Dùng `freezed` + `json_serializable`.
- Đặt trong `data/models/`.
- Chịu trách nhiệm serialize/deserialize JSON.

```dart
// ✅ Tốt - Model (DTO)
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

### Mapping

Luôn map `Model ↔ Entity` tại **repository layer**, không expose DTO ra UI.

```dart
// ✅ Tốt - Repository
class UserRepositoryImpl implements UserRepository {
  @override
  Future<User> getUser(String id) async {
    final userModel = await remoteDataSource.getUser(id);
    return userModel.toEntity(); // Map sang Entity
  }
}
```

---

## 7. Error Handling

### Sử dụng `Result<T>` hoặc `Either<Failure, T>`

Không throw exception trực tiếp từ repository lên UI.

```dart
// ✅ Tốt
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}
```

### UI chỉ xử lý 3 trạng thái:

- `Success`
- `Failure`
- `Loading`

```dart
// ✅ Tốt
final result = ref.watch(getUserProvider);

return result.when(
  data: (user) => Text(user.name),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

---

## 8. Networking

### Stack:

- Sử dụng `dio` + `retrofit`.
- Interceptors: logging, auth, retry.

### Configuration:

- Base URL lấy từ `.env` theo flavor.
- Timeout mặc định: **15s**.

```dart
// ✅ Tốt - Dio setup
final dio = Dio(
  BaseOptions(
    baseUrl: Environment.baseUrl,
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
  ),
);

dio.interceptors.addAll([
  LogInterceptor(),
  AuthInterceptor(),
  RetryInterceptor(),
]);
```

---

## 9. UI & Widgets

### Sử dụng `const`

Thêm `const` vào trước các widget không thay đổi để tối ưu hiệu năng. Linter sẽ giúp bạn việc này.

```dart
// ✅ Tốt
const Text('Hello World')

// ❌ Xấu
Text('Hello World')
```

### Chia nhỏ Widget

Giữ cho phương thức `build` luôn ngắn gọn và dễ đọc. Tách các phần phức tạp ra thành các widget con (private Widget class hoặc `_build...` methods).

```dart
// ✅ Tốt
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() => AppBar(title: const Text('Home'));

  Widget _buildBody() => const Center(child: Text('Content'));
}
```

### Không "Magic Number" hay "Magic String"

- **Màu sắc, Khoảng cách, Kiểu chữ:** Luôn sử dụng giá trị từ `AppTheme` đã định nghĩa.
- **Văn bản:** Tất cả các chuỗi văn bản hiển thị cho người dùng phải được lấy từ file localization (ARB). Không hardcode text trong UI.

```dart
// ❌ Xấu
Container(
  color: Color(0xFF0000FF),
  padding: EdgeInsets.all(16),
  child: Text('Welcome'),
)

// ✅ Tốt
Container(
  color: AppColors.primary,
  padding: EdgeInsets.all(AppSizes.paddingMedium),
  child: Text(context.l10n.welcomeMessage),
)
```

### Page & Widget structure:

- **Page:** Đặt trong `features/<feature>/presentation/pages`.
- **Widget tái sử dụng:** Đặt trong `presentation/common_widgets`.
- **Navigation:** Dùng `go_router`, định nghĩa route trong từng feature, merge vào `app/router.dart`.

---

## 10. Constants & Strings

### Tạm thời:

- `core/constants/app_strings.dart`
- `core/constants/app_colors.dart`
- `core/constants/app_sizes.dart`

### Về lâu dài:

Dùng **l10n ARB** cho text.

### Quy tắc:

- **KHÔNG hardcode string** trong UI.
- Tất cả text hiển thị phải từ localization hoặc constants.

```dart
// ❌ Xấu
Text('Login')

// ✅ Tốt
Text(AppStrings.login)
// hoặc
Text(context.l10n.login)
```

---

## 11. Quy trình làm việc với Git

### Phân nhánh (Branching)

- `main`: Release branch (protected)
- `develop`: Development branch
- `feat/<feature-name>`: Cho các tính năng mới (ví dụ: `feat/login-with-google`)
- `fix/<bug-name>`: Cho việc sửa lỗi (ví dụ: `fix/wrong-password-error`)
- `chore/<task-name>`: Cho các công việc không liên quan đến code (cập nhật docs, cấu hình CI...)

### Commit Message

Tuân thủ tiêu chuẩn **Conventional Commits**.

**Cấu trúc:** `<type>: <subject>`

**`<type>` phổ biến:**

- `feat`: Thêm một tính năng mới
- `fix`: Sửa một lỗi
- `refactor`: Tái cấu trúc code mà không thay đổi hành vi
- `style`: Thay đổi về định dạng, dấu chấm phẩy...
- `docs`: Cập nhật tài liệu
- `chore`: Các công việc vặt
- `test`: Thêm hoặc sửa tests

**Ví dụ:**

```
feat: add user logout functionality
fix: correct password validation logic
docs: update CODE_RULE.md with Git workflow
refactor: extract user repository to separate file
```

### Pull Request (PR)

- Mỗi PR nên nhỏ và chỉ tập trung vào một nhiệm vụ duy nhất.
- Mô tả của PR phải rõ ràng, giải thích những gì đã được thực hiện.
- Mọi PR cần được **ít nhất 1 thành viên khác review và approve** trước khi merge.

---

**Phiên bản:** 1.0.0  
**Cập nhật lần cuối:** 2025-01-01
