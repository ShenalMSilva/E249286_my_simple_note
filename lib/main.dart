import 'package:flutter/material.dart';
import 'screens/notes_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primaryColor: Colors.lightGreen,
        scaffoldBackgroundColor: const Color.fromARGB(250, 250, 250, 250),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
        ),
      ),
      home: NotesPage(),
    );
  }
}