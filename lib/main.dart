import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/screens/auth/login_screen.dart';
import 'package:flutter_frontend/presentation/screens/main/home_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/my_personal_space_screen.dart';
import 'package:flutter_frontend/presentation/screens/onboarding/welcome_screen.dart';
import 'package:flutter_frontend/providers/memory_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/memorial_provider.dart';
import 'presentation/screens/memorial/memorials_screen.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';

void main() {
  runApp(const RemoryApp());
}

class RemoryApp extends StatelessWidget {
  const RemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemorialProvider()),
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ChangeNotifierProvider(create: (_) => DocumentaryProvider())
      ],
      child: MaterialApp(
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
        home: const LoginScreen(),
        routes: {
          '/memorials': (_) => const MemorialsScreen(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
