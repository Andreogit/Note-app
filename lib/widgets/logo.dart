import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_text.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppText(
                  "No",
                  size: 60,
                  fw: FontWeight.w600,
                ),
                SizedBox(
                  height: 50,
                  child: Image.asset(
                    "assets/images/T.png",
                    fit: BoxFit.fitHeight,
                  ),
                ),
                const AppText(
                  "os",
                  size: 60,
                  fw: FontWeight.w600,
                ),
              ],
            ),
          ),
          Text(
            "Write your dreams",
            style: GoogleFonts.pacifico(
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}
