import 'package:flutter/material.dart';
import 'package:noteapp/widgets/app_text.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key? key, this.onTap, required this.text, required this.icon, this.actions}) : super(key: key);
  final VoidCallback? onTap;
  final IconData icon;
  final String text;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 10),
                  AppText(
                    text,
                    size: 18,
                    fw: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                  const Spacer(),
                  actions ?? const SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
