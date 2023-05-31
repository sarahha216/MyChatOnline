import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/models/conversation_models.dart';
import 'package:chatonline/pages/conversation_detail_page.dart';
import 'package:chatonline/service/auth_service.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:chatonline/widget/navigator_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../function/fnc_conversation.dart';

class ConversationPage extends StatefulWidget {
  final String searchCon;
  const ConversationPage({ Key? key, required this.searchCon }) : super(key: key);

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;
  List<ConversationModel> conList = List.empty(growable: true);

  @override
  void initState() {
    getConversations();
    super.initState();
  }

  void getConversations(){
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshot = AuthService.firestore
        .collection('users')
        .doc(uid).collection('conversations')
        .orderBy('lastTime', descending: true)
        .snapshots();

    querySnapshot.listen((event) {
      if (!mounted) return;
      conList.clear();
      conList.addAll(event.docs.map((e) {return ConversationModel.fromJson(e.data());}));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: conversationList(),
    );
  }
  conversationList(){
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: conList.length,
      itemBuilder: (context, index) {
        ConversationModel conversationModel = conList.elementAt(index);
        DateTime time = conversationModel.lastTime.toDate();
        String t = time.toString().substring(11,16);
        if((conversationModel.conName.toLowerCase().contains(widget.searchCon.toLowerCase()) && conversationModel.isHide==false)
            || (widget.searchCon.isEmpty && conversationModel.isHide==false)){
          return Container(
            decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: ClipOval(
                child: conversationModel.image!.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: conversationModel.image!,
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
              title: Text(
                conversationModel.conName,
                style: const TextStyle(fontSize: 16),
              ),
              subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    conversationModel.lastMes.isNotEmpty ?
                    Text(conversationModel.lastMes, overflow: TextOverflow.ellipsis,) : Text('Null'),
                    Text(t, overflow: TextOverflow.ellipsis,)
                  ]),
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                Map<String, dynamic>? conData = await getConDataID(conversationModel.cid);
                setState(() {
                  isLoading = false;
                });
                if(isLoading == false){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ConversationDetailPage(conInfo: conData!)));
                }
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
                            removeConversation(conversationModel.cid);
                            Navigator.pop(context);
                            showSnackBar(context, Colors.green, "Delete is successful");
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
