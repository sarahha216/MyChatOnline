import 'dart:convert';

import 'package:http/http.dart' as http;
class SendNotification{

  static void sendPushMessage(String token, String title, String body) async{
    try{
      await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type':'application/json',
            'Authorization': 'key=API_KEY'
          },
          body:  jsonEncode(
              <String, dynamic>{
                'priority': 'high',
                'data': <String, dynamic>{
                  'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                  'status': 'done',
                  'body': body,
                  'title': title,
                },

                'notification': <String, dynamic>{
                  'body': body,
                  'title': title,
                  'android_channel_id': 'chat_online',
                },
                'to': token,
              }
          )
      );
    }catch (e){
      print("error push notification");
    }
  }
}