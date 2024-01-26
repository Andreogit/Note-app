import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension PushRemoveUntil on BuildContext {
  static void pushAndRemoveUntil(BuildContext context, String until, String path) {
    while ((context.canPop()) && ModalRoute.of(context)!.settings.name != path) {
      context.pop();
    }
    context.push(path);
  }
}
