import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/function/fnc_group.dart';
import 'package:chatonline/models/file_model.dart';
import 'package:chatonline/models/message_models.dart';
import 'package:chatonline/models/models.dart';
import 'package:chatonline/pages/group_info_page.dart';
import 'package:chatonline/service/auth_service.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:chatonline/widget/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';

class GroupsDetailPage extends StatefulWidget {
  final String cid;
  const GroupsDetailPage({super.key, required this.cid});

  @override
  State<GroupsDetailPage> createState() => _GroupsDetailPageState();
}

class _GroupsDetailPageState extends State<GroupsDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker imgPicker = ImagePicker();
  List<XFile> imageFiles = [];
  late List<XFile> imageList = [];

  late List<File> files = [];
  late List<File> fileList = [];
  late List<String> iconfileList = [];
  late List<String> memberIDList= List.empty(growable: true);
  late List<UserModel> memberList= List.empty(growable: true);
  String uid = FirebaseAuth.instance.currentUser!.uid;

  List<MessageModel> listMessage = List.empty(growable: true);
  String conName = "";
  String conImage = "";

  @override
  void initState() {
    getMessage();
    super.initState();
  }

  void getMessage() {
    Stream<DocumentSnapshot<Map<String, dynamic>>> queryInfo = AuthService.firestore
        .collection('groups')
        .doc(widget.cid).snapshots();
    queryInfo.listen((event) {
      if (!mounted) return;
      memberIDList.clear();
      memberList.clear();
      conImage = event.data()!['image'];
      conName = event.data()!['conName'];

      for(var i in event.data()!['members']){
        memberIDList.add(i);
      }
      Stream<QuerySnapshot<Map<String, dynamic>>> queryMember = getAllDataUser(memberIDList);
      queryMember.listen((event) {
        if (!mounted) return;
        memberList.clear();
        memberList.addAll(event.docs.map((e) {return UserModel.fromJson(e.data());}));

        setState(() {

        });
      });
      setState(() {

      });
    });
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshot = AuthService.firestore
        .collection('groups')
        .doc(widget.cid)
        .collection('messages')
        .orderBy('time')
        .snapshots();
    querySnapshot.listen((event) async {
      if (!mounted) return;
      listMessage.clear();
      listMessage.addAll(event.docs.map((e) {
        return MessageModel.fromJson(e.data());
      }).toList());
      QuerySnapshot<Map<String, dynamic>> querySnapshotFiles = await AuthService.firestore
          .collection('groups')
          .doc(widget.cid)
          .collection('files')
          .get();
      for (var element in listMessage) {        
        if (element.type == "file") {
          element.file = FileModel.fromJson(querySnapshotFiles.docs
              .firstWhere((e) => element.mesDes == e.id)
              .data());         
        }
      }    
       
      setState(() {});
    });
  }

  Future<void> sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      print('send text');
      sendText(_messageController.text, uid, widget.cid);
      _messageController.clear();
    }
    if (imageFiles.isNotEmpty) {
      try {
        print('send image');
        imageList.clear();
        imageFiles.forEach((element) {
          imageList.add(element);
        });
        setState(() {
          imageFiles.clear();
        });
        sendImages(imageList, widget.cid, uid);
      } catch (e) {
        print("error while sending file.");
      }
    }
    if (files.isNotEmpty) {
      try {
        print('send files');
        fileList.clear();
        files.forEach((element) {
          fileList.add(element);
        });

        setState(() {
          files.clear();
        });

        sendFiles(fileList, widget.cid, uid);
      } catch (e) {
        print("error while sending file.");
      }
    }
  }

  _pickMultipleFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx', 'xls', 'mp4'],
      );
      if (result != null) {
        files.addAll(result.paths.map((path) => File(path!)).toList());
        result.files.forEach((element) {
          int dotIndex = element.path!.lastIndexOf(".");
          String extension =
              element.path!.substring(dotIndex, element.path!.length);
          print(extension);
          iconfileList.add(extension);
        });
        setState(() {});
      } else {
        print("No file is selected.");
      }
    } catch (e) {
      print("error while picking file.");
    }
  }

  openImages() async {
    try {
      var pickedFiles = await imgPicker.pickMultiImage();
      if (pickedFiles != null) {
        imageFiles.addAll(pickedFiles);
        setState(() {});
      } else {
        print("No image is selected.");
      }
    } catch (e) {
      print("error while picking file.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        title: Row(
          children: [
            ClipOval(
                child: conImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: conImage,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        ImagePath.group,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      )),
            const SizedBox(
              width: 8,
            ),
            Text(
              conName,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          Container(
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GroupInfoPage(
                          cid: widget.cid,
                        )));
              },
              splashRadius: 18,
              icon: const Icon(
                Icons.info,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: 8, right: 8),
              reverse: true,
              physics: const BouncingScrollPhysics(),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listMessage.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return messageContent(size, listMessage.elementAt(index));
                },
              ),
            ),
          ),
          Container(
            width: size.width,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageFiles.isNotEmpty) ...[
                  Container(
                    width: size.width,
                    height: 60,
                    margin: EdgeInsets.only(top: 4, right: 4),
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageFiles.length,
                        itemBuilder: (context, index) {
                          var image = imageFiles.elementAt(index);
                          return Stack(
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: Image.file(File(image.path)),
                              ),
                              Positioned(
                                  top: -5,
                                  right: 0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(36),
                                        color: Colors.white),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      onPressed: () {
                                        imageFiles.remove(
                                            imageFiles.elementAt(index));
                                        print("remove: ${imageFiles.length} ");
                                        setState(() {});
                                      },
                                      icon: Icon(Icons.close,
                                          size: 20, color: Colors.blue),
                                    ),
                                  )),
                            ],
                          );
                        }),
                  )
                ] else if (files.isNotEmpty) ...[
                  Container(
                    width: size.width,
                    height: 60,
                    margin: EdgeInsets.only(top: 4, right: 4),
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          var file = files.elementAt(index);
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blue)),
                                margin: EdgeInsets.only(right: 4),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: FileIcon(
                                    iconfileList.elementAt(index).toString(),
                                    size: 50,
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: -5,
                                  right: 0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(36),
                                        color: Colors.white),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      onPressed: () {
                                        files.remove(files.elementAt(index));
                                        iconfileList.remove(
                                            iconfileList.elementAt(index));
                                        setState(() {});
                                      },
                                      icon: Icon(Icons.close,
                                          size: 20, color: Colors.blue),
                                    ),
                                  )),
                            ],
                          );
                        }),
                  )
                ] else ...[
                  Container(),
                ],
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _pickMultipleFiles(),
                        child: const Icon(
                          Icons.file_present_outlined,
                          color: Colors.grey,
                          size: 29,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          openImages();
                        },
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(8),
                            hintText: "Enter message",
                            border: InputBorder.none,
                          ),
                        ),
                      )),
                      GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: const Icon(
                          Icons.send,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget messageContent(Size size, MessageModel message) {
    bool flag = message.senderID == FirebaseAuth.instance.currentUser!.uid;
    String avatar = "";
    for(var e in memberList){
      if(e.userID == message.senderID){
        avatar = e.image!;
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onLongPress: () {
          if (flag) {
            DialogYesNoWidget.base(
                context: context,
                title: 'Remove this message',
                content: 'Are you sure to remove?',
                voidCallback: () {
                  removeMessage(widget.cid, message.mesID);
                  Navigator.pop(context);
                });
          }
        },
        child: Row(
          mainAxisAlignment:
              !flag ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            !flag
                ? ClipOval(
                    child: avatar.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: avatar,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            ImagePath.avatar,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ))
                : const Text(''),
            const SizedBox(
              width: 8,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: size.width * 0.7),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                  color: flag ? Colors.blue : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(15)),
              child: (message.type == "text" && message.isRemove==false)
                  ? Text(
                      message.mesDes,
                      style: TextStyle(
                          fontSize: 18,
                          color: !flag ? Colors.black : Colors.white),
                    )
                  : (message.type == "image" && message.isRemove==false)
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          imageUrl: message.mesDes,
                          maxWidthDiskCache: 250,
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image, size: 70),
                        ),
                      )
                      : (message.file != null && message.isRemove==false)
                          ? Container(
                              color: Colors.white,
                              margin: const EdgeInsets.only(right: 4),
                              width: 200,
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FileIcon(
                                    message.file!.extension,
                                    size: 32,
                                  ),
                                  SizedBox(
                                      width: 100,
                                      child: Text(
                                        message.file!.name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      )),
                                  IconButton(onPressed: () {
                                    prepareDownload(message.file, context);
                                  }, icon: Icon(Icons.file_download)),
                                ],
                              ),
                            )
                      : (message.isRemove==true) ? Text(
                        "Unsent message",
                        style: TextStyle(
                            fontSize: 18,
                            color: !flag ? Colors.black : Colors.white),
                      ) : null,
            ),
          ],
        ),
      ),
    );
  }
}
