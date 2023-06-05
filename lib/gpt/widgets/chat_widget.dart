import 'package:chatonline/gpt/widgets/path.dart';
import 'package:chatonline/gpt/widgets/text_widget.dart';

import 'package:flutter/material.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({Key? key, required this.msg, required this.sender}) : super(key: key);

  final String msg;
  final String sender;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: sender == "user" ? ColorPath.color_me : ColorPath.color_gpt,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  sender == "user" ?
                  IMGPath.gpt_user : IMGPath.gpt_chat,
                  height: 30,
                  width: 30,),
                const SizedBox(width: 8,),
                Expanded(
                    child: TextWidget.base(label: msg.trim()),
                ),
                sender == "user"
                    ? const SizedBox.shrink()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.thumb_up_alt_outlined,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.thumb_down_alt_outlined,)
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


