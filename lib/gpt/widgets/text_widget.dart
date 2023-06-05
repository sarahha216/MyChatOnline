import 'package:flutter/cupertino.dart';

class TextWidget {
  static base({
    required String label,
})
  {
  return Text(
    label,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      ),
    );
  }
}