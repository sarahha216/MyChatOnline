import 'package:flutter/material.dart';
import 'dart:math';

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenRemove(context, page){
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>page), (route) => false);
}

void showSnackBar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
      )
  );
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void popUntil(context){
  int counter = 3;
  Navigator.of(context).popUntil((route) => counter-- <= 0);
}


// void showSnackbar(context, color, message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(
//         message,
//         style: const TextStyle(fontSize: 14),
//       ),
//       backgroundColor: color,
//       duration: const Duration(seconds: 2),
//       action: SnackBarAction(
//         label: "OK",
//         onPressed: () {},
//         textColor: Colors.white,
//       ),
//     ),
//   );
// }