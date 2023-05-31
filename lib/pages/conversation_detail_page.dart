import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/function/fnc_conversation.dart';
import 'package:chatonline/models/file_model.dart';
import 'package:chatonline/models/message_models.dart';
import 'package:chatonline/models/models.dart';
import 'package:chatonline/pages/conversation_info_page.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:chatonline/widget/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ConversationDetailPage extends StatefulWidget {
  final Map<String, dynamic> conInfo;
  const ConversationDetailPage({Key? key, required this.conInfo})
      : super(key: key);

  @override
  State<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker imgPicker = ImagePicker();
  List<XFile> imageFiles = [];
  late List<XFile> imageList = [];

  late List<File> files = [];
  late List<File> fileList = [];
  late List<String> iconfileList = [];

  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MessageModel> listMessage = List.empty(growable: true);
  @override
  void initState() {
    getMessage();
    super.initState();
  }

  void getMessage(){
        Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshot = _firestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(widget.conInfo['cid'])
        .collection('messages')
        .orderBy('time')
        .snapshots();
    querySnapshot.listen((event) async {
      if(!mounted) return;
        listMessage.clear();
        listMessage.addAll(event.docs.map((e) {
          return MessageModel.fromJson(e.data());
        }).toList());
      QuerySnapshot<Map<String, dynamic>> querySnapshotFiles = await _firestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(widget.conInfo['cid'])
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
      sendText(_messageController.text, uid, widget.conInfo['cid']);
      isTrueConversation(uid, widget.conInfo['cid']);
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
        sendImages(imageList, uid, widget.conInfo['cid']);
        isTrueConversation(uid, widget.conInfo['cid']);
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
        sendFiles(fileList, uid, widget.conInfo['cid']);
        isTrueConversation(uid, widget.conInfo['cid']);
      } catch (e) {
        print("error while sending file.");
      }
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
                child: widget.conInfo['image'].isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.conInfo['image'],
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        ImagePath.avatar,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      )),
            const SizedBox(
              width: 8,
            ),
            Text(
              '${widget.conInfo['conName']}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          Container(
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ConversationInfoPage(
                          conInfo: widget.conInfo,
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
                )),
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

  _pickMultipleFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx', 'xls', '.mp4'],
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

  Widget messageContent(Size size, MessageModel message) {
    bool flag = message.senderID == FirebaseAuth.instance.currentUser!.uid;
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
                  removeMessage(message.mesID, uid, widget.conInfo['cid']);
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
                    child: widget.conInfo['image'].isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.conInfo['image'],
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
                      ? Container(
                          child: ClipRRect(
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
                          ),
                        )
                      : (message.file != null && message.isRemove==false)
                          ? Container(
                              color: Colors.white,
                              margin: EdgeInsets.only(right: 4),
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
                                  Icon(Icons.file_download),
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
