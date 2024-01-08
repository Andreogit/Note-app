import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth/auth_cubit.dart';
import '../utils/colors.dart';
import 'app_text.dart';
import 'app_textfield.dart';
import 'login_with.dart';

class LoginForm extends StatelessWidget {
  final BuildContext context;
  final String? message;
  final Widget? bottomInfo;
  final String? submitText;
  final void Function()? onSubmit;
  final void Function()? onShowPassword;
  final bool? showForgetPassword;
  final bool? obscurePassword;
  const LoginForm({
    Key? key,
    this.onSubmit,
    required this.obscurePassword,
    this.showForgetPassword,
    this.onShowPassword,
    required this.context,
    this.submitText,
    this.bottomInfo,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + (MediaQuery.of(context).viewInsets.bottom / 2.2),
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            AppText(
              message ?? "",
              size: 28,
              fw: FontWeight.w600,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  AppTextField(
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    onChanged: context.read<AuthCubit>().changeEmail,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 40),
                  AppTextField(
                    obscure: obscurePassword,
                    hintText: "Password",
                    keyboardType: TextInputType.visiblePassword,
                    onChanged: context.read<AuthCubit>().changePassword,
                    textInputAction: TextInputAction.done,
                    action: IconButton(
                      icon: Icon(
                        obscurePassword == true ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: AppColors.lightGray,
                      ),
                      onPressed: onShowPassword,
                    ),
                  ),
                  const SizedBox(height: 9),
                  showForgetPassword == true
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppText(
                              "Forgot password?",
                              color: Colors.blue,
                              fw: FontWeight.w700,
                            ),
                          ],
                        )
                      : const SizedBox(),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return AppText(
                        state.errorText,
                        color: Colors.black,
                        size: 16,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onSubmit,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF39E1F),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: SizedBox(
                              height: 50,
                              child: Center(
                                child: BlocBuilder<AuthCubit, AuthState>(
                                  buildWhen: (previous, current) => previous.loading != current.loading,
                                  builder: (context, state) {
                                    return state.loading
                                        ? const SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: Colors.white,
                                            ),
                                          )
                                        : AppText(
                                            submitText ?? "",
                                            textAlign: TextAlign.center,
                                            color: Colors.white,
                                            fw: FontWeight.w600,
                                            size: 19,
                                          );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  AppText(
                    "Other ways",
                    letterSpacing: 0.2,
                    size: 18,
                    fw: FontWeight.w700,
                    color: AppColors.darkGrey.withOpacity(0.6),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoginWith(
                        imageAsset: "assets/images/google-logo.png",
                        onTap: () async {
                          await context.read<AuthCubit>().signInWithGoogle();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  bottomInfo == null ? const SizedBox() : bottomInfo!,
                  Container(
                    padding: const EdgeInsets.only(top: 400),
                    height: 0,
                    width: 0,
                    child: OverflowBox(
                      maxHeight: 600,
                      maxWidth: MediaQuery.of(context).size.width,
                      child: Container(
                        color: Colors.white,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
