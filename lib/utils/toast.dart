import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noteapp/utils/colors.dart';

class AppToast {
  static Future<void> showToast(String text, {bool? long}) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: text,
      toastLength: long == true ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: AppColors.text,
      fontSize: 16.0,
    );
  }
}
