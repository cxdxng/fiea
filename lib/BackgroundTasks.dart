import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fiea/main.dart';

import 'DatabaseHelper.dart';
import 'package:flutter_tts/flutter_tts.dart';


class Background{

  final dbHelper = DatabaseHelper.instance;
  FlutterTts tts = FlutterTts();

  Future<String> convertToBase64(File imageFile) async {
    if (imageFile != null) {
      Uint8List bytes = await imageFile.readAsBytes();
      return base64.encode(bytes);
    }
  }

  void handleResults(String msg)async{

    if(msg.contains("info Kennung")){

    }else if(msg.contains("Gesicht hinzufügen")){

    }else if(msg.contains("neuer Eintrag") || msg.contains("Neuer Eintrag")){
      var split = msg.split(" ");
      insert(split[2], int.parse(split[3]));
    }else if(msg.contains("Eintrag löschen")){
      var split = msg.split(" ");
      delete(int.parse(split[3]));
    }else if(msg == "Datenbank anzeigen"){
      print("Ran");
      query();
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
    speakOut('Erfolgreich eingetragen\n neue Kennung: $id');
  }

  void query() async {
    final allRows = await dbHelper.queryAllRows();
    print(allRows);
    if(allRows.isNotEmpty) {
      allRows.forEach((row) {
        var rowAsString = row.toString();
        var formatted = formatString(rowAsString);
        print(formatted.toString());
        speakOut("${formatted[0]}\n${formatted[1]}\n${formatted[2]}");
      });
    }else{
      speakOut("Keine Daten vorhanden");
    }
  }

  void delete(int id) async {
    // Assuming that the number of rows is the id for the last row.
    //final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
    speakOut("Eintrag erfolgreich gelöscht");
  }

  void speakOut(String msg)async{
    await tts.setLanguage("de-DE");
    await tts.speak(msg);
  }

  List<String> formatString(String toEdit) {
    var removeFrontBracket = toEdit.replaceAll("{", "");
    var removeBackBracket = removeFrontBracket.replaceAll("}", "");
    var splitAtComma = removeBackBracket.split(",");

    var tempID = "Kennung: ${splitAtComma[0].replaceAll("_id: ", "").trim()}";
    var tempName = "Name: ${splitAtComma[1].replaceAll("name: ", "").trim()}";
    var tempBirth = "Geboren: ${splitAtComma[2]
        .replaceAll("birth: ", "")
        .trim()}";


    return [tempID, tempName, tempBirth];
  }
}