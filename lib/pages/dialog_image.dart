import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/service/auth_service.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class DialogImage extends StatefulWidget {
  final String cid;
  const DialogImage({Key? key, required this.cid}) : super(key: key);

  @override
  State<DialogImage> createState() => _DialogImageState();
}

class _DialogImageState extends State<DialogImage> {

  File? image;
  String imageURL = "";

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    Stream<DocumentSnapshot<Map<String, dynamic>>> querySnapshot = AuthService.firestore.collection('groups').doc(widget.cid).snapshots();
    querySnapshot.listen((event) {
      if (!mounted) return;
      imageURL = event.data()!['image'];
      setState(() {

      });
    });
  }

  Future pickImage() async{
    try{
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;

      final imageTemporary = File(image.path);
      setState(()=>this.image = imageTemporary);

    } on PlatformException catch(e){
      if (kDebugMode) {
        print('Failed to pick image:  $e');
      }
    }
  }

  Future saveInfo() async{
    if(image !=null){
      await AuthService.storageGroup.child(widget.cid).child(widget.cid).putFile(image!);

      imageURL = await AuthService.storageGroup.child(widget.cid).child(widget.cid).getDownloadURL();
    }

    Map<String, dynamic> map = {
      'image': imageURL,
    };

    await AuthService.firestore.collection('groups').doc(widget.cid).update(map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: AlertDialog(
        title: Text("Change Image", textAlign: TextAlign.center),
        content: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: image != null? Image.file(
                image!,width: 80,
                height: 80,
                fit: BoxFit.cover,):
              imageURL.isNotEmpty? CachedNetworkImage(
                imageUrl: imageURL,
                width: 80,
                height: 80,
                fit: BoxFit.cover,):
              Image.asset(
                ImagePath.group,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: -10,
              right: 50,
              child: MaterialButton(
                elevation: 1,
                onPressed: pickImage,
                shape: const CircleBorder(),
                color: Colors.white,
                child: const Icon(Icons.edit, color: Colors.blue),
              ),
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text('Cancel')
          ),
          TextButton(
              onPressed: (){
                saveInfo();
                Navigator.pop(context);
              },
              child: const Text('OK')
          ),
        ],
      ),
    );
  }
}
