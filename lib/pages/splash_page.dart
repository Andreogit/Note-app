import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:noteapp/cubit/auth/auth_cubit.dart';
import 'package:noteapp/cubit/notes/notes_cubit.dart';
import 'package:noteapp/utils/routes.dart';

import '../widgets/app_scaffold.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser == null) {
        context.go(Routes.login);
      } else {
        context.go(Routes.home);
      }
    });
  }

  @override
  void initState() {
    context.read<AuthCubit>().init();
    context.read<NotesCubit>().init();
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
                "assets/images/note.png",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
