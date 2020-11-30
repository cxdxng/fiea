import 'DatabaseHelper.dart';

class Background{

  final dbHelper = DatabaseHelper.instance;

  void handleResults(String msg)async{

    switch (msg){
      case "datenbank anzeigen":{_query();}
        break;
      case "gesicht hinzufügen":{}
        break;
      case "info":{}
        break;
      case "eintrag löschen":{_delete();}
        break;
      case "neuer eintrag":{_insert("Test", 2000);}
        break;
    }
  }

  void _insert(String name, int year) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName : name,
      DatabaseHelper.columnBirth  : year
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach((row) => print(row));
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
  }

  void speakOut(String msg){

  }

}