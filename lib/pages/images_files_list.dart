import 'package:chatonline/models/message_models.dart';
import 'package:chatonline/service/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ImageFilePage extends StatefulWidget {
  final String cid;
  const ImageFilePage({Key? key, required this.cid}) : super(key: key);

  @override
  State<ImageFilePage> createState() => _ImageFilePageState();
}

class _ImageFilePageState extends State<ImageFilePage> {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  List<MessageModel> listMessage = List.empty(growable: true);
  List<String> imageList = List.empty(growable: true);

  @override
  void initState() {
    getMessage();
    super.initState();
  }

  void getMessage(){
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshot = AuthService.firestore
        .collection('groups')
        .doc(widget.cid)
        .collection('messages')
        .orderBy('time')
        .snapshots();
    querySnapshot.listen((event) async {
      if(!mounted) return;
      listMessage.clear();
      listMessage.addAll(event.docs.map((e) {
        return MessageModel.fromJson(e.data());
      }).toList());
      for (var element in listMessage) {
        if (element.type == "image") {
          imageList.add(element.mesDes);
        }
      }
      setState(() {

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Images'),
        elevation: 0,
        centerTitle: true,
      ),
      body: photoList(),
    );
  }
  photoList(){
    return GridView.builder(
        itemCount: imageList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index){
          return SizedBox(
            width: 100,
            height: 100,
            child: Image.network(
              imageList.elementAt(index),
              fit: BoxFit.fill,
            ),
          );
        });
  }
}
