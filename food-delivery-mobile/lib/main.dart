import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart'; // ← Commented out per setup instructions
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 FIREBASE SETUP (COMMENTED OUT UNTIL CONFIGURED)
  // await Firebase.initializeApp();
  // await FirebaseMessaging.instance.requestPermission();

  runApp(
    // Riverpod scope must wrap the entire app
    const ProviderScope(
      child: RestaurantDirectDriverApp(),
    ),
  );
}