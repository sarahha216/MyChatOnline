import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/function/validate.dart';
import 'package:chatonline/models/user_models.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:chatonline/widget/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ChangeInfoPage extends StatefulWidget {
  const ChangeInfoPage({ Key? key }) : super(key: key);

  @override
  State<ChangeInfoPage> createState() => _ChangeInfoPageState();
}

class _ChangeInfoPageState extends State<ChangeInfoPage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? isNameValidation;

  File? image;

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
  String? imageURL;

  Future saveInfo(String imageURL) async{
    if(image !=null){
      await FirebaseStorage.instance.ref().child('users').child(FirebaseAuth.instance.currentUser!.uid).child(image.toString()).putFile(image!);

      imageURL = await FirebaseStorage.instance.ref().child('users').child(FirebaseAuth.instance.currentUser!.uid).child(image.toString()).getDownloadURL();
    }

    Map<String, dynamic> map = {
      'fullName': nameController.text,
      'image': imageURL,
    };

    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Update information'),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  isNameValidation = validateName(nameController.text);
                });
                if(isNameValidation ==  null){
                  await saveInfo(imageURL.toString());
                  Navigator.pop(context);
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18),)
            ),
          ],
        ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid).get(),

          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if(snapshot.hasData){
              UserModel userModel = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);

              nameController.text = userModel.fullName!;
              emailController.text = userModel.email!;
              imageURL = userModel.image!;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  Center(
                    child: Stack(
                      children: [
                        ClipOval(
                          child: image != null? Image.file(
                            image!,width: 128,
                            height: 128,
                            fit: BoxFit.cover,):
                          userModel.image!.isNotEmpty? CachedNetworkImage(
                            imageUrl: userModel.image!,
                            width: 128,
                            height: 128,
                            fit: BoxFit.cover,):
                          Image.asset(
                            ImagePath.avatar,
                            width: 128,
                            height: 128,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: -10,
                          right: -15,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              pickImage();
                            },
                            shape: const CircleBorder(),
                            color: Colors.white,
                            child: const Icon(Icons.edit, color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16,),
                  TextFieldWidget.base(
                    onChanged: (text){},
                    controller: nameController,
                    textInputType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.person),
                    errorText: isNameValidation,
                  ),
                  const SizedBox(height: 16,),
                  TextFieldWidget.base(
                    onChanged: (text){},
                    controller: emailController,
                    textInputType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    readOnly: true,
                    prefixIcon: const Icon(Icons.mail),
                    hintText: "Email",
                  ),

                ]),
              );
            }
            else{
              return const Center();
            }
          }
        ),
      ),
    );
  }
}