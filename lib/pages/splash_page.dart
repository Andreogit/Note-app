import 'package:flutter/material.dart';
import 'package:noteapp/pages/auth/login_page.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/app_text.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Route fadeRouteBuilder(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  Future<void> checkRoute() async {
    await Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        fadeRouteBuilder(const LoginPage()),
      );
    });
  }

  @override
  void initState() {
    checkRoute();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: Image.asset(
                "assets/note.png",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 15),
            const AppText(
              "Notes",
              color: Colors.white,
              size: 40,
              fw: FontWeight.w600,
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}
