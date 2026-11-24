import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'pages/auth/pin_page.dart';
import 'pages/home_page.dart';
import 'services/local_db.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ar', null);
  await LocalDb.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فواتير صيانة المنزل',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: RootPage(),
      ),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool authenticated = false;

  @override
  Widget build(BuildContext context) {
    if (!authenticated) {
      return PinPage(
        isSetup: !LocalDb.hasPin,
        onSuccess: () {
          setState(() {
            authenticated = true;
          });
        },
      );
    }

    return HomePage(
      onLock: () {
        setState(() {
          authenticated = false;
        });
      },
    );
  }
}