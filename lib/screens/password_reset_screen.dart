import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:noteit/changeNotifiers/password_reset_change_notifier.dart';
import 'package:noteit/services/auth_service.dart';
import 'package:noteit/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:noteit/helpers/helpers.dart';

class PasswordResetScreen extends StatefulWidget {
  static Widget create(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return ChangeNotifierProvider<PasswordResetChangeNotifier>(
      create: (_) => PasswordResetChangeNotifier(authService: authService),
      child: PasswordResetScreen(),
    );
  }

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _resetFormKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email;

  Future<void> _sendEmail(PasswordResetChangeNotifier model) async {
    try {
      await model.sendPasswordResetEmail(email: _email);
      _resetFormKey.currentState.reset();
      model.updateWith(autoValidate: false);
      _showSnackBar('A password reset link has been sent to $_email',
          Icons.check_circle_outline);
    } on Failure catch (e) {
      _showSnackBar(e.message, Icons.error_outline);
    }
  }

  void _showSnackBar(String message, IconData icon) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Container(
        child: Row(
          children: <Widget>[
            Icon(icon, size: 22.0),
            const SizedBox(width: 5.0),
            Expanded(
              child: Text(message, maxLines: 2),
            ),
          ],
        ),
      ),
    );

    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
        title: Text(
          'Forget Password',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Builder(builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height -
                Scaffold.of(context).appBarMaxHeight,
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Consumer<PasswordResetChangeNotifier>(
              builder: (_, model, __) => Form(
                key: _resetFormKey,
                autovalidate: model.autoValidate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: const Icon(MdiIcons.emailSendOutline, size: 60.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Hey, please enter you email address below and we\'ll send you a password reset link',
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 16.0, letterSpacing: 0.5),
                      ),
                    ),
                    AuthTextFormField(
                      label: 'Email',
                      obscure: false,
                      prefixIconData: Icons.mail_outline,
                      type: TextInputType.emailAddress,
                      validator: (inputValue) {
                        if (inputValue.trim().isEmpty) {
                          return 'Email is required';
                        }

                        return null;
                      },
                      onSaved: (inputValue) {
                        _email = inputValue;
                      },
                    ),
                    const SizedBox(height: 40.0),
                    AuthButton(
                      buttonName: 'Submit',
                      onPressed: () {
                        if (_resetFormKey.currentState.validate()) {
                          _resetFormKey.currentState.save();
                          _sendEmail(model);
                        } else {
                          model.updateWith(autoValidate: true);
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
}
