import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:fiea/DatabaseViewer.dart';
import 'package:fiea/main.dart';
import 'package:fiea/personInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'DatabaseHelper.dart';


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
  String nA = "Nicht vorhanden";
  String errorText = "Fehler, bitte versuche es erneut";

  bool isTTSfinished = true;


  Map<String, dynamic> row;

  
  


  // Process result from STT and run the correct function for the command
  Future<bool> handleResults(String msg, BuildContext context)async {
    if(msg.contains("info Kennung")){

      try{
        var split = splitResult(msg);
        var singleData = await querySingleData(int.parse(split[2]));

        if(singleData != null){
          speakOut("Daten von Kennung ${split[2]}\nBitteschön");
          Navigator.push(context, MaterialPageRoute(builder: (context) => PersonCard(entries:singleData)));
        }
        return true;
      }catch(e){
        speakOut(errorText);
      }

    }else if(msg.contains("Gesicht hinzufügen")){

      var split = splitResult(msg);
      String result = await generateFaceData();

      if(result != ""){
        dbHelper.addFace(result, int.parse(split[3]));
        speakOut("Gesichtsdaten erfolgreich hinzugefügt");
      }else{
        speakOut(errorText);
      }
      return true;

    }else if(msg == "Datenbank anzeigen"){

      var cardInfo = await queryAllData();
      if(cardInfo != null){
        speakOut("Bitteschön");
        Navigator.push(context, MaterialPageRoute(builder: (context) => DbViewer(entries: cardInfo)));
      }else{
        speakOut("Keine Daten vorhanden");
      }
      return true;
    }else if(msg == "Datenbank löschen"){

      bool success = dbHelper.deleteTable() as bool;
      if(success){
        speakOut("Datenbank erfolgreich gelöscht\nNeue Daten bank wurde automatisch erstellt");
      }else{
        speakOut(errorText);
      }
      return true;
    }
    return false;
  }

  
  // Insert a new Entry into the Database
  void insert(String name, int year) async {    
    // row to insert
    row = {
      DatabaseHelper.columnName : name,
      DatabaseHelper.columnBirth : year,
      DatabaseHelper.columnIQ : nA,
      DatabaseHelper.columnWeight : nA,
      DatabaseHelper.columnHeight : nA,
      DatabaseHelper.columnPhonenumber : nA,
      DatabaseHelper.columnAddress : nA,
      DatabaseHelper.columnFacedata: nA,
    };
    final id = await dbHelper.insert(row);
    print(row);
    speakOut('Erfolgreich eingetragen\n Neue Kennung: $id');
  }

  Future<int> update(int id, String toUpdate, String value)async{
    switch(toUpdate){
      case "IQ":{
        row = {
          DatabaseHelper.columnId: id,
          DatabaseHelper.columnIQ: int.parse(value),
        };
        return await dbHelper.update(row);
      }
      break;
      case "Gewicht": {
        row = {
          DatabaseHelper.columnId: id,
          DatabaseHelper.columnWeight: "$value kg",
        };
        return await dbHelper.update(row);
      }
      break;
      case "Größe": {
        row = {
          DatabaseHelper.columnId: id,
          DatabaseHelper.columnHeight: "$value cm"
        };
        return await dbHelper.update(row);        
      }
      break;
      case "Nummer": {
        row = {
          DatabaseHelper.columnId: id,
          DatabaseHelper.columnPhonenumber: value
        };
        return await dbHelper.update(row);
      }
      break;
      case "Adresse": {
        row = {
          DatabaseHelper.columnId: id,
          DatabaseHelper.columnAddress : value
        };
        return await dbHelper.update(row);
      }
    }
    return 0;
  }

  void manualUpdate(List<String> data)async{
    row = {
      DatabaseHelper.columnName: data[0],
      DatabaseHelper.columnBirth: data[1],
      DatabaseHelper.columnIQ: data[2],
      DatabaseHelper.columnHeight: data[3],
      DatabaseHelper.columnWeight: data[4],
      DatabaseHelper.columnPhonenumber: data[5],
      DatabaseHelper.columnAddress: data[6],
      DatabaseHelper.columnId: data[7],
      DatabaseHelper.columnFacedata: data[8],
    };
    print(row);
    int success = await dbHelper.update(row);
    if(success == 1){
      speakOut("Änderungen erfolgreich übernommen");
    }

  }

  // Get all Data from the Database
  Future<List<Map<String, dynamic>>> queryAllData() async {
    var allRows = await dbHelper.queryAllRows();

    if(allRows.isNotEmpty){
      return allRows;
    }
    
    return null;
    
  }

  // Get single entry from Database 
  Future<List<Map<String, dynamic>>> querySingleData(int id) async{
    var singleRow = await dbHelper.queryOneRow(id);
    if(singleRow.isNotEmpty){
      return singleRow;
    }
    return null;
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
  Future<String> generateFaceData() async{

    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(imageFile != null) {
      base64string = await encodeBase64(imageFile);
      print(base64string);
      return base64string;
    }

    return "";
    
  }

  void callID(String msg)async{
    try{
      var split = splitResult(msg); 
      List<Map<String, dynamic>> result = await querySingleData(int.parse(split[1]));
      var data = result[0];
      // Converting number to int because if it is
      // not set then it will automaticly go to cath block
      int tempNumber = int.parse(data["number"]);
      launch("tel://$tempNumber");
    }catch(e){
      speakOut("Keine Nummer gefunden");
    }
  }

  

  // Speak out the msg using TTS
  Future speakOut(String msg)async{
    await tts.setLanguage("de-DE");
    await tts.awaitSpeakCompletion(true);
    await tts.speak(msg);
    print("Spoke");
    SpeechScreen.isFinished = true;
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
  
  Uint8List decodeBase64(String encoded){
    var decoded = Uint8List.fromList(base64Decode(encoded));
    
    return decoded;
  }
}

/* https://trello.com/b/oECiBL2s/fiea */