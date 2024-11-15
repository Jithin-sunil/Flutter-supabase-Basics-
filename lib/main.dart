import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/district.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://uizjhuexeotwhoppabms.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpempodWV4ZW90d2hvcHBhYm1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE2NjgxMTEsImV4cCI6MjA0NzI0NDExMX0.fseHcYVt5ipT9bRVyDk7mrhimMBbQT48GCgT6WnxWYM', // Replace with your Supabase anon key
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: District()
    );
  }
}
