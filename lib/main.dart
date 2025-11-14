// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loom/config/firebase_options.dart';
import 'package:loom/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supabase
  await Supabase.initialize(
    url: 'https://ccxgqsdseuebtosbzczq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNjeGdxc2RzZXVlYnRvc2J6Y3pxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4ODc5ODEsImV4cCI6MjA3ODQ2Mzk4MX0.L0-mWct5DUucp-FZSjPyZkBJOqSHAwKu8JNhDWbG6Xs',
  );

  runApp(App());
}
