import 'package:event_management/features/auth/presentation/bloc/change_password/change_password_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password/change_password_event.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password/change_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  String? oldPassword;
  String? newPassword;
  String? confirmPassword;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đổi mật khẩu thành công!')),
          );
        }
        if (state is ChangePasswordFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is ChangePasswordLoading;
        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mật khẩu cũ'),
                obscureText: true,
                onSaved: (v) => oldPassword = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                obscureText: true,
                onSaved: (v) => newPassword = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                ),
                obscureText: true,
                onSaved: (v) => confirmPassword = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      context.read<ChangePasswordBloc>().add(
                        ChangePasswordSubmitted(
                          oldPassword: oldPassword!,
                          newPassword: newPassword!,
                          confirmPassword: confirmPassword!,
                        ),
                      );
                    }
                  },
                  child: const Text('Đổi mật khẩu'),
                ),
            ],
          ),
        );
      },
    );
  }
}
