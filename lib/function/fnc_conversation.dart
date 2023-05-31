import 'dart:io';

import 'package:chatonline/models/file_model.dart';
import 'package:chatonline/models/message_models.dart';
import 'package:chatonline/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

late CollectionReference _collectionReference = _firestore.collection('users');
FirebaseFirestore _firestore = FirebaseFirestore.instance;
Reference _firebaseStorage = FirebaseStorage.instance.ref().child('conversations');

Future<Map<String, dynamic>?> getUserData(String uid) async{
  Map<String, dynamic>? userData;
  await FirebaseFirestore.instance.collection('users')
      .doc(uid).get().then((value) async{
    userData = value.data();
  });
  return userData;
}

Future<Map<String, dynamic>?> getConDataID(String cid) async{
  Map<String, dynamic>? userData;
  await FirebaseFirestore.instance.collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid).collection('conversations')
      .doc(cid).get().then((value) async{
    userData = value.data();
  });
  return userData;
}

Future<Map<String, dynamic>?> getConData(String myid,String cid) async{
  Map<String, dynamic>? conData;
  await FirebaseFirestore.instance.collection('users')
      .doc(myid).collection('conversations')
      .doc(cid).get().then((value) async{
    conData = value.data();
  });
  return conData;
}

Future removeConversation(String cid) async{
  String uid = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
  Map<String, dynamic> map = {
    'isHide': true,
  };
  await collectionReference.doc(uid)
      .collection('conversations').doc(cid).update(map);
}

isTrueConversation(String uid, String cid) async{
  CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
  Map<String, dynamic> map = {
    'isHide': false,
  };
  //update bên mình
  await collectionReference.doc(uid)
      .collection('conversations').doc(cid).update(map);
  //update bên userID
  await collectionReference.doc(cid)
      .collection('conversations').doc(uid).update(map);
}

removeMessage(String mesID, String uid, String cid) async{
  Map<String, dynamic> map = {
    'isRemove': true,
  };
  await _collectionReference
      .doc(uid)
      .collection('conversations')
      .doc(cid)
      .collection('messages')
      .doc(mesID).update(map);
  await _collectionReference
      .doc(cid)
      .collection('conversations')
      .doc(uid)
      .collection('messages')
      .doc(mesID).update(map);
}

sendText(String mesDes, String uid, String cid) {
  //create auto token
  Uuid uuid = const Uuid();
  String mesID=uuid.v4();
  MessageModel messageModel = MessageModel(mesID: mesID, mesDes: mesDes, senderID: uid, time: Timestamp.now(), isRemove: false, type: 'text');

  updateLastMessage_Text(uid, cid, mesID, messageModel);
  updateLastMessage_Text(cid, uid, mesID, messageModel);
}

updateLastMessage_Text(String uid, String other, String mesID, MessageModel messageModel) {
  _collectionReference
      .doc(uid)
      .collection('conversations')
      .doc(other)
      .collection('messages')
      .doc(mesID)
      .set(messageModel.toJson())
      .then((value) {
    _collectionReference
        .doc(uid)
        .collection('conversations')
        .doc(other)
        .update({
      'lastTime': messageModel.time,
      'lastMes': messageModel.mesDes,
    });
  });
}

sendImages(List<XFile> images, String uid, String cid) async {
  String imageURL = '';
  String imageID = '';
  //create auto token
  Uuid uuid = const Uuid();
  String mesID = '';
  for (int i = 0; i < images.length; i++) {
    mesID = uuid.v4();
    imageID = uuid.v4();
    await _firebaseStorage
        .child(uid)
        .child(cid)
        .child(imageID)
        .putFile(File(images[i].path));
    imageURL = await _firebaseStorage
        .child(uid)
        .child(cid)
        .child(imageID)
        .getDownloadURL();
    MessageModel messageModel = MessageModel(mesID: mesID, mesDes: imageURL, senderID: uid, time: Timestamp.now(), isRemove: false, type: 'image');

    updateLastMessage_Image(mesID, uid, cid, messageModel);
    updateLastMessage_Image(mesID, cid, uid, messageModel);
  }
}

updateLastMessage_Image(String mesID ,String uid, String other, MessageModel messageModel) {
  _collectionReference
      .doc(uid)
      .collection('conversations')
      .doc(other)
      .collection('messages')
      .doc(mesID)
      .set(messageModel.toJson())
      .then((value) {
    _collectionReference
        .doc(uid)
        .collection('conversations')
        .doc(other)
        .update({
      'lastTime': messageModel.time,
      'lastMes': 'Image',
    });
  });
}

sendFiles(List<File> files, String uid, String cid) async {
  String fileURL = '';
  String fileID = '';
  //create auto token
  Uuid uuid = const Uuid();
  for (int i = 0; i < files.length; i++) {
    String mesID = '';
    mesID = uuid.v4();
    fileID = uuid.v4();

    int dotIndex = files[i].path.lastIndexOf(".");
    String extension = files[i].path.substring(dotIndex, files[i].path.length);

    await _firebaseStorage
        .child(uid)
        .child(cid)
        .child(fileID+extension)
        .putFile(File(files[i].path));

    fileURL = await _firebaseStorage
        .child(uid)
        .child(cid)
        .child(fileID+extension)
        .getDownloadURL();

    int slashIndex = files[i].path.lastIndexOf("/");
    String name = files[i].path.substring(slashIndex + 1, dotIndex);
    print(name);
    print(extension);
    FileModel fileModel =
    FileModel(id: fileID, url: fileURL, name: name, extension: extension);
    Map<String, dynamic> fileMap = fileModel.toJson();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(cid)
        .collection('files')
        .doc(fileMap['id'])
        .set(fileMap);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cid)
        .collection('conversations')
        .doc(uid)
        .collection('files')
        .doc(fileMap['id'])
        .set(fileMap);
    MessageModel messageModel = MessageModel(mesID: mesID, mesDes: fileID, senderID: uid, time: Timestamp.now(), isRemove: false, type: 'file');

    updateLastMessage_File(mesID, uid, cid, messageModel);
    updateLastMessage_File(mesID, cid, uid, messageModel);
  }
}

updateLastMessage_File(String mesID, String uid, String other, MessageModel messageModel) {
  _collectionReference
      .doc(uid)
      .collection('conversations')
      .doc(other)
      .collection('messages')
      .doc(mesID)
      .set(messageModel.toJson())
      .then((value) {
    _collectionReference
        .doc(uid)
        .collection('conversations')
        .doc(other)
        .update({
      'lastTime': messageModel.time,
      'lastMes': 'File',
    });
  });
}