import 'package:flutter/foundation.dart';
import 'package:noteit/helpers/helpers.dart';
import 'package:noteit/services/auth_service.dart';

class LoginChangeNotifier with ChangeNotifier {
  final AuthService authService;
  bool autoValidate;
  bool passwordVisibility;
  bool isLoginLoading;
  bool isLoginWithGoogleLoading;

  LoginChangeNotifier({
    @required this.authService,
    this.autoValidate = false,
    this.passwordVisibility = false,
    this.isLoginLoading = false,
    this.isLoginWithGoogleLoading = false,
  });

  void updateWith(
      {bool autoValidate,
      bool passwordVisibility,
      bool isLoginLoading,
      bool isLoginWithGoogleLoading}) {
    this.autoValidate = autoValidate ?? this.autoValidate;
    this.passwordVisibility = passwordVisibility ?? this.passwordVisibility;
    this.isLoginLoading = isLoginLoading ?? this.isLoginLoading;
    this.isLoginWithGoogleLoading =
        isLoginWithGoogleLoading ?? this.isLoginWithGoogleLoading;
    notifyListeners();
  }

  void reset() {
    updateWith(
      autoValidate: false,
      isLoginLoading: false,
      isLoginWithGoogleLoading: false,
      passwordVisibility: false,
    );
  }

  Future<void> login(
      {@required String email, @required String password}) async {
    try {
      updateWith(isLoginLoading: true);
      await authService.loginWithEmailAndPaswword(
          email: email, password: password);
    } on Failure {
      updateWith(isLoginLoading: false);
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      updateWith(isLoginWithGoogleLoading: true);
      await authService.signInWithGoogle();
    } on Failure {
      updateWith(isLoginWithGoogleLoading: false);
      rethrow;
    }
  }
}
