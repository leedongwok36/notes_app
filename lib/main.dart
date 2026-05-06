import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/note_provider.dart';
import 'screens/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NoteProvider()..loadNotes(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Note App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        quill.FlutterQuillLocalizations.delegate, // Cấu hình ngôn ngữ cho Quill
      ],
      supportedLocales: const [
        Locale('en', 'US'), // Ngôn ngữ tiếng Anh
        Locale('vi', 'VN'), // Ngôn ngữ tiếng Việt
      ],
      home: const HomePage(),
    );
  }
}