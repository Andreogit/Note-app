import 'package:flutter/material.dart';
import 'package:noteapp/utils/colors.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppbar({Key? key, this.backgroundColor, this.content, this.leading}) : super(key: key);
  final Color? backgroundColor;
  final Widget? content;

  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.appBar,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: content ?? const SizedBox.shrink(),
                      ),
                      SizedBox(height: leading == null ? 0 : 20),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    top: MediaQuery.of(context).padding.top,
                    child: leading ?? const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}
