import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loom/app.dart';
import 'package:loom/config/firebase_options.dart';

void main() async {

  // Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}
