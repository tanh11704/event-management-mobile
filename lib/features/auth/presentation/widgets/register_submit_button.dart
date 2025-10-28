import 'package:flutter/material.dart';

class RegisterSubmitButton extends StatelessWidget {
  const RegisterSubmitButton({required this.onPressed, super.key});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: onPressed, child: const Text('Đăng ký')),
    );
  }
}
