// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Color? bgColor;
  final Widget? body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Key? scaffoldKey;
  final PreferredSizeWidget? appBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  const AppScaffold({
    Key? key,
    this.body,
    this.appBar,
    this.bgColor,
    this.drawer,
    this.scaffoldKey,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: floatingActionButtonLocation ?? FloatingActionButtonLocation.centerDocked,
      floatingActionButton: floatingActionButton,
      key: scaffoldKey,
      drawer: drawer,
      backgroundColor: bgColor ?? Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: appBar,
      body: body != null ? body! : const SizedBox(),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
