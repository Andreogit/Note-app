import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noteapp/utils/colors.dart';

class AppText extends StatelessWidget {
  final String text;
  final FontWeight? fw;
  final double? size;
  final Color? color;
  final TextAlign? textAlign;
  final double? letterSpacing;
  final TextOverflow? overflow;
  const AppText(this.text, {Key? key, this.fw, this.size, this.color, this.textAlign, this.letterSpacing, this.overflow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: overflow,
      textAlign: textAlign,
      style: GoogleFonts.roboto(fontWeight: fw, fontSize: size, color: color ?? AppColors.text, letterSpacing: letterSpacing),
    );
  }
}
