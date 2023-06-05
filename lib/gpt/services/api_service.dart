import 'dart:convert';
import 'dart:io';

import 'package:chatonline/gpt/models/chats_model.dart';
import 'package:chatonline/gpt/services/api_consts.dart';
import 'package:http/http.dart' as http;
class ApiService{
  static Future<void> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {'Authorization': 'Bearer $API_KEY'},
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      print("jsonResponse $jsonResponse");
    } catch (error) {
      print("error $error");
    }
  }
  //gpt-3.5-turbo
  static Future<ChatModel> sendMessageGPT(
      {required String message}) async {
    try {
      var response = await http.post(
        Uri.parse("$BASE_URL/chat/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": MODEL_GPT,
            "messages": [
              {
                "role": "user",
                "content": message,
              }
            ]
          },
        ),
      );

      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }
      ChatModel chatList;
        chatList =  ChatModel(
            msg: jsonResponse["choices"][0]["message"]["content"],
            sender: "bot",
          );


      return chatList;
    } catch (error) {
      print("error $error");
      rethrow;
    }
  }
  //text-davinci-003
  static Future<ChatModel> sendMessage({required String message}) async{
    try{
      var response = await http.post(
        Uri.parse("$BASE_URL/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": MODEL_ID,
            "prompt": message,
            "max_tokens": 100,
            "temperature": 0
          },
        ),
      );
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }
      ChatModel chatList;
        chatList = ChatModel(
            msg: jsonResponse["choices"][0]["text"],
            sender: "bot",
          );

      return chatList;
    }
    catch (error){
      print("error $error");
      rethrow;
    }
  }
}