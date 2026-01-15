import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gkfwqnwxkaohvwyenodb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrZndxbnd4a2FvaHZ3eWVub2RiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyMDg5NzYsImV4cCI6MjA4Mzc4NDk3Nn0.TxaKBVelW8j4HhMZf4gDU85M1td5d6OwVRyoJolPcMY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
    return const MaterialApp(
      home: LoginPage(),
    );
  }
}
