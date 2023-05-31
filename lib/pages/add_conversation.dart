// ignore_for_file: use_build_context_synchronously, prefer_final_fields


import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatonline/function/fnc_conversation.dart';

import 'package:chatonline/function/validate.dart';

import 'package:chatonline/widget/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/user_models.dart';
import '../widget/image_path.dart';

class AddConversation extends StatefulWidget {
  const AddConversation({super.key});

  @override
  State<AddConversation> createState() => _AddConversationState();
}

class _AddConversationState extends State<AddConversation> {
  
  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _collectionReference = _firestore.collection('users');
  
  List<String> userListID = List.empty(growable: true);
  List<UserModel> tempList = List.empty(growable: true);
  List<String> tempListID = List.empty(growable: true);
  String searchString = '';
  List<UserModel> userList = List.empty(growable: true);
  final TextEditingController nameController = TextEditingController();
  String? isNameValidation;

  Icon actionIcon = const Icon(Icons.search);
  Widget appBarTitle = const Text('Create Group');
  final TextEditingController _searchUserController = TextEditingController();
  

  @override
  void initState() {
    getAllUser();
    super.initState();
  }

  createConversation() async{
    Uuid uuid = const Uuid();
    Map<String, dynamic>? currentUser = await getUserData(uid);
    tempListID.add(uid);
    Map<String, dynamic> map = {
       'cid': uuid.v4(),
      'adminID': uid,
      'conName': nameController.text,
      'image': '',
      'isHide': false,
      'lastMes': '',
      'lastTime': Timestamp.now(),
      'members': tempListID,
    };
    await FirebaseFirestore.instance.collection('groups').doc(map['cid']).set(map);
    // nextScreen(context, const GroupsDetailPage());
    Navigator.pop(context);
  }
  Future<void> getAllUser() async {
     Stream<QuerySnapshot<Map<String, dynamic>>> query =
        _firestore.collection('users').where('userID',
        isNotEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots();
    
     query.listen((event) async {
      if(!mounted) return;
      userListID.clear();
      userList.clear();
      for (var element in event.docs) {
        userListID.add(element.id);
        // Map<String, dynamic>? user = await getUserData(element.id);
        // userList.add(UserModel.fromJson(user!));
      }
      userList.addAll(event.docs.map((e) {return UserModel.fromJson(e.data());}));
      setState(() {
      
      });
      
    });
    
  }
  searchConversation(){
    if(this.actionIcon.icon==Icons.search){
      this.actionIcon = const Icon(Icons.close);
      this.appBarTitle = TextField(
        controller: _searchUserController,
        style: new TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
          // border: OutlineInputBorder(),
          hintText: "Search...",
          hintStyle: TextStyle(color: Colors.white),
          contentPadding: EdgeInsets.fromLTRB(4, 14, 4, 0),
        ),
        onChanged: (text) {
          setState(() {
            searchString = text;
          });
        },
      );

    }
    else{
      handleSearchEnd();
    }
  }
  handleSearchEnd(){
    setState(() {
      this.appBarTitle = const Text("Create Group");
      this.actionIcon = const Icon(Icons.search);
      searchString = '';
      _searchUserController.clear();
    });
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
              setState(() {
                searchConversation();
              });
            },
            icon: actionIcon,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10.0),
              height: 50,
              child: TextFieldWidget.base(
                edgeInsetsGeometry: EdgeInsets.symmetric(horizontal: 10),
              controller: nameController,
              errorText: isNameValidation,
              onChanged: (String value) {},
              hintText: "Name Group",
            ),
            ),
            
            memberListWidget(size),
            userListWidget(),
            tempList.length>1  ? ElevatedButton(onPressed: () {
              setState(() {
                isNameValidation = validateName(nameController.text);
              });
              if(isNameValidation == null){
                createConversation();
              }              
            }, child: const Text('Create', style: TextStyle(color: Colors.white, fontSize: 18),)) : Container(),
          ],
        ),
      ),
    );
  }
  memberListWidget(Size size){
    return Container(
      child: tempList.isNotEmpty ? Container(
        width: size.width,
        height: 48,
        margin: const EdgeInsets.all(16.0),
        child: ListView.builder(
            physics:
            const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: tempList.length,
            itemBuilder: (context, index){
          return Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: ClipOval(
              child: tempList.elementAt(index).image!.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: tempList.elementAt(index).image!,
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
          );
        }),
      ) : Container(),
    );
  }
  userListWidget() {
    return SizedBox(
      height: MediaQuery.of(context).size.height*0.6,
      child: ListView.builder(
          physics:
          const BouncingScrollPhysics(), //not allow to top scroll
          shrinkWrap: true, //popup
          itemCount: userList.length,
          itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom:
                        BorderSide(color: Colors.grey.shade200))),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: ClipOval(
                    child: userList.elementAt(index).image!.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: userList.elementAt(index).image!,
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
                  title: Text(userList.elementAt(index).fullName!),
                  trailing: Container(
                  width: 36,
                  height: 36.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36), color: tempList.contains(userList.elementAt(index)) ? Colors.red.shade400 : Colors.blue.shade400),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 22.0,
                    onPressed: () {
                      setState(() {
                        if(tempList.contains(userList.elementAt(index))){
                          tempList.remove(userList.elementAt(index));
                          tempListID.remove(userListID.elementAt(index));
                        }
                        else{
                          tempList.add(userList.elementAt(index));
                          tempListID.add(userListID.elementAt(index));
                        }
                      });
                    },
                    icon: tempList.contains(userList.elementAt(index)) ?  const Icon(
                      Icons.remove,
                      size: 18.0,
                    ) : const Icon(
                      Icons.add,
                      size: 18.0,
                    ),
                    color: Colors.white,
                  ),
                )
                ),
              );
            }
          ),
    );
  }
}