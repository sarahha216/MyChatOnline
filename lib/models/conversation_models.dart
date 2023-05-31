import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class ConversationModel {
  late String cid;
  String? adminID;
  late String conName;
  String? image;
  late bool isHide;
  late String lastMes;
  late Timestamp lastTime;
  List<MessageModel>? messages;
  List<String>? members;

  ConversationModel({
    required this.cid,
    this.adminID,
    required this.conName,
    this.image,
    required this.isHide,
    required this.lastMes,
    required this.lastTime,
    this.messages,
    required this.members
    }){
    messages = messages??[];
    members = members??[];
  }

  ConversationModel.fromJson(Map<String, dynamic> json){
    cid = json['cid'];
    adminID = json['adminID'];
    conName = json['conName'];
    image = json['image'];
    isHide = json['isHide'];
    lastMes = json['lastMes'];
    lastTime = json['lastTime'];
    messages = json['messages'];
    members = json['members'];
  }

  Map<String, dynamic> toJson(){
    return {
      'cid': cid,
      'adminID': adminID,
      'conName': conName,
      'image': image,
      'isHide': isHide,
      'lastMes': lastMes,
      'lastTime': lastTime,
      'messages': messages,
      'members': members,
    };
  }


}