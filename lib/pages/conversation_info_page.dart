import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/function/fnc_conversation.dart';
import 'package:chatonline/widget/color_setting.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:chatonline/widget/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_models.dart';

class ConversationInfoPage extends StatelessWidget {
  final Map<String, dynamic> conInfo;
  const ConversationInfoPage({Key? key, required this.conInfo}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.blue),
        ),
        body: Container(
          color: Colors.white,
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(conInfo['cid'])
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                UserModel userModel = UserModel.fromJson(
                    snapshot.data!.data() as Map<String, dynamic>);
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: userModel.image!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: userModel.image!,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    ImagePath.avatar,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  )),
                      ),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1.2))),
                          child: Center(
                            child: Text(
                              userModel.fullName!,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          )),
                      ListViewWidget.base(
                          title: 'Profile',
                          textStyle: TextStyle(fontSize: 18),
                          colorIcon: BaseColor.black80,
                          icon: Icon(
                            Icons.person,
                            size: 28,
                          ),
                          voidCallback: () {
                            DialogInfoWidget.base(
                              context: context,
                              title: Center(
                                  child: Column(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
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
                                            )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(userModel.fullName!)
                                ],
                              )),
                              content: SizedBox(
                                height: 100,
                                width: MediaQuery.of(context).size.width - 32,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.email,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(userModel.email!)
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(userModel.email!)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ListViewWidget.base(
                          title: 'Remove conversation',
                          textStyle: TextStyle(fontSize: 18),
                          colorIcon: Colors.red,
                          icon: Icon(Icons.delete),
                          voidCallback: () {
                            DialogYesNoWidget.base(
                                context: context,
                                title: 'Remove this conversation',
                                content: 'Are you sure to remove?',
                                voidCallback: () {
                                  removeConversation(conInfo['cid']);
                                  int counter = 3;
                                  Navigator.of(context)
                                      .popUntil((route) => counter-- <= 0);
                                });
                          }),
                    ],
                  ),
                );
              }
              return const Center(
                child: const CircularProgressIndicator(),
              );
            },
          ),
        ));
  }
}
