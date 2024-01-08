// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:noteapp/widgets/app_scaffold.dart';

import '../../utils/colors.dart';
import '../../utils/routes.dart';
import '../../widgets/app_text.dart';
import '../../widgets/login_form.dart';
import '../../widgets/logo.dart';
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppScaffold(
          body: CustomScrollView(
            reverse: MediaQuery.of(context).viewInsets.bottom > 200 ? true : false,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    const Logo(),
                    LoginForm(
                      message: "Hello again  👋",
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
                      submitText: "Login",
                      bottomInfo: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            "Dont have an account",
                            fw: FontWeight.w600,
                            color: AppColors.darkGrey.withOpacity(0.7),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                context.go(Routes.register);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: AppText(
                                  "Sign up",
                                  fw: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
