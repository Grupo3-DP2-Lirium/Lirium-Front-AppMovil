class ResetPasswordRequest {
  final String resetToken;
  final String newPassword;

  ResetPasswordRequest({
    required this.resetToken,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'resetToken': resetToken,
    'newPassword': newPassword,
  };
}
