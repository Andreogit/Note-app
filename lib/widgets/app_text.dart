import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText extends StatelessWidget {
  final String text;
  final FontWeight? fw;
  final double? size;
  final Color? color;
  const AppText(this.text, {Key? key, this.fw, this.size, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.lato(fontWeight: fw, fontSize: size, color: color),
    );
  }
}
