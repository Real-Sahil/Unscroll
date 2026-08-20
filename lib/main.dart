import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  runApp(
    const FocusFeedApp(),
  );
}

class FocusFeedApp extends StatelessWidget {
  const FocusFeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UnScroll',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const UnScrollHome(),
      routes: AppRoutes.routes,
    );
  }
}

class UnScrollHome extends StatelessWidget {
  const UnScrollHome({super.key});

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
              'UnScroll',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Reclaim Your Time. Escape the Doomscroll.',
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
