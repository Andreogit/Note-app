// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/login_form.dart';
import '../../cubit/auth/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      child: Column(
        children: [
          LoginForm(
            message: "Log in to your account",
            onShowPassword: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
            showForgetPassword: true,
            context: context,
            obscurePassword: obscurePassword,
            onSubmit: () async {
              await context.read<AuthCubit>().signInWithEmail();
            },
            submitText: "Log in",
          ),
        ],
      ),
    );
  }
}
