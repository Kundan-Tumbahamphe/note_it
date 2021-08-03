import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:noteit/components/login_clipper.dart';
import 'package:noteit/configs/configs.dart';
import 'package:noteit/screens/screens.dart';
import 'package:noteit/changeNotifiers/login_change_notifier.dart';
import 'package:noteit/services/services.dart';
import 'package:noteit/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:noteit/helpers/helpers.dart';

class LoginScreen extends StatefulWidget {
  static Widget create(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return ChangeNotifierProvider<LoginChangeNotifier>(
      create: (_) => LoginChangeNotifier(authService: authService),
      child: LoginScreen(),
    );
  }

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email, _password;

  Future<void> _login(LoginChangeNotifier loginModel) async {
    try {
      await loginModel.login(email: _email, password: _password);
    } on Failure catch (e) {
      _showSnackBar(e.message);
    }
  }

  Future<void> _loginWithGoogle(LoginChangeNotifier loginModel) async {
    try {
      await loginModel.loginWithGoogle();
    } on Failure catch (e) {
      _showSnackBar(e.message);
    }
  }

  void _resetState(LoginChangeNotifier loginModel) {
    loginModel.reset();
    _loginFormKey.currentState.reset();
    _scaffoldKey.currentState.removeCurrentSnackBar();
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Row(
        children: <Widget>[
          const Icon(Icons.error_outline, size: 22.0),
          const SizedBox(width: 5.0),
          Text(message),
        ],
      ),
    );

    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            height: screenSize.height - MediaQuery.of(context).padding.top,
            child: Stack(
              children: <Widget>[
                ClipPath(
                  clipper: LoginClipper(),
                  child: Container(
                    height: 240.0,
                    width: double.infinity,
                    color: Constants.mainDesignColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 90.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'NoteIt',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 58.0),
                  child: Consumer<LoginChangeNotifier>(
                      builder: (_, loginModel, __) {
                    return Form(
                      key: _loginFormKey,
                      autovalidate: loginModel.autoValidate,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          AuthTextFormField(
                            label: 'Email',
                            obscure: false,
                            prefixIconData: Icons.mail_outline,
                            type: TextInputType.emailAddress,
                            validator: (inputValue) => inputValue.trim().isEmpty
                                ? 'Email is required'
                                : null,
                            onSaved: (inputValue) {
                              _email = inputValue;
                            },
                          ),
                          const SizedBox(height: 15.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              AuthTextFormField(
                                label: 'Password',
                                obscure: !loginModel.passwordVisibility,
                                prefixIconData: Icons.lock_outline,
                                type: TextInputType.visiblePassword,
                                suffixIcon: loginModel.passwordVisibility
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                suffixIconOnTap: () {
                                  loginModel.updateWith(
                                      passwordVisibility:
                                          !loginModel.passwordVisibility);
                                },
                                validator: (inputValue) =>
                                    inputValue.trim().isEmpty
                                        ? 'Password is required'
                                        : null,
                                onSaved: (inputValue) {
                                  _password = inputValue;
                                },
                              ),
                              const SizedBox(height: 15.0),
                              GestureDetector(
                                onTap: () {
                                  _resetState(loginModel);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PasswordResetScreen.create(context),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forget Password ?',
                                  style: const TextStyle(
                                      fontSize: 13.0,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30.0),
                          AuthButton(
                            buttonName: 'Login',
                            loading: loginModel.isLoginLoading,
                            onPressed: () {
                              if (_loginFormKey.currentState.validate()) {
                                _loginFormKey.currentState.save();
                                _login(loginModel);
                              } else {
                                loginModel.updateWith(autoValidate: true);
                              }
                            },
                          ),
                          const SizedBox(height: 20.0),
                          RaisedButton(
                            onPressed: () => _loginWithGoogle(loginModel),
                            padding: const EdgeInsets.all(17.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: Constants.mainDesignColor,
                            elevation: 2.0,
                            child: loginModel.isLoginWithGoogleLoading
                                ? Center(
                                    child: SizedBox(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 3.0),
                                      height: 20.0,
                                      width: 20.0,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Icon(
                                        MdiIcons.google,
                                        color: Colors.black87,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        'Login with Google',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('No Account ? '),
                              GestureDetector(
                                onTap: () {
                                  _resetState(loginModel);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          RegisterScreen.create(context),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Register Here',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
