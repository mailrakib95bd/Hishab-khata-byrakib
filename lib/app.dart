import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/ledger/presentation/screens/ledger_screen.dart';
import 'core/theme/app_theme.dart';

class HishabKhataApp extends StatelessWidget {
  const HishabKhataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'হিসাব খাতা BD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('bn', 'BD'), // বাংলা
        Locale('en', 'US'), // ইংরেজি
      ],
      locale: const Locale('bn', 'BD'),
      home: const LedgerScreen(),
    );
  }
}
