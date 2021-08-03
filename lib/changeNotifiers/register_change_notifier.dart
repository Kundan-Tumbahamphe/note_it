import 'package:flutter/foundation.dart';
import 'package:noteit/helpers/helpers.dart';
import 'package:noteit/services/auth_service.dart';

class RegisterChangeNotifier with ChangeNotifier {
  final AuthService authService;
  bool autoValidate;
  bool passwordVisibility;
  bool confirmPasswordVisibility;
  bool isRegisterLoading;

  RegisterChangeNotifier({
    @required this.authService,
    this.autoValidate = false,
    this.passwordVisibility = false,
    this.confirmPasswordVisibility = false,
    this.isRegisterLoading = false,
  });

  void updateWith(
      {bool autoValidate,
      bool passwordVisibility,
      bool confirmPasswordVisibility,
      bool isRegisterLoading}) {
    this.autoValidate = autoValidate ?? this.autoValidate;
    this.passwordVisibility = passwordVisibility ?? this.passwordVisibility;
    this.confirmPasswordVisibility =
        confirmPasswordVisibility ?? this.confirmPasswordVisibility;
    this.isRegisterLoading = isRegisterLoading ?? this.isRegisterLoading;
    notifyListeners();
  }

  Future<void> register(
      {@required String name,
      @required String email,
      @required String password}) async {
    try {
      updateWith(isRegisterLoading: true);
      await authService.registerUser(
          name: name, email: email, password: password);
    } on Failure {
      updateWith(isRegisterLoading: false);
      rethrow;
    }
  }
}
