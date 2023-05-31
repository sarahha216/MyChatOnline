import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/function/fnc_group.dart';
import 'package:chatonline/models/models.dart';
import 'package:chatonline/pages/add_member.dart';
import 'package:chatonline/pages/pages.dart';
import 'package:chatonline/service/auth_service.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MemberList extends StatefulWidget {
  final String cid;
  const MemberList({Key? key, required this.cid}) : super(key: key);

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    List<UserModel> memberList=List.empty(growable: true);
    List<String> memberIDList=List.empty(growable: true);
    List<String> noAdminList=List.empty(growable: true);

    String? adminID;
    bool isAdmin = false;

    @override
    void initState() {
      getMembers();
      super.initState();
    }

    void getMembers(){
      Stream<DocumentSnapshot<Map<String, dynamic>>> querySnapshotMembers =
      AuthService.firestore.collection('groups').doc(widget.cid).snapshots();
      querySnapshotMembers.listen((event) async {
        if(!mounted) return;
        memberIDList.clear();
        noAdminList.clear();

        adminID = event.data()!['adminID'];

        if(adminID == uid) isAdmin = true;

        for(var i in event.data()!['members']){
          memberIDList.add(i);
          noAdminList.add(i);
        }
        Stream<QuerySnapshot<Map<String, dynamic>>> queryMember = getAllDataUser(memberIDList);
        queryMember.listen((event) {
          if (!mounted) return;
          memberList.clear();
          memberList.addAll(event.docs.map((e) {return UserModel.fromJson(e.data());}));

          setState(() {

          });
        });
      });


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context)=>AddMember(cid: widget.cid,)));
          }, icon: Icon(Icons.add),
            splashRadius: 18,
          ),
        ],
      ),
      body: memberListWidget(),
    );
  }
  memberListWidget() {
    noAdminList.removeWhere((element) => element == uid);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 8, right: 8),
          child: SingleChildScrollView(
            reverse: true,
            physics: const BouncingScrollPhysics(),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: memberList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return memberItem(memberList.elementAt(index));
              },
            ),
          ),
        ),
      ],
    );
  }
  memberItem(UserModel member) {
      print(noAdminList);
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
            child: member.image!.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: member.image!,
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
          title: Text(member.fullName!),

          trailing: isAdmin ? Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(36),color:Colors.red.shade400),
            child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 22.0,
              onPressed: () {
                //có member >= 2
                if(memberIDList.length>1){
                  //xóa member đã chọn
                  removeMember(widget.cid, member.userID!);
                  //nếu xóa trúng mình && mình là Admin
                  if(uid==member.userID){
                    updateAdminID(widget.cid, noAdminList.first);
                    popUntil(context);
                  }
                }
                //có member = 1
                if(memberIDList.length==1){
                  removeMember(widget.cid, member.userID!);
                  updateIsHide(widget.cid);
                  popUntil(context);
                }
              },
              icon: const Icon(Icons.remove,size:  18.0,),color: Colors.white,),
          ) : null,
        ),
      );
  }
}
