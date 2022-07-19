import 'package:flutter/material.dart';
import 'dashboard.dart';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'dashboard',
            theme: ThemeData(
                brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
                brightness: Brightness.dark,
            ),
            themeMode: ThemeMode.dark, 
            /* ThemeMode.system to follow system theme, 
               ThemeMode.light for light theme, 
               ThemeMode.dark for dark theme
            */
            debugShowCheckedModeBanner: false,
            home: const Dashboard(),
        );
    }
}
