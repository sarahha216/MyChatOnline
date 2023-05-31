import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/function/fnc_group.dart';
import 'package:chatonline/function/fnc_menu.dart';
import 'package:chatonline/models/menu_item.dart';
import 'package:chatonline/models/menu_items.dart';
import 'package:chatonline/pages/images_files_list.dart';
import 'package:chatonline/pages/member_list.dart';
import 'package:chatonline/service/auth_service.dart';
import 'package:chatonline/widget/color_setting.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:chatonline/widget/navigator_widget.dart';
import 'package:chatonline/widget/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfoPage extends StatefulWidget {
  final String cid;
  const GroupInfoPage({Key? key, required this.cid}) : super(key: key);

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  late TextEditingController changeNameController;

  List<String> memberIDList=List.empty(growable: true);
  List<String> noAdminList=List.empty(growable: true);

  String name = "";
  String imageURL = "";
  String? adminID;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    changeNameController = TextEditingController();
    refreshData();
  }

  @override
  void dispose() {
    changeNameController.dispose();
    super.dispose();
  }

  void refreshData() {
    Stream<DocumentSnapshot<Map<String, dynamic>>> querySnapshot = AuthService.firestore.collection('groups').doc(widget.cid).snapshots();
    querySnapshot.listen((event) {
      if (!mounted) return;
      memberIDList.clear();
      noAdminList.clear();

      name = event.data()!['conName'];
      imageURL = event.data()!['image'];

      adminID = event.data()!['adminID'];

      if(adminID == uid) isAdmin = true;

      for(var i in event.data()!['members']){
        memberIDList.add(i);
        noAdminList.add(i);
      }

      noAdminList.removeWhere((element) => element == uid);

      setState(() {

      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          PopupMenuButton<MenuItem>(
              onSelected: (item)=> onSelected(context, item, changeNameController, widget.cid),
              itemBuilder: (context)=>[
            ...MenuItems.itemsMenu.map(buildItem).toList(),
          ]),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: imageURL.isNotEmpty? CachedNetworkImage(
                      imageUrl: imageURL,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ):Image.asset(
                      ImagePath.group,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    )
                ),
              ),
              Container(
                  decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1.2))),
                  child: Center(child: Text("$name", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),)),
              ListViewWidget.base(
                  title: 'Members', textStyle: TextStyle(fontSize: 18),
                  colorIcon: BaseColor.black80, icon: Icon(Icons.groups),
                  voidCallback: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> MemberList(cid: widget.cid)));
                  }),
              ListViewWidget.base(
                  title: 'Images', textStyle: TextStyle(fontSize: 18),
                  colorIcon: BaseColor.black80, icon: Icon(Icons.image_outlined),
                  voidCallback: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ImageFilePage(cid: widget.cid)));
                  }),
              ListViewWidget.base(
                  title: 'Leave group',
                  textStyle: TextStyle(fontSize: 18),
                  colorIcon: Colors.red,
                  icon: Icon(Icons.delete),
                  voidCallback: () {
                    DialogYesNoWidget.base(
                        context: context,
                        title: 'Leave this group',
                        content: 'Are you sure to leave this group?',
                        voidCallback: () {
                          //có member >= 2
                          if(memberIDList.length>1){
                            //rời nhóm
                            removeMember(widget.cid, uid);
                            //nếu mình là Admin
                            if(isAdmin==true){
                              updateAdminID(widget.cid, noAdminList.first);
                              popUntil(context);
                            }
                          }
                          //có member = 1
                          if(memberIDList.length==1){
                            removeMember(widget.cid, uid);
                            updateIsHide(widget.cid);
                            popUntil(context);
                          }
                        });
                  }),
            ],
          ),
        ),
      ),
    );
  }

}
