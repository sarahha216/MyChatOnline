import 'package:chatonline/models/menu_item.dart';
import 'package:chatonline/models/menu_items.dart';
import 'package:chatonline/pages/dialog_image.dart';
import 'package:chatonline/service/auth_service.dart';
import 'package:chatonline/widget/widgets.dart';
import 'package:flutter/material.dart';


PopupMenuItem<MenuItem> buildItem(MenuItem item) =>
    PopupMenuItem<MenuItem>(
        value: item,
        child: Text(item.text)
    );
void onSelected (BuildContext buildContext, MenuItem item, TextEditingController controller, String cid){
  switch (item){
    case MenuItems.itemGroupAvatar :
      Navigator.of(buildContext).push(MaterialPageRoute(builder: (context)=> DialogImage(cid: cid)));
      break;
    case MenuItems.itemGroupName:
      DialogChangeInfoWidget.base(
        context: buildContext,
        title: "Change Name",
        voidCallback: () => changeName(controller, cid, buildContext),
        controller: controller,
      );
      break;
    case MenuItems.itemRemoveGroup :
      DialogYesNoWidget.base(
          context: buildContext,
          title: 'Remove this group',
          content: 'Are you sure to remove?',
          voidCallback: () {
            // removeConversation(conInfo['cid']);
            // int counter = 3;
            // Navigator.of(context)
            //     .popUntil((route) => counter-- <= 0);
          });
      break;
  }
}
void changeName(TextEditingController controller, String cid, BuildContext context){
  if(controller.text == null || controller.text.isEmpty) return;

  Map<String, dynamic> map = {
    'conName': controller.text,
  };
  AuthService.firestore.collection('groups').doc(cid).update(map);
  Navigator.of(context).pop();
}