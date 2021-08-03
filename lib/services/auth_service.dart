import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:noteit/helpers/helpers.dart';
import 'package:noteit/models/models.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }

    return User(id: user.uid, name: user.displayName);
  }

  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
  }

  Future<void> loginWithEmailAndPaswword(
      {@required String email, @required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on PlatformException catch (err) {
      String errorMessage;

      switch (err.code) {
        case 'ERROR_INVALID_EMAIL':
          errorMessage = 'Your email address is malformed.';
          break;
        case 'ERROR_WRONG_PASSWORD':
          errorMessage = 'Your password is incorrect.';
          break;
        case 'ERROR_USER_NOT_FOUND':
          errorMessage = 'User with this email doesn\'t exist.';
          break;
        case 'ERROR_USER_DISABLED':
          errorMessage = 'User with this email has been disabled.';
          break;
        case 'ERROR_TOO_MANY_REQUESTS':
          errorMessage = 'Too many requests. Try again later.';
          break;
        case 'ERROR_OPERATION_NOT_ALLOWED':
          errorMessage = 'Signing in with Email and Password is not enabled.';
          break;
        default:
          errorMessage = 'Something went wrong.';
      }

      throw Failure(errorMessage);
    }
  }

  Future<void> registerUser(
      {@required String name,
      @required String email,
      @required String password}) async {
    try {
      AuthResult authResult = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = name;
      FirebaseUser user = authResult.user;
      await user.updateProfile(updateInfo);
    } on PlatformException catch (err) {
      String errorMessage;

      switch (err.code) {
        case 'ERROR_WEAK_PASSWORD':
          errorMessage = 'Your password is not strong enough.';
          break;
        case 'ERROR_INVALID_CREDENTIAL':
          errorMessage = 'Your email address is malformed.';
          break;
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          errorMessage = 'The email has already been registered.';
          break;
        default:
          errorMessage = 'Something went wrong.';
      }

      throw Failure(errorMessage);
    }
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount googleAccount = await GoogleSignIn().signIn();

    if (googleAccount != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.getCredential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ),
        );
      } else {
        throw Failure('Missing google auth token');
      }
    } else {
      throw Failure('Google login aborted');
    }
  }

  Future<void> sendPasswordResetEmail({@required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on PlatformException catch (err) {
      String errorMessage;

      switch (err.code) {
        case 'ERROR_INVALID_EMAIL':
          errorMessage = 'Your email address is malformed.';
          break;
        case 'ERROR_USER_NOT_FOUND':
          errorMessage = 'User with this email doesn\'t exist.';
          break;
        default:
          errorMessage = 'Something went wrong.';
      }

      throw Failure(errorMessage);
    }
  }

  Future<void> logOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
