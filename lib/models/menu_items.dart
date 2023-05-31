import 'package:chatonline/models/menu_item.dart';
import 'package:flutter/material.dart';

class MenuItems {
  static const List<MenuItem> itemsMenu = [
    itemGroupAvatar,
    itemGroupName,
    itemRemoveGroup,
  ];
  static const itemGroupAvatar = MenuItem(
      text: 'Group \'s Image',
  );
  static const itemGroupName = MenuItem(
      text: "Group \'s Name"
  );
  static const itemRemoveGroup = MenuItem(
      text: "Remove Group"
  );
}