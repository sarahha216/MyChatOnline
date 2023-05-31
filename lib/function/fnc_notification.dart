import 'package:chatonline/pages/navigation_page.dart';
import 'package:chatonline/widget/navigator_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus ==
      AuthorizationStatus.provisional) {
    print('User provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

void saveToken(String token) async{
  await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
    'token': token,
  });
}

initInfo(context){
  var androidInit = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initSetting = InitializationSettings(android: androidInit);
  //flutterLocalNotificationsPlugin.initialize(initSetting);
  flutterLocalNotificationsPlugin.initialize(initSetting,
    onDidReceiveNotificationResponse: (payload) {
      try{
        if(payload!=null){
          nextScreenRemove(context, NavigationPage());
        }
      }
      catch(e){
      }
    });

  FirebaseMessaging.onMessage.listen((RemoteMessage message)  async{
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      message.notification!.body.toString(), htmlFormatBigText: true,
      contentTitle: message.notification!.title.toString(), htmlFormatContentTitle: true,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'chat_online', 'chat_online', importance: Importance.high,
        styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails,);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title.toString(),
      message.notification!.body.toString(),
      notificationDetails,
      payload: message.data['body'],
    );
  });
}

