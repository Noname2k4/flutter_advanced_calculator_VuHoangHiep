import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/calculator_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/calculator_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProviderApp()),
      ],
      child: Consumer<ThemeProviderApp>(
        builder: (context, theme, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode:
                theme.isDark ? ThemeMode.dark : ThemeMode.light,
            darkTheme: ThemeData.dark(),
            theme: ThemeData.light(),
            home: const CalculatorScreen(),
          );
        },
      ),
    );
  }
}