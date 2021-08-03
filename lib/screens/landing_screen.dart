import 'package:flutter/material.dart';
import 'package:noteit/models/models.dart';
import 'package:noteit/screens/screens.dart';
import 'package:noteit/services/services.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User>(
      stream: authService.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User user = snapshot.data;
          if (user == null) {
            return LoginScreen.create(context);
          }
          return MultiProvider(
            providers: [
              Provider<User>.value(value: user),
              Provider<DatabaseService>(
                create: (_) => DatabaseService(userId: user.id),
              ),
              Provider<StorageService>(
                create: (_) => StorageService(),
              ),
            ],
            child: HomeScreen(),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
