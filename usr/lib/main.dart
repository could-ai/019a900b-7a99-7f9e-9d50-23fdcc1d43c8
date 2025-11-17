import 'package:couldai_user_app/typing_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touch Typing Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF282C34),
        primaryColor: const Color(0xFF61AFEE),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFABB2BF)),
          bodyMedium: TextStyle(color: Color(0xFFABB2BF)),
        ),
      ),
      home: const TypingPage(),
    );
  }
}
