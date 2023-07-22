import 'package:chat_app/data/models/menu_item.dart';
import 'package:flutter/material.dart';

class MenuItems {
  static const List<MenuItem> menuItems = [
    // addFriend,
    createGroup
  ];
  // static const MenuItem addFriend =
  //     MenuItem(icon: Icons.person_add_alt_1, text: "Add friend");
  static const MenuItem createGroup =
      MenuItem(icon: Icons.group_add, text: "Create group");
}
