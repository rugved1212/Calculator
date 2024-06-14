import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'calculator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _splashscreen();
}

class _splashscreen extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: 3),
          () {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => Calculator()), (route) => false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: Container(
              color: Color.fromRGBO(36, 36, 35, 1),
              child: Center(
                  child: Container(
                      width: 200,
                      height: 200,
                      child: Lottie.asset('assets/animation/operatoranim.json')))),
        ));
  }
}
