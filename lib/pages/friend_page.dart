import 'package:chatonline/pages/friend_list_page.dart';
import 'package:chatonline/pages/friend_request.dart';
import 'package:chatonline/widget/navigator_widget.dart';
import 'package:flutter/material.dart';

import 'add_friend.dart';

class FriendPage extends StatelessWidget {
  const FriendPage({Key? key}) : super(key: key);
  TabBar get _tabBar => TabBar(
    unselectedLabelColor: Colors.grey, 
    labelColor: Colors.blue,  
    tabs: [
        Tab(        
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.people),
                SizedBox(width: 5),
                Text("Friend List")
              ]),
        ),
        Tab(         
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.person_add),
                SizedBox(width: 5),
                Text("Friend Request")
              ]),
        ),
      ]);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Friends',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                nextScreen(context, AddFriend());
              },
              icon: const Icon(Icons.add),
            )
          ],
          bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: Material(color: Colors.white,
            child: _tabBar,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            FriendList(),
            FriendRequest(),
          ],
        ),
      ),
    );
  }
}
