import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fiea/DatabaseViewer.dart';
import 'package:fiea/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'DatabaseHelper.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:fiea/TestUI.dart';



class Background{


  /*
  +++COMMANDS+++
  - Gesicht hinzufügen
  - neuer Eintrag
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

    return null;
  }

  // Process result from STT and run the correct function for the command
  Future<List<Map<String, dynamic>>> handleResults(String msg)async {
    if(msg.contains("info Kennung")){
      var split = splitResult(msg);
      querySingleData(int.parse(split[2]));
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

      var cardInfo = await queryAllData();
      
      return cardInfo;

    }else if(msg == "Datenbank löschen"){
      dbHelper.deleteTable();
    }
    return null;
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
  Future<List<Map<String, dynamic>>> queryAllData() async {
    var allRows = await dbHelper.queryAllRows();

    if(allRows.isNotEmpty){

      speakOut("Bitteschön");
      return allRows;

    }else{
      speakOut("Keine Daten vorhanden");
      print("Keine Daten vorhanden");
    }
    return null;
  }

  // Get single entry from Database 
  void querySingleData(int id) async{
    var data = await dbHelper.queryOneRow(id);
    print(data[0]);
    var list = data[0].values.toList();
    if(data.isNotEmpty){
      if(list[3] != null && list[3] != ""){
        speakOut("Kennung: ${list[0]}\n Name: ${list[1]}\n Geboren: ${list[2]}\n Gesichtsdaten vorhanden");
      }else{
        speakOut("Kennung: ${list[0]}\n Name: ${list[1]}\n Geboren: ${list[2]}\n Gesichtsdaten nicht vorhanden");
      }
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

  // Add facedata to person in Database
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





/**TODO
 * Implement full database visualisation with Listview instead of TTS
 * Face recogniion on facedata
 * displaying Facedata and converting it from base64
 */