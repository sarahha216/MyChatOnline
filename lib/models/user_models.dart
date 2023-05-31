import 'models.dart';

class UserModel {
  String? userID;
  String? fullName;
  String? email;
  String? image;
  String? token;
  List<String>? friends;
  List<String>? requests;
  List<ConversationModel>? conversations;

  UserModel(
      {required this.userID,
      required this.fullName,
      required this.email,
      this.image,
      this.token,
      this.requests,
      this.friends,
      this.conversations}) {
    image = image ?? "";
    token = token ?? "";
    requests = requests??[];
    friends = friends??[];
    conversations = conversations??[];
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    fullName = json['fullName'];
    email = json['email'];
    image = json['image']??'';
    token = json['token']??'';
    requests = json['requests']??[];
    friends = json['friends']??[];
    conversations = json['conversations']??[];
  }

  Map<String, dynamic> toJson(){
    return {
      'userID': userID,
      'fullName':fullName,
      'email': email,
      'image': image,
      'token': token,
      'requests': requests,
      'friends': friends,
      'conversations': conversations,
    };
  }
}