import 'package:chatonline/gpt/models/chats_model.dart';
import 'package:chatonline/gpt/models/db_helper.dart';
import 'package:chatonline/gpt/services/api_service.dart';
import 'package:chatonline/gpt/widgets/chat_widget.dart';
import 'package:chatonline/gpt/widgets/notification_widget.dart';
import 'package:chatonline/gpt/widgets/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late DBHelper dbHelper;
  List<ChatModel>? dataList;


  bool _isTyping = false;
  ScrollController _listScrollController = ScrollController();

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    dbHelper = DBHelper();
    loadData();
    super.initState();
  }
  loadData() async{
    dataList = await dbHelper.getChatList();
  }

  Future<void> _sendMessage() async{
    if(textEditingController.text.isEmpty){
      showSnackBar(context, Colors.red, "Please type a message");
      return;
    }
    try{
    ChatModel chatModel = ChatModel(msg: textEditingController.text, sender: "user");
    setState(() {
      _isTyping = true;
      dbHelper.insertChat(ChatModel(
      msg: chatModel.msg,
      sender: chatModel.sender,
      ));
    });

    textEditingController.clear();

    //ChatModel temp = await ApiService.sendMessage(message: chatModel.msg!);
    ChatModel temp = await ApiService.sendMessageGPT(message: chatModel.msg!);
    setState(() {
      dbHelper.insertChat(ChatModel(msg: temp.msg , sender: temp.sender));
      scrollListToEND();
      _isTyping = false;
    });
    }
    catch (error){
      print("error $error");
      showSnackBar(context, Colors.red, error.toString());
    }

  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 1,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(IMGPath.openaiLogo),
        ),
        title: const Text("ChatGPT",),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: FutureBuilder(
                future: dbHelper.getChatList(),
                builder: (context, AsyncSnapshot<List<ChatModel>> snapshot){
                  if(!snapshot.hasData||snapshot.data==null){
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else if(snapshot.data!.length==0) {
                    return Center(
                      child: Text(''),
                    );
                  }
                  else{
                    return ListView.builder(
                      controller: _listScrollController,
                      itemCount: snapshot.data!.length,
                        itemBuilder: (context, index){
                        return ChatWidget(
                            msg: snapshot.data![index].msg.toString(),
                            sender: snapshot.data![index].sender.toString());
                    });
                  }
                },
              ),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.blue,
                size: 16,
              ),
            ],
            const SizedBox(
              height: 12,
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.black),
                      controller: textEditingController,
                      onSubmitted: (value) {
                        _sendMessage();
                        print('saved');
                      },
                      decoration: const InputDecoration.collapsed(
                          hintText: "How can I help you",),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        _sendMessage();
                        print('saved');
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.blue,
                        size: 36,
                      )),
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }
}
