import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/pages/add_conversation.dart';
import 'package:chatonline/pages/group_detail_page.dart';
import 'package:chatonline/service/auth_service.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:chatonline/widget/navigator_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupPage extends StatefulWidget {
  final String searchGroup;
  const GroupPage({Key? key, required this.searchGroup}) : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  List<Map<String, dynamic>> groupList = List.empty(growable: true);

  @override
  void initState() {
    getGroups();
    super.initState();
  }

  void getGroups() async{
    Stream<QuerySnapshot> querySnapshot = await AuthService.firestore
        .collection('groups').orderBy('lastTime', descending: true)
        .snapshots();

    var data;
    querySnapshot.listen((event) {
      if (!mounted) return;
      groupList.clear();
      for (DocumentSnapshot item in event.docs) {
        data = item.data();
        for(int i=0; i<data['members'].length; i++){
          if(data['members'][i] == uid ){
            groupList.add(data);
          }
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: groupListWidget(),
        ),
        Container(
          margin: EdgeInsets.only(right: 20, bottom: 20),
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: (){
              nextScreen(context, AddConversation());
            },
            elevation: 0,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
  groupListWidget(){
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: groupList.length,
      itemBuilder: (context, index) {
        DateTime time = groupList.elementAt(index)['lastTime'].toDate();
        String t = time.toString().substring(11,16);
        if(groupList.elementAt(index)['conName'].toLowerCase().contains(widget.searchGroup.toLowerCase())
            || widget.searchGroup.isEmpty){
          return Container(
            decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: ClipOval(
                child: groupList.elementAt(index)['image'].isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: groupList.elementAt(index)['image'],
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  ImagePath.group,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                groupList.elementAt(index)['conName'],
                style: const TextStyle(fontSize: 16),
              ),
              subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    groupList.elementAt(index)['lastMes'].isNotEmpty ?
                    Text(groupList.elementAt(index)['lastMes'], overflow: TextOverflow.ellipsis,) : Text('Null'),
                    Text(t, overflow: TextOverflow.ellipsis,)
                  ]),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> GroupsDetailPage(cid: groupList.elementAt(index)['cid'])));
              },

              onLongPress: (){
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    title: const Text('Delete conversation'),
                    content: const Text('Are you sure to delete this conversation?'),
                    actions: [
                      TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel')
                      ),
                      TextButton(
                          onPressed: (){
                            // removeConversation(conversationModel.cid);
                            // Navigator.pop(context);
                            // showSnackBar(context, Colors.green, "Delete is successful");
                          },
                          child: const Text('Yes')
                      ),
                    ],
                  );
                });
              },
            ),
          );
        }
        else{
          return Container();
        }
      },
    );
  }
}
