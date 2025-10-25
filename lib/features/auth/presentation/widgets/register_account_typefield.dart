import 'package:flutter/material.dart';

class RegisterAccountTypeField extends StatelessWidget {
  const RegisterAccountTypeField({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Loại tài khoản'),
      initialValue: value,
      items: const [
        DropdownMenuItem(value: 'sponsor', child: Text('Nhà tài trợ')),
        DropdownMenuItem(value: 'student', child: Text('Sinh viên')),
        DropdownMenuItem(value: 'teacher', child: Text('Giáo viên')),
      ],
      onChanged: onChanged,
    );
  }
}
