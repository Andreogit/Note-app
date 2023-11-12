import 'package:flutter/material.dart';
import 'package:noteapp/utils/colors.dart';
import 'package:noteapp/widgets/app_scaffold.dart';
import 'package:noteapp/widgets/app_text.dart';

import '../../widgets/app_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          const Column(
            children: [
              AppText(
                "Note app",
                color: Colors.white,
                size: 60,
                fw: FontWeight.w600,
              ),
              SizedBox(height: 10),
              AppText(
                "Write your dreams",
                color: Colors.white,
                size: 25,
              ),
            ],
          ),
          SingleChildScrollView(
            reverse: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(20),
                height: 500,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    const AppText(
                      "Hello again",
                      size: 28,
                      fw: FontWeight.w600,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          AppTextField(
                            hintText: "User name",
                            onChanged: (str) {},
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 40),
                          AppTextField(
                            obscure: obscurePassword,
                            hintText: "Password",
                            onChanged: (str) {},
                            textInputAction: TextInputAction.done,
                            action: IconButton(
                              icon: Icon(
                                Icons.remove_red_eye_rounded,
                                color: obscurePassword == true ? AppColors.lightGray : AppColors.darkGrey,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
