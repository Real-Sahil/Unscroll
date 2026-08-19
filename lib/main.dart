import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/theme.dart';
import 'config/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(
    const ProviderScope(
      child: FocusFeedApp(),
    ),
  );
}

class FocusFeedApp extends StatelessWidget {
  const FocusFeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFeed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const FocusFeedHome(),
      routes: AppRoutes.routes,
    );
  }
}

class FocusFeedHome extends StatelessWidget {
  const FocusFeedHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'FocusFeed',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Addiction-Focused Doomscroll Blocker',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            ElevatedButton.large(
              onPressed: () {
                Navigator.pushNamed(context, '/onboarding');
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
