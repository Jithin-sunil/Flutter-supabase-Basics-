import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/dashboard.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wowplhhxxcpximnejqmp.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indvd3BsaGh4eGNweGltbmVqcW1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIyNDczMDUsImV4cCI6MjA0NzgyMzMwNX0.xmR6TY_ZDqHvJSv-y5k2cCOhaD0Mmjynq-BGjHV-8DY', // Replace with your Supabase anon key
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard()
    );
  }
}
