import 'package:flutter/material.dart';

import 'dart:async';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isActivated;
  const SplashScreen({super.key, required this.isActivated});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        // 🔥 أثناء التطوير: تجاهل حالة التفعيل واذهب للرئيسية
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoWidth = size.width * 0.7;

    return Scaffold(
      backgroundColor: const Color.fromARGB(233, 104, 99, 132),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: logoWidth,
              height: logoWidth,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.school, size: 150, color: Colors.white);
              },
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
