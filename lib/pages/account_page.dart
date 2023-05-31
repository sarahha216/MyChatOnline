import 'dart:io';

import 'package:chatonline/models/user_models.dart';
import 'package:chatonline/pages/pages.dart';
import 'package:chatonline/widget/color_setting.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:chatonline/widget/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({ Key? key }) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future signOut() async {
    auth.signOut();
  }
  
  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Account'),
          elevation: 0,
         
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if(snapshot.hasData)
            {
              UserModel userModel = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
            
            return SingleChildScrollView(       
              child: Container(
                color: Colors.white,
                child: Column(                
                  children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1.2))),
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 16),
                          child: ClipOval(
                            child: userModel.image!.isNotEmpty? CachedNetworkImage(
                              imageUrl: userModel.image!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,):
                            Image.asset(
                              ImagePath.avatar,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),),
                          const SizedBox(width: 8,),
                          // ignore: prefer_const_constructors
                          Text(
                            userModel.fullName!,
                            style: const TextStyle(
                            color: BaseColor.black80, fontSize: 18, fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ListViewWidget.base(title: 'Update information', colorIcon: BaseColor.black80, icon: Icon(Icons.info_outline),
                      voidCallback: (){
                        nextScreen(context, ChangeInfoPage());
                      }
                  ),

                  ListViewWidget.base(title: 'Change password', colorIcon: BaseColor.black80, icon: Icon(Icons.key),
                    voidCallback: (){
                      nextScreen(context, ChangePasswordPage());
                    }
                  ),

                  ListViewWidget.base(title: 'Log out', colorIcon:Colors.red, icon: Icon(Icons.lock),
                      voidCallback: () async{
                      await signOut();
                      nextScreenRemove(context, LoginPage());
                  }),

                ]),
              ),
            );
          }
          return const Center(
                child: CircularProgressIndicator(),
              );
          }
        ),
    );
  }
}