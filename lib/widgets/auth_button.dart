import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String buttonName;

  final Function onPressed;
  final bool loading;

  AuthButton({
    @required this.buttonName,
    @required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      padding: const EdgeInsets.all(17.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2.0,
      child: Center(
        child: loading
            ? SizedBox(
                child: CircularProgressIndicator(strokeWidth: 3.0),
                height: 20.0,
                width: 20.0,
              )
            : Text(
                buttonName,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
