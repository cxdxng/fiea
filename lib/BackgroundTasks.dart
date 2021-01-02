import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fiea/DatabaseViewer.dart';
import 'package:fiea/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'DatabaseHelper.dart';


//import 'package:flutter_tts/flutter_tts.dart';

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



  // Process result from STT and run the correct function for the command
  Future<List<Map<String, dynamic>>> handleResults(String msg)async {
    if(msg.contains("info Kennung")){
      var split = splitResult(msg);
      try{
        var singleData = await querySingleData(int.parse(split[2]));
        return singleData;
      }catch(FormatException){
        print("Could not parse Int");
        return null;
      }
    }else if(msg.contains("Gesicht hinzufügen")){
      var split = splitResult(msg);
      addFaceData(int.parse(split[3]));
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
    speakOut('Erfolgreich eingetragen\n Neue Kennung: $id');
  }

  void update(int id, String toUpdate, String value)async{
    switch(toUpdate){
      case "IQ":{
        Map<String, dynamic> row = {
          DatabaseHelper.columnId: id,
          DatabaseHelper.columnIQ: int.parse(value),
        };
        final rowsAffected = await dbHelper.update(row);
        if (rowsAffected == 1 ) {
          speakOut("Eintrag erfolgreich aktualisiert");
        }else{
          speakOut("Fehler, bitte versuche es erneut");
        }
      }
      break;
      case "Gewicht": {
        Map<String, dynamic> row = {
          DatabaseHelper.columnId: id,
          DatabaseHelper.columnWeight: int.parse(value),
        };
        final rowsAffected = await dbHelper.update(row);
        print(rowsAffected);
      }
      break;
      case "Größe": {
        Map<String, dynamic> row = {
          DatabaseHelper.columnId: id,
          DatabaseHelper.columnHeight: int.parse(value)
        };
        final rowsAffected = await dbHelper.update(row);
        print(rowsAffected);
      }
    }
    
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
    
    tts.setStartHandler(() {
      SpeechScreen.isFinishedWithTalking = false;
    });

    tts.setCompletionHandler(() {
      SpeechScreen.isFinishedWithTalking = true;
    });

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