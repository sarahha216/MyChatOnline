import 'package:chatonline/gpt/models/chats_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DBHelper{
  Database? _database;

  String _dbName = "ChatDB1.db";
  int _version = 1;

  Future<Database?> get database async{
    if(_database!=null){
      return _database;
    }
    _database = await getInstance();
  }
  Future<Database> getInstance() async {
    String path = join(await getDatabasesPath(), _dbName);
    return _database = await openDatabase(
        path,
        version: _version,
        onCreate: createDatabase);
  }

  createDatabase(Database db, int version) async{
    await db.execute("CREATE TABLE chat(id INTEGER PRIMARY KEY AUTOINCREMENT,"
        " msg TEXT NOT NULL, sender TEXT NOT NULL)");
  }
  Future<ChatModel> insertChat(ChatModel chatModel) async {
    var dbChat = await database;
    await dbChat!.insert('chat', chatModel.toJson());
    return chatModel;
  }

  Future<List<ChatModel>> getChatList() async{
    await database;
    final List<Map<String, Object?>> QueryResult =
      await _database!.rawQuery("SELECT * FROM chat");
    return QueryResult.map((e) => ChatModel.fromJson(e)).toList();
  }

}