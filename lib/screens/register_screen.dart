import 'package:flutter/material.dart';
import 'package:noteit/changeNotifiers/register_change_notifier.dart';
import 'package:noteit/helpers/helpers.dart';
import 'package:noteit/services/auth_service.dart';
import 'package:noteit/widgets/widgets.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  static Widget create(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return ChangeNotifierProvider<RegisterChangeNotifier>(
      create: (_) => RegisterChangeNotifier(authService: authService),
      child: RegisterScreen(),
    );
  }

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _registerFormKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _passwordController = TextEditingController();
  String _name, _email, _password;

  Future<void> _register(RegisterChangeNotifier registerModel) async {
    try {
      await registerModel.register(
          name: _name, email: _email, password: _password);
      Navigator.of(context).pop();
    } on Failure catch (e) {
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.fixed,
        content: Row(
          children: <Widget>[
            const Icon(Icons.error_outline, size: 22.0),
            const SizedBox(width: 5.0),
            Text(e.message),
          ],
        ),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(elevation: 0.0),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Builder(builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height -
                Scaffold.of(context).appBarMaxHeight,
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Consumer<RegisterChangeNotifier>(
              builder: (_, registerModel, __) => Form(
                key: _registerFormKey,
                autovalidate: registerModel.autoValidate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: Text(
                        'NoteIt',
                        style: const TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    AuthTextFormField(
                      label: 'Name',
                      obscure: false,
                      prefixIconData: Icons.person_outline,
                      type: TextInputType.text,
                      validator: (inputValue) {
                        if (inputValue.trim().isEmpty) {
                          return 'Name is required';
                        } else if (!Validator.validName(inputValue)) {
                          return 'Name must be a-z or A-z';
                        }

                        return null;
                      },
                      onSaved: (inputValue) {
                        _name = inputValue;
                      },
                    ),
                    const SizedBox(height: 15.0),
                    AuthTextFormField(
                      label: 'Email',
                      obscure: false,
                      prefixIconData: Icons.mail_outline,
                      type: TextInputType.emailAddress,
                      validator: (inputValue) {
                        if (inputValue.trim().isEmpty) {
                          return 'Email is required';
                        } else if (!Validator.validEmail(inputValue)) {
                          return 'Invalid Email';
                        }

                        return null;
                      },
                      onSaved: (inputValue) {
                        _email = inputValue;
                      },
                    ),
                    const SizedBox(height: 15.0),
                    AuthTextFormField(
                      controller: _passwordController,
                      label: 'Password',
                      obscure: !registerModel.passwordVisibility,
                      prefixIconData: Icons.lock_outline,
                      type: TextInputType.visiblePassword,
                      suffixIcon: registerModel.passwordVisibility
                          ? Icons.visibility
                          : Icons.visibility_off,
                      suffixIconOnTap: () {
                        registerModel.updateWith(
                            passwordVisibility:
                                !registerModel.passwordVisibility);
                      },
                      validator: (inputValue) {
                        if (inputValue.trim().isEmpty) {
                          return 'Password is required';
                        } else if (!Validator.validPassword(inputValue)) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                      onSaved: (inputValue) {
                        _password = inputValue;
                      },
                    ),
                    const SizedBox(height: 15.0),
                    AuthTextFormField(
                      label: 'Confirm Password',
                      obscure: !registerModel.confirmPasswordVisibility,
                      prefixIconData: Icons.lock_outline,
                      type: TextInputType.visiblePassword,
                      suffixIcon: registerModel.confirmPasswordVisibility
                          ? Icons.visibility
                          : Icons.visibility_off,
                      suffixIconOnTap: () {
                        registerModel.updateWith(
                            confirmPasswordVisibility:
                                !registerModel.confirmPasswordVisibility);
                      },
                      validator: (inputValue) {
                        if (inputValue.trim().isEmpty) {
                          return 'Confirm password is required';
                        } else if (inputValue != _passwordController.text) {
                          return 'Password not matched';
                        }

                        return null;
                      },
                      onSaved: null,
                    ),
                    const SizedBox(height: 40.0),
                    AuthButton(
                      buttonName: 'Register',
                      loading: registerModel.isRegisterLoading,
                      onPressed: () {
                        if (_registerFormKey.currentState.validate()) {
                          _registerFormKey.currentState.save();
                          _register(registerModel);
                        } else {
                          registerModel.updateWith(autoValidate: true);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
