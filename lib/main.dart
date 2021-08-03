import 'package:flutter/material.dart';
import 'package:noteit/changeNotifiers/theme_change_notifier.dart';
import 'package:noteit/configs/themes.dart';
import 'package:noteit/services/services.dart';
import 'package:provider/provider.dart';
import 'package:noteit/screens/screens.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChangeNotifier>(
          create: (_) => ThemeChangeNotifier(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: Consumer<ThemeChangeNotifier>(builder: (_, themeNotifier, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NoteIt',
          theme:
              themeNotifier.isDarkTheme ? Themes.darkTheme : Themes.lightTheme,
          home: LandingScreen(),
        );
      }),
    );
  }
}
