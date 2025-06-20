import 'package:event_booking/firebase_options.dart';
import 'package:event_booking/views/user/LandingPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:event_booking/controller/AuthController.dart';
import 'package:event_booking/controller/UserController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(AuthController()); // Inject controller
  Get.put(UserController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // 🔁 Use GetMaterialApp instead of MaterialApp
      debugShowCheckedModeBanner: false,
      home: const LandingPage(),
    );
  }
}
