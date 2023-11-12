import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noteapp/utils/colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String str)? onChanged;
  final String? hintText;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Widget? action;
  final bool? obscure;
  const AppTextField({
    super.key,
    this.onChanged,
    this.controller,
    this.hintText,
    this.textInputAction,
    this.focusNode,
    this.action,
    this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 5, right: action == null ? 0 : 45),
              child: TextField(
                obscureText: obscure ?? false,
                focusNode: focusNode,
                onTapOutside: (p) {
                  FocusScope.of(context).unfocus();
                },
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration.collapsed(
                  hintText: hintText,
                  hintStyle: GoogleFonts.lato(fontWeight: FontWeight.w600, color: AppColors.lightGray),
                ),
                textInputAction: textInputAction,
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 1.6, color: AppColors.lightGray)
          ],
        ),
        action != null ? Positioned(right: 0, bottom: -6, child: action!) : const SizedBox(),
      ],
    );
  }
}
