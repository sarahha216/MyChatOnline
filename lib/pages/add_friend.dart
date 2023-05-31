import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/function/fnc_group.dart';
import 'package:chatonline/models/models.dart';
import 'package:chatonline/notification.dart';
import 'package:chatonline/pages/pages.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:chatonline/widget/navigator_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../function/fnc_conversation.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({super.key});

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  Icon actionIcon = const Icon(Icons.search);
  Widget appBarTitle = const Text(
    'Add Friends',
  );

  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;


  List<String> userIDList=List.empty(growable: true);
  List<String> friendIDList=List.empty(growable: true);
  List<String> output = List.empty(growable: true);

  List<UserModel> userList=List.empty(growable: true);

  final TextEditingController _searchUserController = TextEditingController();
  String searchString = '';

  @override
  void initState() {
    // TODO: implement initState
    getUsers();
    super.initState();
  }

  void getUsers(){
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshotUsers =
    _firestore.collection('users').where('userID', isNotEqualTo: uid).snapshots();

    //lấy id users
    querySnapshotUsers.listen((event) async {
      if(!mounted) return;
      userIDList.clear();

      event.docs.forEach((element) {
        userIDList.add(element.id);
      });
        userList.clear();
        userList.addAll(event.docs.map((e) {return UserModel.fromJson(e.data());}));
        setState(() {});
    });

  }
  Future<bool> isFriend(String userID) async {
    //kiểm tra collection field
    CollectionReference checkCollection = _firestore
        .collection('users')
        .doc(userID)
        .collection('friends');
    QuerySnapshot snapshot = await checkCollection.get();
    if (snapshot.size == 0) {
      print('dont have collection field');
      return false;
    } else {
      //kiểm tra user có tồn tại trong list friend?
      CollectionReference checkUser = FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('friends');
      DocumentSnapshot<Object?> snapshot1 =
      await checkUser.doc(uid).get();
      if (snapshot1.exists) {
        print('is friend');
        return true;
      } else {
        print('isnt friend');
        return false;
      }
    }
  }

  addFriend(String userID) async {
    var get = await isFriend(userID);
    if (get == false){
      try {
        Map<String, dynamic>? map = {'userID': uid};
        _firestore
            .collection('users')
            .doc(userID).collection('requests').doc(uid).set(map);

        //thông báo
        Map<String, dynamic>? dataInfo = await getUserData(uid);
        String title = '${dataInfo!['fullName']} requested add-friend';
        dataInfo = await getUserData(userID);
        SendNotification.sendPushMessage(dataInfo!['token'], title, "");

        showSnackBar(context, Colors.green, "Send a friend request");
      } on FirebaseAuthException catch (e) {
        showSnackBar(context, Colors.red, e.message.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = const Icon(Icons.close);
                  this.appBarTitle = TextField(
                    controller: _searchUserController,
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
                    onChanged: (text) {
                      setState(() {
                        searchString = text;
                      });
                    },
                  );
                } else {
                  handleSearchEnd();
                }
              });
            },
          )
        ],
      ),
      body: userListWidget(),
    );
  }

  handleSearchEnd() {
    setState(() {
      this.appBarTitle = const Text("Add Friends");
      this.actionIcon = const Icon(Icons.search);
      searchString = '';
      _searchUserController.clear();
    });
  }

  userListWidget() {
    return SingleChildScrollView(
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: userList.length,
          itemBuilder: (context, index) {
            UserModel userModel = userList.elementAt(index);

            if (userModel.fullName!
                .toLowerCase()
                .contains(searchString.toLowerCase())) {
              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom:
                        BorderSide(color: Colors.grey.shade200))),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: ClipOval(
                    child: userModel.image!.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: userModel.image!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      ImagePath.avatar,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(userModel.fullName!),

                  trailing: iconAddFriend(userModel),
                ),
              );
            }
            else{
              return const Center();
            }

          }),
    );
  }

  iconAddFriend(UserModel userModel) {
    return Container(
      width: 36,
      height: 36.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36), color: Colors.blue.shade400),
      child: IconButton(
        padding: EdgeInsets.zero,
        splashRadius: 22.0,
        onPressed: () {
          addFriend(userModel.userID!);
        },
        icon: const Icon(
          Icons.person_add,
          size: 18.0,
        ),
        color: Colors.white,
      ),
    );
  }
}
