import 'dart:io';

import 'package:chatonline/models/file_model.dart';
import 'package:chatonline/models/message_models.dart';
import 'package:chatonline/models/models.dart';
import 'package:chatonline/service/auth_service.dart';
import 'package:chatonline/widget/navigator_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
late CollectionReference _collectionReference = _firestore.collection('groups');

Reference _firebaseStorage = FirebaseStorage.instance.ref().child('groups');

Future<Map<String, dynamic>?> getGroupData(String cid) async{
  Map<String, dynamic>? groupData;
  await FirebaseFirestore.instance.collection('groups')
      .doc(cid).get().then((value) async{
    groupData = value.data();
  });
  return groupData;
}

Stream<QuerySnapshot<Map<String, dynamic>>> getAllDataUser(var userIds) {
  return _firestore
      .collection('users')
      .where('userID', whereIn: userIds.isEmpty ? ['']
          : userIds)
      .snapshots();
}

sendText(String mesDes, String uid, String cid){
  //create auto token
  Uuid uuid = const Uuid();
  String mesID = uuid.v4();
  MessageModel messageModel = MessageModel(mesID: mesID, mesDes: mesDes, senderID: uid, time: Timestamp.now(), isRemove: false, type: 'text');

  updateLastMessage_Text(cid, mesID, messageModel);
}

updateLastMessage_Text(String cid, String mesID, MessageModel messageModel){
  _collectionReference.doc(cid).collection('messages').doc(mesID).set(messageModel.toJson()).then((value) {
    _collectionReference.doc(cid).update({
      'lastTime': messageModel.time,
      'lastMes': messageModel.mesDes,
    });
  });
}

sendImages(List<XFile> images, cid, uid) async{
  String imageURL='';
  String imageID = '';
  //create auto token
  Uuid uuid = const Uuid();
  String mesID='';
  for(int i=0; i<images.length;i++){
    mesID = uuid.v4();
    imageID = uuid.v4();
    await _firebaseStorage.child(cid).child(imageID).putFile(File(images[i].path));
    imageURL = await _firebaseStorage.child(cid).child(imageID).getDownloadURL();

    MessageModel messageModel = MessageModel(mesID: mesID, mesDes: imageURL, senderID: uid, time: Timestamp.now(), isRemove: false, type: 'image');

    updateLastMessage_Image(cid, mesID, messageModel);
  }

}
updateLastMessage_Image(String cid, String mesID, MessageModel messageModel){
  _collectionReference.doc(cid).collection('messages').doc(mesID).set(messageModel.toJson()).then((value) {
    _collectionReference.doc(cid).update({
      'lastTime': messageModel.time,
      'lastMes': 'Image',
    });
  });
}

sendFiles(List<File> files, String cid, String uid) async{
  String fileURL= '';
  String fileID = '';
  String mesID = '';
  //create auto token
  Uuid uuid = const Uuid();
  for(int i=0; i<files.length;i++){
    mesID = uuid.v4();
    fileID = uuid.v4();

    int dotIndex = files[i].path.lastIndexOf(".");
    String extension = files[i].path.substring(dotIndex, files[i].path.length);

    await _firebaseStorage.child(cid).child(fileID+extension).putFile(File(files[i].path));
    fileURL = await _firebaseStorage.child(cid).child(fileID+extension).getDownloadURL();

    int slashIndex = files[i].path.lastIndexOf("/");
    String name = files[i].path.substring(slashIndex + 1, dotIndex);

    FileModel fileModel =
    FileModel(id: fileID, url: fileURL, name: name, extension: extension);
    Map<String, dynamic> fileMap = fileModel.toJson();
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(cid)
        .collection('files')
        .doc(fileMap['id'])
        .set(fileMap);
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(cid)
        .collection('files')
        .doc(fileMap['id'])
        .set(fileMap);

    MessageModel messageModel = MessageModel(mesID: mesID, mesDes: fileID, senderID: uid, time: Timestamp.now(), isRemove: false, type: 'file');

    updateLastMessage_File(cid, mesID, messageModel);
  }
}

updateLastMessage_File(String cid, String mesID, MessageModel messageModel){
  _collectionReference.doc(cid).collection('messages').doc(mesID).set(messageModel.toJson()).then((value) {
    _collectionReference.doc(cid).update({
      'lastTime': messageModel.time,
      'lastMes': 'File',
    });
  });
}

addMember(String cid, String userID){
  _collectionReference.doc(cid).update({
    'members': FieldValue.arrayUnion([userID]),
  });
}
removeMember(String cid, String userID){
  _collectionReference.doc(cid).update({
    'members': FieldValue.arrayRemove([userID]),
  });
}

updateAdminID(String cid, String newAdminID) async{
  Map<String, dynamic> map = {
    'adminID': newAdminID,
  };
  await AuthService.firestore.collection('groups').doc(cid).update(map);
}

updateIsHide(String cid) async{
  Map<String, dynamic> map = {
    'isHide': true,
  };
  await AuthService.firestore.collection('groups').doc(cid).update(map);
}

removeMessage(String cid, String mesID) async{
  Map<String, dynamic> map = {
    'isRemove': true,
  };
  await AuthService.firestore.collection('groups')
      .doc(cid)
      .collection('messages')
      .doc(mesID).update(map);
}

Future<bool> checkPermission() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  if (androidInfo.version.sdkInt <= 33){
    final status = await Permission.storage.status;
    if (status == PermissionStatus.granted){
      return true;
    }
    if (status != PermissionStatus.granted) {
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
  }
  return true;
}

Future prepareDownload(var file, context) async {
  bool permissionReady = await checkPermission();
  if (permissionReady) {
    try{
      downloadFile(file);
      showSnackBar(context, Colors.green, "Download is successful");
    }catch (e){
      showSnackBar(context, Colors.red, e.toString());
    }
  }
  else{
    showSnackBar(context, Colors.red, "Please enable storage!");
  }
}

Future<void> downloadFile(var file) async {
  final url = file.url;
  final tempDir = await getExternalStorageDirectory();
  final path = '${tempDir!.path}/${file.name}'+'${file.extension}';
  await Dio().download(
      url,
      path
  );
}