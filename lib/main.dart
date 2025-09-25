import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/screens/onboarding/welcome_screen.dart';
import 'presentation/screens/setup/preserve_question_screen.dart';
import 'utils/auth_guard.dart';

void main() {
  runApp(const ProviderScope(child: RemoryApp()));
}

class RemoryApp extends StatelessWidget {
  const RemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remory',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          // Headings
          displayLarge: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800), // H1
          displayMedium: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700), // H2
          displaySmall: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600), // H3
          headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500), // H4
          headlineSmall: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500), // H5
          titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500), // H6

          // Body
          bodyLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400), // Body XLarge
          bodyMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400), // Body Large
          bodySmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400), // Body Medium
          labelSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400), // Body Small
        ),
      ),
      home: const OnboardingGuard(
        onboardingFlow: WelcomeScreen(),
        authenticatedFlow: PreserveQuestionScreen(),
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
    );
  }
}


