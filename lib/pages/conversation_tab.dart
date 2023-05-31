import 'package:chatonline/models/conversation_models.dart';
import 'package:chatonline/pages/conversation_page.dart';
import 'package:chatonline/pages/group_page.dart';
import 'package:chatonline/service/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConversationTab extends StatefulWidget {
  const ConversationTab({Key? key}) : super(key: key);

  @override
  State<ConversationTab> createState() => _ConversationTabState();
}

class _ConversationTabState extends State<ConversationTab> with SingleTickerProviderStateMixin{
  Icon actionIcon = const Icon(Icons.search);
  Widget appBarTitle = const Text('Conversations');

  String uid = FirebaseAuth.instance.currentUser!.uid;
  List<ConversationModel> conList = List.empty(growable: true);
  List<Map<String, dynamic>> groupList = List.empty(growable: true);
  final TextEditingController _searchController = TextEditingController();
  String searchCon='';
  String searchGroup='';
  late TabController _tabController;

  void _handleTabIndex() {
    setState(() {});
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);

    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        setState(() {
          searchCon = "";
          searchGroup = "";
        });
      } else {
        setState(() {
          searchCon = _searchController.text;
          searchGroup = _searchController.text;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  TabBar get _tabBar => TabBar(
      controller: _tabController,
      unselectedLabelColor: Colors.grey,
      labelColor: Colors.blue,
      tabs: [
        Tab(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.people),
                SizedBox(width: 5),
                Text("Conversations")
              ]),
        ),
        Tab(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.groups),
                SizedBox(width: 5),
                Text("Groups")
              ]),
        ),
      ]);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: appBarTitle,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: Material(color: Colors.white,
              child: _tabBar,
            ),
          ),
          actions: [
            IconButton(onPressed: (){
              setState(() {
                searchConversation();
              });
            },
              icon: actionIcon,
            )
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ConversationPage(searchCon: searchCon,),
            GroupPage(searchGroup: searchGroup,),
          ],
        ),
      ),
    );
  }
  searchConversation(){
    if(this.actionIcon.icon==Icons.search){
      this.actionIcon = const Icon(Icons.close);
      this.appBarTitle = TextField(
        controller: _searchController,
        style: new TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
          // border: OutlineInputBorder(),
          hintText: "Search...",
          hintStyle: TextStyle(color: Colors.white),
          contentPadding: EdgeInsets.fromLTRB(4, 14, 4, 0),
        ),
      );

    }
    else{
      handleSearchEnd();
    }
  }
  handleSearchEnd(){
    setState(() {
      this.appBarTitle = const Text("Conversations");
      this.actionIcon = const Icon(Icons.search);
      _searchController.clear();
    });
  }
}

