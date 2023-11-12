import 'package:flutter/material.dart';
import 'package:noteapp/utils/colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                stops: [0.01, 1],
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
                colors: [AppColors.bg1, AppColors.bg2],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
