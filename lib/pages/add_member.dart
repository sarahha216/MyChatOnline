import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/function/fnc_group.dart';
import 'package:chatonline/models/user_models.dart';
import 'package:chatonline/service/auth_service.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMember extends StatefulWidget {
  final String cid;
  const AddMember({Key? key, required this.cid}) : super(key: key);

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {

  List<String> userIDList=List.empty(growable: true);
  List<String> memberIDList=List.empty(growable: true);
  List<String> output = List.empty(growable: true);

  List<UserModel> userList=List.empty(growable: true);

  @override
  void initState() {
    // TODO: implement initState
    getUsers();
    super.initState();
  }

  void getUsers(){
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshotUsers =
      AuthService.firestore.collection('users').snapshots();

    querySnapshotUsers.listen((event) async {
      if(!mounted) return;
      userIDList.clear();

      event.docs.forEach((element) {
        userIDList.add(element.id);
      });
    });


    Stream<DocumentSnapshot<Map<String, dynamic>>> querySnapshotMembers =
      AuthService.firestore.collection('groups').doc(widget.cid).snapshots();

    querySnapshotMembers.listen((event) async {
      if(!mounted) return;
      memberIDList.clear();
      output.clear();
      userList.clear();

      for(int i=0; i<event.data()!['members'].length; i++){
        memberIDList.add(event['members'][i]);
      }

      userIDList.forEach((element) {
        if(!memberIDList.contains(element)){
          output.add(element);
        }
      });

      //userIDList.where((element) => !memberIDList.contains(element));
      Stream<QuerySnapshot<Map<String, dynamic>>> queryOthers = getAllDataUser(output);
      queryOthers.listen((event) {
        if (!mounted) return;
        userList.clear();
        userList.addAll(event.docs.map((e) {return UserModel.fromJson(e.data());}));

        setState(() {

        });
      });
      print(userList.length);
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
        elevation: 0,
        centerTitle: true,
      ),
      body: userListWidget(),
    );
  }
  userListWidget() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 8, right: 8),
          child: SingleChildScrollView(
            reverse: true,
            physics: const BouncingScrollPhysics(),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return userItem(userList.elementAt(index));
              },
            ),
          ),
        ),
      ],
    );
  }
  userItem(UserModel user) {
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
          child: user.image!.isNotEmpty
              ? CachedNetworkImage(
            imageUrl: user.image!,
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
        title: Text(user.fullName!),
        trailing: Container(
          width: 70.0,
          height: 36.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36), color: Colors.blue.shade400),
          child: TextButton(
            onPressed: (){
              addMember(widget.cid, user.userID!);
            },
            child: Text("Add",style: TextStyle(color: Colors.white),),
          ),
        ),
      ),
    );
  }
}
