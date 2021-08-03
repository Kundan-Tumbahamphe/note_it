import 'package:flutter/foundation.dart';
import 'package:noteit/helpers/helpers.dart';
import 'package:noteit/services/auth_service.dart';

class PasswordResetChangeNotifier with ChangeNotifier {
  final AuthService authService;
  bool autoValidate;
  bool isLoading;

  PasswordResetChangeNotifier({
    @required this.authService,
    this.autoValidate = false,
    this.isLoading = false,
  });

  void updateWith({
    bool autoValidate,
    bool isLoading,
  }) {
    this.autoValidate = autoValidate ?? this.autoValidate;
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail({@required String email}) async {
    try {
      updateWith(isLoading: true);
      await authService.sendPasswordResetEmail(email: email);
    } on Failure {
      updateWith(isLoading: false);
      rethrow;
    }
  }
}
