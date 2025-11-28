import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_event.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_state.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? phoneNumber;
  String? password;
  String? confirmPassword;
  int? unitId;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Chỉ fetch units 1 lần khi khởi tạo form
    context.read<RegisterBloc>().add(const RegisterGetUnits());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final isLoading = state is RegisterLoading;
        final unitsLoaded = state is RegisterUnitsLoaded ? state : null;

        return Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Họ tên
              TextFormField(
                decoration: _buildInputDecoration(
                  label: 'Họ và tên',
                  hint: 'Nhập họ và tên đầy đủ',
                  icon: Icons.person_outline_rounded,
                ),
                textInputAction: TextInputAction.next,
                onChanged: (v) {
                  // Lưu giá trị để validation realtime
                  name = v.trim();
                },
                onSaved: (v) => name = v?.trim(),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Vui lòng nhập họ tên'
                    : null,
              ),
              const SizedBox(height: AppSpacing.spaceMD),

              // Email
              TextFormField(
                decoration: _buildInputDecoration(
                  label: 'Email',
                  hint: 'name@student.vku.udn.vn',
                  icon: Icons.email_outlined,
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (v) {
                  // Lưu giá trị để validation realtime
                  email = v.trim();
                },
                onSaved: (v) => email = v?.trim(),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(v.trim())) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.spaceMD),

              // Số điện thoại
              TextFormField(
                decoration: _buildInputDecoration(
                  label: 'Số điện thoại',
                  hint: 'Ví dụ: 0912 345 678',
                  icon: Icons.phone_outlined,
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onChanged: (v) {
                  // Lưu giá trị để validation realtime
                  phoneNumber = v.trim();
                },
                onSaved: (v) => phoneNumber = v?.trim(),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Vui lòng nhập số điện thoại'
                    : null,
              ),
              const SizedBox(height: AppSpacing.spaceMD),

              // Mật khẩu
              TextFormField(
                decoration: _buildInputDecoration(
                  label: 'Mật khẩu',
                  hint: 'Tối thiểu 8 ký tự',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                onChanged: (v) {
                  // Trigger validation khi người dùng nhập
                  setState(() {
                    password = v;
                  });
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                  }
                },
                onSaved: (v) => password = v,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (v.length < 8) {
                    return 'Mật khẩu phải có ít nhất 8 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.spaceMD),

              // Xác nhận mật khẩu
              TextFormField(
                decoration: _buildInputDecoration(
                  label: 'Xác nhận mật khẩu',
                  hint: 'Nhập lại mật khẩu',
                  icon: Icons.lock_reset_rounded,
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.next,
                onChanged: (v) {
                  // Trigger validation khi người dùng nhập
                  setState(() {
                    confirmPassword = v;
                  });
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                  }
                },
                onSaved: (v) => confirmPassword = v,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (password != null && v != password) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.spaceMD),

              // Loại tài khoản
              if (unitsLoaded != null)
                DropdownButtonFormField<int>(
                  decoration: _buildInputDecoration(
                    label: 'Loại tài khoản',
                    hint: 'Chọn vai trò',
                    icon: Icons.account_tree_rounded,
                  ),
                  initialValue: unitsLoaded.selectedAccountTypeId,
                  isExpanded: true,
                  items: unitsLoaded.accountTypes
                      .map<DropdownMenuItem<int>>(
                        (UnitEntity u) => DropdownMenuItem(
                          value: u.id,
                          child: Text(
                            u.unitName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    // Ẩn bàn phím khi chọn dropdown
                    FocusScope.of(context).unfocus();
                    setState(() {
                      unitId = null;
                    });
                    if (value != null) {
                      context.read<RegisterBloc>().add(
                        RegisterAccountTypeChanged(value),
                      );
                    }
                  },
                  validator: (v) =>
                      v == null ? 'Vui lòng chọn loại tài khoản' : null,
                ),
              if (unitsLoaded != null &&
                  unitsLoaded.selectedAccountTypeId != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.spaceMD),
                  child: DropdownButtonFormField<int>(
                    decoration: _buildInputDecoration(
                      label: 'Đơn vị / Lớp',
                      hint: 'Chọn đơn vị hoặc lớp',
                      icon: Icons.apartment_rounded,
                    ),
                    initialValue: unitId,
                    isExpanded: true,
                    items: unitsLoaded.filteredUnits
                        .map<DropdownMenuItem<int>>(
                          (UnitEntity u) => DropdownMenuItem(
                            value: u.id,
                            child: Text(
                              u.unitName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      // Ẩn bàn phím khi chọn dropdown
                      FocusScope.of(context).unfocus();
                      setState(() => unitId = value);
                    },
                    validator: (v) =>
                        v == null ? 'Vui lòng chọn đơn vị / lớp' : null,
                  ),
                ),

              const SizedBox(height: AppSpacing.spaceLG),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        context.read<RegisterBloc>().add(
                          RegisterSubmitted(
                            name: name!,
                            email: email!,
                            phoneNumber: phoneNumber!,
                            password: password!,
                            confirmPassword: confirmPassword!,
                            unitId: unitId,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vkuBlue,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.spaceMD,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 1,
                    ),
                    child: Text(
                      'Đăng ký',
                      style: AppTextStyles.heading5.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.vkuBlue),
      filled: true,
      fillColor: AppColors.coolGray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.vkuBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMD,
        vertical: AppSpacing.spaceXM,
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.coolGray500,
              ),
              onPressed: onToggleObscure,
            )
          : null,
    );
  }
}
