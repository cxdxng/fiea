import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fiea/main.dart';
import 'package:image_picker/image_picker.dart';
import 'DatabaseHelper.dart';
import 'package:flutter_tts/flutter_tts.dart';


class Background{

  /*
  +++COMMANDS+++
  - Gesicht hinzufügen
  - neuer eintrag
  - Eintrag löschen
  - Datenbank anzeigen
  */

  // Create necessary Variables
  final dbHelper = DatabaseHelper.instance;
  FlutterTts tts = FlutterTts();
  String base64string;


  Future<String> convertToBase64(File imageFile) async {
    if (imageFile != null) {
      Uint8List bytes = await imageFile.readAsBytes();
      return base64.encode(bytes);
    }
  }

  // Process result from STT and run the correct function for the command
  bool handleResults(String msg){
    if(msg.contains("info Kennung")){
      var split = splitResult(msg);
      queryEntry(int.parse(split[2]));
      return true;
    }else if(msg.contains("Gesicht hinzufügen")){
      var split = splitResult(msg);
      addFaceData(int.parse(split[3]));
    }else if(msg.contains("neuer Eintrag") || msg.contains("Neuer Eintrag")){

      var split = splitResult(msg);
      insert(split[2], int.parse(split[3]));

    }else if(msg.contains("Eintrag löschen")){
      
      var split = splitResult(msg);
      delete(int.parse(split[3]));

    }else if(msg == "Datenbank anzeigen"){
      queryFullData();
    }

  return false;
  }

  
  // Insert a new Entry into the Database
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

  // Get all Data from the Database
  void queryFullData() async {
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
      print("Keine Daten vorhanden");
    }
  }

  void queryEntry(int id) async{
    var data = await dbHelper.queryOneRow(id);
    print(data[0]);
    var list = data[0].values.toList();
    if(list[3] != null && list[3] != ""){
      
      speakOut("Kennung: ${list[0]}\n Name: ${list[1]}\n Geboren: ${list[2]}\n Gesichtsdaten vorhanden");
    }else{
      speakOut("Kennung: ${list[0]}\n Name: ${list[1]}\n Geboren: ${list[2]}\n Gesichtsdaten nicht vorhanden");
    }
  }

  // Delete an Entry from the Database
  void delete(int id) async {
    // Assuming that the number of rows is the id for the last row.
    //final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
    speakOut("Eintrag erfolgreich gelöscht");
  }

  void addFaceData(int id) async{

    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(imageFile != null) {
      base64string = await encodeBase64(imageFile);
      print(base64string);

      if(base64string != null || base64string != ""){
        var success = dbHelper.addFace(base64string, id);
        print(success);
        speakOut("Gesichtsdaten erfolgreich hinzugefügt");
      }else{
        print("Base64 data empty");
      }
    }
    
  }

  // Speak out the msg using TTS
  void speakOut(String msg)async{
    await tts.setLanguage("de-DE");
    await tts.speak(msg);
  }

  // +++Data formatting+++

  List<String> formatString(String toEdit) {
    var removeFrontBracket = toEdit.replaceAll("{", "");
    var removeBackBracket = removeFrontBracket.replaceAll("}", "");
    var splitAtComma = removeBackBracket.split(",");

    var tempID = "Kennung: ${splitAtComma[0].replaceAll("_id: ", "").trim()}";
    var tempName = "Name: ${splitAtComma[1].replaceAll("name: ", "").trim()}";
    var tempBirth = "Geboren: ${splitAtComma[2].replaceAll("birth: ", "").trim()}";
    var tempFacedata = splitAtComma[3].replaceAll("facedata: ", "").trim();

    return [tempID, tempName, tempBirth, tempFacedata];
  }

  // Split a String at it's spaces so it can
  // be processed later on in the code and treated
  // as a List of Strings for the different pieces of Data
  List<String> splitResult(String toSplit){
    return toSplit.split(" ");
  }


  Future<String> encodeBase64(File imageFile) async{
    Uint8List bytes = await imageFile.readAsBytes();
    var encoded = base64.encode(bytes);
    return encoded;
  }
}