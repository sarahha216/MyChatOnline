import 'package:flutter/material.dart';

class ListViewWidget{
  static base({
    String? title,
    TextStyle ? textStyle,
    Color? colorIcon,
    Icon? icon,
    VoidCallback? voidCallback,
  }){
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1.2))),
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: colorIcon,
        textColor: colorIcon,
        leading: icon,
        title: Text('$title', style: textStyle,),
        onTap: voidCallback
        ),
      );
  }
}


class DialogYesNoWidget{static base({
  required BuildContext context,
  required String? title,
  required String? content,
  VoidCallback? voidCallback,
}){
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$title'),
          content: Text('$content'),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: const Text('Cancel')
            ),
            TextButton(
                onPressed: voidCallback,
                child: const Text('OK')
            ),
          ],
        );
      });
  }
}

class DialogInfoWidget{static base({
  required BuildContext context,
  required Widget? title,
  required Widget? content,
  List<Widget>? action,
  VoidCallback? voidCallback,
}){
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: title,
          content: content,
          actions: action,
        );
      });
}
}

class DialogChangeInfoWidget{static base({
  required BuildContext context,
  required String? title,
  TextEditingController? controller,
  VoidCallback? voidCallback,
}){
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$title'),
          content: TextField(
            autofocus: true,
            controller: controller,
            decoration: const InputDecoration(
                hintText: "Change Group Name"),

          ),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: const Text('Cancel')
            ),
            TextButton(
                onPressed: voidCallback,
                child: const Text('OK')
            ),
          ],
        );
      });
}
}