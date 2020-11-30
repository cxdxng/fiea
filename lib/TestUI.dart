import 'package:fiea/BackgroundTasks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

class TTS extends StatefulWidget {
  @override
  _TTSState createState() => _TTSState();
}

class _TTSState extends State<TTS> {

  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HELLO WORLD"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          FloatingActionButton(
            onPressed:(){_insert();},
            child: Text("INSERT"),
          ),
          FloatingActionButton(
            onPressed:(){_query();},
            child: Text("GET DATA"),
          ),
          FloatingActionButton(
            onPressed:(){},
            child: Text("Delete DATA"),
          ),
          FloatingActionButton(
            onPressed:(){Background().speakOut("Juden Tach ming freund");},
            child: Text("SPEAK"),
          ),
        ],
      ),
    );
  }
  void _insert() async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName : 'Test',
      DatabaseHelper.columnBirth  : 2003
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach((row) => print(row));
  }

}


