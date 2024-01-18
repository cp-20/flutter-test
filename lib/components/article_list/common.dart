import 'package:flutter/material.dart';

const loadLimit = 20;

notifySnackBar(BuildContext context, String message, void Function() onUndo,
    Animation<double> animation) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    action: SnackBarAction(
      label: '元に戻す',
      onPressed: onUndo,
    ),
    content: Text(message),
    duration: const Duration(milliseconds: 1000),
    margin: const EdgeInsets.all(16),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    animation: CurvedAnimation(
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
      parent: animation.drive(Tween<double>(
        begin: 0.0,
        end: 1.0,
      )),
    ),
  ));
}
