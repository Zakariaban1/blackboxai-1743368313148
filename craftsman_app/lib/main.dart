import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_rtl/flutter_rtl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:craftsman_app/firebase/firebase_config.dart';
import 'package:craftsman_app/localization/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  runApp(const ProviderScope(child: CraftsmanApp()));
}

class CraftsmanApp extends StatelessWidget {
  const CraftsmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RTL(
      child: MaterialApp(
        title: 'Craftsman App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Amiri',
          primarySwatch: Colors.blue,
        ),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement auth state handling
    return const LoginScreen();
  }
}