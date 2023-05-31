import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/function/fnc_conversation.dart';
import 'package:chatonline/function/fnc_group.dart';
import 'package:chatonline/notification.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class FriendRequest extends StatefulWidget {
  const FriendRequest({Key? key}) : super(key: key);

  @override
  State<FriendRequest> createState() => _FriendRequestState();
}

class _FriendRequestState extends State<FriendRequest> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  List<String> requestListID=List.empty(growable: true);
  List<UserModel> requestList=List.empty(growable: true);

  @override
  void initState() {
    getRequests();
    super.initState();
  }

  void getRequests(){
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshotRequests =
    _firestore.collection('users').doc(uid).collection('requests').snapshots();

    querySnapshotRequests.listen((event) async {
      if(!mounted) return;
      requestListID.clear();

      event.docs.forEach((element) {
        requestListID.add(element.id);
      });

      Stream<QuerySnapshot<Map<String, dynamic>>> queryOthers = getAllDataUser(requestListID);
      queryOthers.listen((event) {
        if (!mounted) return;
        requestList.clear();
        requestList.addAll(event.docs.map((e) {return UserModel.fromJson(e.data());}));

        print(requestList.length);
        setState(() {

        });

      });

    });
  }
  acceptAddFriend(String userID) async{
    //gửi id của mình tới friend list của người khác
    Map<String, dynamic>? myID = {'userID': uid};
    CollectionReference friends = _firestore.collection('users').doc(userID)
            .collection('friends');
    await friends.doc(uid).set(myID);

    //gửi id của người khác tới friend list của mình
    Map<String, dynamic>? friendID = {'userID': userID};
    friends = _firestore.collection('users').doc(uid)
        .collection('friends');
    await friends.doc(userID).set(friendID);

    await removeFriendRequest(userID);

    //thông báo
    Map<String, dynamic>? dataInfo = await getUserData(uid);
    String title = '${dataInfo!['fullName']} accepted add-friend';
    dataInfo = await getUserData(userID);
    SendNotification.sendPushMessage(dataInfo!['token'], title, "");
  }

  removeFriendRequest(String userID) async{
    CollectionReference requests = _firestore.collection('users')
                                    .doc(uid).collection('requests');
    await requests.doc(userID).delete();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: requestList.length,
      itemBuilder: (context, index) {
        UserModel request = requestList.elementAt(index);
        return Container(
          decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: ClipOval(
              child: request.image!.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: request.image!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                ImagePath.avatar,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              request.fullName!,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),

            onTap: () => {
              //nextScreenReplace(context, )
            },
            trailing: SizedBox(
              width: 160.0,
              height: 36.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 70.0,
                    height: 36.0,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(36),color:Colors.blue.shade400),
                    child: TextButton(
                      onPressed: () {
                        acceptAddFriend(request.userID!);
                      },
                      child: Text("Accept", style: TextStyle(color: Colors.white),),),
                  ),
                  Container(
                    width: 70.0,
                    height: 36.0,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(36),color:Colors.grey),
                    child: TextButton(
                      onPressed: () {
                        removeFriendRequest(request.userID!);
                      },
                      child: Text("Delete", style: TextStyle(color: Colors.white),),),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
