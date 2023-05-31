import 'package:cloud_firestore/cloud_firestore.dart';

import 'file_model.dart';

class MessageModel{
  late String mesID;
  late String mesDes;
  late String senderID;
  late Timestamp time;
  late bool isRemove;
  late String type;
  FileModel? file;
  MessageModel({
    required this.mesID, required this.mesDes, required this.senderID, required this.time, required this.isRemove, required this.type
});

  MessageModel.fromJson(Map<String, dynamic> json){
    mesID = json['mesID'];
    mesDes = json['mesDes'];
    senderID = json['senderID'];
    time = json['time'];
    isRemove = json['isRemove'];
    type = json['type'];
  }

  Map<String, dynamic> toJson(){
    return {
      'mesID': mesID,
      'mesDes': mesDes,
      'senderID': senderID,
      'time': time,
      'isRemove': isRemove,
      'type': type
    };
  }
}