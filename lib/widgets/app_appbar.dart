import 'package:flutter/material.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppbar({Key? key, this.backgroundColor, this.title, this.actions, this.leading}) : super(key: key);
  final Color? backgroundColor;
  final Widget? title;
  final List<Widget>? actions;

  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: leading,
      actions: actions,
      title: title,
      titleSpacing: 0,
      leadingWidth: leading == null ? 0 : 56,
      elevation: 0,
      backgroundColor: backgroundColor ?? Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}
