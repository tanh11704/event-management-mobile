import 'package:flutter/material.dart';

class RegisterUnitField extends StatelessWidget {
  const RegisterUnitField({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Đơn vị / Lớp'),
      initialValue: value,
      items: const [
        DropdownMenuItem(value: 'HLE', child: Text('HLE')),
        DropdownMenuItem(value: 'KMA', child: Text('KMA')),
      ],
      onChanged: onChanged,
    );
  }
}
