import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  // Create necessary Variables

  static final _databaseName = "Humans.db";
  static final _databaseVersion = 1;

  static final table = 'humanData';

  static final columnId = '_id';
  static final columnName = 'name';
  static final columnBirth = 'birth';
  static final columnFacedata = "facedata";
  static final columnIQ = "iq";
  static final columnWeight = "weight";
  static final columnHeight = "height";
  static final columnPhonenumber = "number";
  static final columnAddress = "address";
  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnBirth TEXT NOT NULL,
            $columnFacedata TEXT,
            $columnIQ TEXT NOT NULL,
            $columnWeight TEXT NOT NULL,
            $columnHeight TEXT NOT NULL,
            $columnPhonenumber TEXT NOT NULL,
            $columnAddress TEXT
          )
          ''');
  }

  // Helper methods

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }



  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT * FROM $table");
  }

  Future<List<Map<String, dynamic>>> queryOneRow(int id) async{
    Database db = await instance.database;
    var data = db.rawQuery("SELECT * FROM $table WHERE $columnId='$id'");
    return data;
  }


  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    try{
      int id = int.parse(row[columnId]);
      print(id);
      return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);

    }catch(FormatException){
      print("ERROR");
    }
    return null;
  }

  Future<String> addFace(String facedata, int id)async{
    Database db = await instance.database;
    await db.execute("UPDATE $table SET $columnFacedata ='$facedata' WHERE $columnId='$id'");
    return "Success";
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  void deleteTable() async{

    Database db = await instance.database;
    await db.execute("DROP TABLE IF EXISTS $table");
    print("Dropped table successfully");
    await _onCreate(db, _databaseVersion);
    print("Created new Table: $table");

  }
}