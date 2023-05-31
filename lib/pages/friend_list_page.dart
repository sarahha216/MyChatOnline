import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/function/fnc_conversation.dart';
import 'package:chatonline/function/fnc_group.dart';
import 'package:chatonline/models/user_models.dart';
import 'package:chatonline/pages/conversation_detail_page.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendList extends StatefulWidget {
  const FriendList({Key? key}) : super(key: key);

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  List<String> friendListID=List.empty(growable: true);
  List<UserModel> friendList=List.empty(growable: true);
  bool _isLoading = false;

  @override
  void initState() {
    getFriends();
    super.initState();
  }

  void getFriends(){
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshotRequests =
    _firestore.collection('users').doc(uid).collection('friends').snapshots();

    querySnapshotRequests.listen((event) async {
      if(!mounted) return;
      friendListID.clear();

      event.docs.forEach((element) {
        friendListID.add(element.id);
      });

      Stream<QuerySnapshot<Map<String, dynamic>>> queryOthers = getAllDataUser(friendListID);
      queryOthers.listen((event) {
        if (!mounted) return;
        friendList.clear();
        friendList.addAll(event.docs.map((e) {return UserModel.fromJson(e.data());}));

        print(friendList.length);
        setState(() {

        });

      });

    });
  }

  Future removeFriend(String userID)async{
    CollectionReference friend =  _firestore.collection('users').doc(uid).collection('friends');
    await  friend.doc(userID).delete();

    friend =  _firestore.collection('users').doc(userID).collection('friends');
    await  friend.doc(uid).delete();
  }

  Future createNewConversation(String userID) async{
    Map<String, dynamic>? myData  = await getUserData(uid);
    Map<String, dynamic>? friendData  = await getUserData(userID);
    Map<String, dynamic>? conversation = {
      'cid': userID,
      'adminID': '',
      'conName' : friendData!['fullName'],
      'image': friendData['image'],
      'lastTime': Timestamp.now(),
      'lastMes': '',
      'isHide': false,
    };

    await  _firestore.collection('users').doc(uid)
        .collection('conversations').doc(userID).set(conversation);


    conversation['conName'] = myData!['fullName'];
    conversation['cid'] = myData['userID'];
    conversation['image'] = myData['image'];

    await  _firestore.collection('users').doc(userID)
        .collection('conversations').doc(uid).set(conversation);
  }

  Future goToConversation(String userID, BuildContext context)async{
    setState(() {
      _isLoading = true;
    });
    await _firestore.collection('users').doc(uid)
        .collection('conversations').doc(userID).get().then((value) async{
      if(!value.exists){
        await createNewConversation(userID);
      }
    });

    Map<String, dynamic>? conData = await getConDataID(userID);
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ConversationDetailPage(conInfo: conData!)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: friendList.length,
      itemBuilder: (context, index) {

        UserModel friends = friendList.elementAt(index);

        return Container(
          decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: ClipOval(
              child: friends.image!.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: friends.image!,
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
              friends.fullName!,
              style: const TextStyle(fontSize: 16),
            ),

            onTap: () => {
              //nextScreenReplace(context, )
            },
            trailing: SizedBox(
              width: 90.0,
              height: 36.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(36),color:Colors.blue.shade400),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 22.0,
                      onPressed: () {
                        if(_isLoading==true){
                          Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        else {
                          goToConversation(friends.userID!, context);
                        }
                      },
                      icon: const Icon(Icons.message,size:  18.0,),color: Colors.white,),
                  ),
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(36),color:Colors.red.shade400),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 22.0,
                      onPressed: () {
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            title: const Text('Unfriend'),
                            content: const Text('Are you sure to unfriend?'),
                            actions: [
                              TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel')
                              ),
                              TextButton(
                                  onPressed: (){
                                    removeFriend(friends.userID!);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Yes')
                              ),
                            ],
                          );
                        });
                      },
                      icon: const Icon(Icons.person_remove,size:  18.0,),color: Colors.white,),
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
