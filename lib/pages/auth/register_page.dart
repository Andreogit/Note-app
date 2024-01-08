import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:noteapp/cubit/auth/auth_cubit.dart';
import 'package:noteapp/utils/routes.dart';

import '../../utils/colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/login_form.dart';
import '../../widgets/logo.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

bool obscurePassword = true;

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppScaffold(
          body: CustomScrollView(
            reverse: MediaQuery.of(context).viewInsets.bottom > 0 ? true : false,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    const Logo(),
                    LoginForm(
                      message: "Register an account",
                      onShowPassword: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      showForgetPassword: true,
                      context: context,
                      obscurePassword: obscurePassword,
                      onSubmit: () async {
                        await context.read<AuthCubit>().register().whenComplete(() {
                          if (FirebaseAuth.instance.currentUser != null) context.go(Routes.home);
                        });
                      },
                      submitText: "Continue",
                      bottomInfo: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            "Already have an account?",
                            fw: FontWeight.w600,
                            color: AppColors.darkGrey.withOpacity(0.7),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                context.go(Routes.login);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: AppText(
                                  "Sign in",
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
