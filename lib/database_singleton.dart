import 'package:chatgpt/api_calls.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  //static variable to hold the instance of class
  static LocalDatabase? _mydatabase;
  static late Database _mydatabaseAddress;

  //creating a private constructor
  LocalDatabase._internal() {
    //_openMyDatabase();
  }

  static initialize() async {
    if (_mydatabase == null) {
      //we are calling empty constructor to make an instance
      _mydatabase = LocalDatabase._internal();
      _mydatabaseAddress = await _openMyDatabase();
    }
    return _mydatabase!;
  }

  //getter (this is to access it globally)
  static LocalDatabase get mydatabase => _mydatabase!;

  //making function of database
  static Future<Database> _openMyDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_database.db');
    final database =
        await openDatabase(path, version: 1, onCreate: (db, version) async {
      //creating table
      return db.execute(
          'CREATE TABLE conversation(id INTEGER, role TEXT, response TEXT)');
    });
    return database;
  }

  //insert data function
  Future<void> insertData(Conversation conv) async {
    await _mydatabaseAddress.insert('conversation', conv.toMap());
  }

  //retrieve list of data of table
  Future<List<Conversation>> retrieveData() async {
    final List<Map<String, Object?>> dataMaps =
        await _mydatabaseAddress.query('conversation');
    return dataMaps.map<Conversation>((e) => Conversation.fromJson(e)).toList();
  }

  //retrieve history data
  Future<List<Conversation>> retrieveHistoryData(int a) async {
    final List<Map<String, Object?>> dataMaps = await _mydatabaseAddress
        .query('conversation', where: 'id = ?', whereArgs: [a]);
    return dataMaps.map<Conversation>((e) => Conversation.fromJson(e)).toList();
  }
}
