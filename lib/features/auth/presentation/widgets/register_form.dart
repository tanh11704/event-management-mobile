import 'package:event_management/features/auth/presentation/bloc/register_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/register_event.dart';
import 'package:event_management/features/auth/presentation/bloc/register_state.dart';
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
  String? accountType;
  int? unitId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
        }
        if (state is RegisterFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is RegisterLoading;
        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Họ tên'),
                onSaved: (v) => name = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (v) => email = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                onSaved: (v) => phoneNumber = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                onSaved: (v) => password = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                ),
                obscureText: true,
                onSaved: (v) => confirmPassword = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Loại tài khoản'),
                initialValue: accountType,
                items: const [
                  DropdownMenuItem(
                    value: 'sponsor',
                    child: Text('Nhà tài trợ'),
                  ),
                  DropdownMenuItem(value: 'student', child: Text('Sinh viên')),
                  DropdownMenuItem(value: 'teacher', child: Text('Giáo viên')),
                ],
                onChanged: (value) => setState(() => accountType = value),
                validator: (v) => v == null ? 'Bắt buộc' : null,
              ),
              if (accountType != null)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Đơn vị / Lớp'),
                  initialValue: unitId,
                  items: const [
                    DropdownMenuItem(value: 3, child: Text('HLE')),
                    DropdownMenuItem(value: 4, child: Text('KMA')),
                  ],
                  onChanged: (value) => setState(() => unitId = value),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
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
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Đăng ký'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
