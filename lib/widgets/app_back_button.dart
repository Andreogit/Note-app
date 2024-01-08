import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AppBackButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      customBorder: const CircleBorder(),
      radius: 15,
      onTap: onTap ??
          () {
            Navigator.of(context).pop();
          },
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
        ),
      ),
    );
  }
}
