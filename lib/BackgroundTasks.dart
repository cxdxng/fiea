import 'DatabaseHelper.dart';
import 'package:flutter_tts/flutter_tts.dart';


class Background{

  final dbHelper = DatabaseHelper.instance;
  FlutterTts tts = FlutterTts();


  void handleResults(String msg)async{

    switch (msg){
      case "Datenbank anzeigen":{
        query();
      }
      break;
      case "gesicht hinzufügen":{}
      break;
      case "info":{}
      break;
      case "eintrag löschen":{delete();}
      break;
      case "neuer Eintrag":{insert("Test", 2000);}
      break;
    }
  }

  void insert(String name, int year) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName : name,
      DatabaseHelper.columnBirth  : year
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
    speakOut('inserted row id: $id');
  }

  void query() async {
    final allRows = await dbHelper.queryAllRows();
    allRows.forEach((row) {
      var rowAsString = row.toString();
      var formatted = formatString(rowAsString);
      print(formatted.toString());
      speakOut("${formatted[0]}\n${formatted[1]}\n${formatted[2]}");

    });
  }

  void delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
  }

  void speakOut(String msg)async {
    await tts.setLanguage("de-DE");
    await tts.speak(msg);
  }

  List<String> formatString(String toEdit){
    var removeFrontBracket = toEdit.replaceAll("{", "");
    var removeBackBracket = removeFrontBracket.replaceAll("}", "");
    var splitAtComma = removeBackBracket.split(",");

    var tempID = "ID: ${splitAtComma[0].replaceAll("_id: ", "").trim()}";
    var tempName = "Name: ${splitAtComma[1].replaceAll("name: ", "").trim()}";
    var tempBirth = "Geboren: ${splitAtComma[2].replaceAll("birth: ", "").trim()}";


    return [tempID, tempName, tempBirth];
  }

}