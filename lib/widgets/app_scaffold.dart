// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:noteapp/widgets/app_background.dart';

class AppScaffold extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  const AppScaffold({
    Key? key,
    this.body,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AppBackground(),
          body != null ? body! : const SizedBox(),
        ],
      ),
    );
  }
}
