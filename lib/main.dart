import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YouTubeXApp());
}

class YouTubeXApp extends StatelessWidget {
  const YouTubeXApp({super.key});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFFF0033);
    return MaterialApp(
      title: 'YouTube X',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: ColorScheme.fromSeed(seedColor: red, brightness: Brightness.dark),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0F0F0F), elevation: 0),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
