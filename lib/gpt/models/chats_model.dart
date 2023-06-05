class ChatModel{
  int? id;
  String? msg;
  String? sender;

  ChatModel({this.id, this.msg, this.sender});

  ChatModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    msg = json['msg'];
    sender = json['sender'];
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'msg': msg,
      'sender': sender,
    };
  }
}