import 'package:flutter/material.dart';

import '../utils/colors.dart';

class LoginWith extends StatelessWidget {
  final String imageAsset;
  final EdgeInsets? padding;
  final void Function()? onTap;
  const LoginWith({
    super.key,
    this.onTap,
    required this.imageAsset,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(8),
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.lightGray,
          ),
        ),
        child: Image.asset(
          imageAsset,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
