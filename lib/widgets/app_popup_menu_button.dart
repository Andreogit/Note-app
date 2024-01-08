// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class AppPopupMenuButton extends StatelessWidget {
  final List<Widget> items;
  final Widget? child;
  final Icon? icon;
  final Offset? offset;
  const AppPopupMenuButton({
    Key? key,
    required this.items,
    this.child,
    this.icon,
    this.offset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        icon: icon,
        splashRadius: 22,
        tooltip: "",
        elevation: 0,
        padding: EdgeInsets.zero,
        offset: offset ?? const Offset(20, 35),
        color: Colors.transparent,
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: items,
                ),
              ),
            ),
          ];
        },
        child: child);
  }
}
