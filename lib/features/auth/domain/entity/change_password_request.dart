class ChangePasswordRequest {
  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String oldPassword;

  final String newPassword;

  final String confirmPassword;
}
