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

import 'package:http/http.dart'as http;
import 'package:http/http.dart';

class Background {

  // Test DB Password: {*=R0\CiNh<#+w*(


  /*
  +++COMMANDS+++
  - Gesicht hinzufügen
  - neuer Eintrag
  - Eintrag löschen
  - info kennung ...
  - Datenbank löschen
  - Eintrag updaten
  - ... suchen
  - Zeig mir was du kannst
  - Wie viel Uhr ist es
  - Datenbank anzeigen
  */

  // Create necessary Objects
  final dbHelper = DatabaseHelper.instance;
  FlutterTts tts = FlutterTts();

  // Create necessary variables
  String base64string;
  String nA = "Nicht vorhanden";
  String errorText = "Fehler, bitte versuche es erneut";
  bool isTTSfinished = true;
  Map<String, dynamic> row;

  // Get all data from MySQL database and save them in a local sqlite
  // database so that the database is up to date and available at all times

  void getDataFromMySQL()async{
    Response response = await http.get(Uri.https("esktcorona.000webhostapp.com", "/getAllData.php"));
    Map data = response.body as Map<dynamic, String> ;
  }

  void insertInLocalDatabase(){
    
  }

  // Process result from STT and run the correct function for the command
  Future<bool> handleNormalResult(String msg, BuildContext context) async {
    // Split the msg at spaces
    List<String> split = splitResult(msg);
    // Check msg and run corresponding method
    if (msg.contains("info Kennung")) {
      try {
        // Pass msg to method
        List<Map<String, dynamic>> singleData =
            await querySingleData(int.parse(split[2]));
        // Check for success
        if (singleData != null) {
          speakOut("Daten von Kennung ${split[2]}\nBitteschön");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PersonCard(entries: singleData)));
        }
        return true;
      } catch (e) {
        speakOut(errorText);
      }
    } else if (msg.contains("Gesicht hinzufügen")) {
      // Get Facedata from Imagepicker
      String result = await generateFaceData();

      // Check for success
      if (result != "") {
        // Pass msg to method
        dbHelper.addFace(result, int.parse(split[3]));
        speakOut("Gesichtsdaten erfolgreich hinzugefügt");
      } else {
        speakOut(errorText);
      }
      return true;
    } else if (msg == "Datenbank anzeigen") {
      // Get data from Database
      List<Map<String, dynamic>> cardInfo = await queryAllData();

      // Check for success
      if (cardInfo != null) {
        speakOut("Bitteschön");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DbViewer(entries: cardInfo)));
      } else {
        speakOut("Keine Daten vorhanden");
      }
      return true;
    } else if (msg == "Datenbank löschen") {
      // Delete the current table from Database
      bool success = dbHelper.deleteTable() as bool;
      // Check for success
      if (success) {
        speakOut(
            "Datenbank erfolgreich gelöscht\nNeue Daten bank wurde automatisch erstellt");
      } else {
        speakOut(errorText);
      }
      return true;
    } else if (msg.contains(" suchen")) {
      try {
        List<Map<String, dynamic>> cardInfo = await queryByName(split[0]);
        if (cardInfo != null) {
          speakOut("Alle Ergebnisse für: ${split[0]}");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DbViewer(entries: cardInfo)));
        }
      } catch (e) {
        speakOut(errorText);
      }
    }
    // If non of the methods above fired, return false to go on with
    // passing the msg to the Chatbot
    return false;
  }

  // Insert a new entry into the Table
  void insert(String name, int year) async {
    // Creating a map for easier access
    row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnBirth: year,
      DatabaseHelper.columnIQ: nA,
      DatabaseHelper.columnWeight: nA,
      DatabaseHelper.columnHeight: nA,
      DatabaseHelper.columnPhonenumber: nA,
      DatabaseHelper.columnAddress: nA,
      DatabaseHelper.columnFacedata: nA,
    };
    final id = await dbHelper.insert(row);
    // Let user know which id the new entry has
    speakOut('Erfolgreich eingetragen\n Neue Kennung: $id');
  }

  // Update one parameter of an ID with Speech input
  Future<int> update(int id, String toUpdate, String value) async {
    // Check for the column that needs to be updated
    // and create a Map with necessary data in it which is
    // the id and the new value for the column and finally pass
    // the map to dbHelper
    switch (toUpdate) {
      case "IQ":
        {
          row = {
            DatabaseHelper.columnId: id,
            DatabaseHelper.columnIQ: int.parse(value),
          };
          return await dbHelper.update(row);
        }
        break;
      case "Gewicht":
        {
          row = {
            DatabaseHelper.columnId: id,
            DatabaseHelper.columnWeight: "$value kg",
          };
          return await dbHelper.update(row);
        }
        break;
      case "Größe":
        {
          row = {
            DatabaseHelper.columnId: id,
            DatabaseHelper.columnHeight: "$value cm"
          };
          return await dbHelper.update(row);
        }
        break;
      case "Nummer":
        {
          row = {
            DatabaseHelper.columnId: id,
            DatabaseHelper.columnPhonenumber: value
          };
          return await dbHelper.update(row);
        }
        break;
      case "Adresse":
        {
          row = {
            DatabaseHelper.columnId: id,
            DatabaseHelper.columnAddress: value
          };
          return await dbHelper.update(row);
        }
    }

    // If update succeeded this will return 1 and if
    // update fails for any reason this will return 0
    return 0;
  }

  // Update one or multiple parameters via EditInfo
  void manualUpdate(List<String> data) async {
    // Creating a map for easier access
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
    // Pass data to method
    int success = await dbHelper.update(row);
    // Check for success
    if (success != 1) {
      speakOut(errorText);
    }
  }

  // Get all Data from the Database
  Future<List<Map<String, dynamic>>> queryAllData() async {
    // Get data from table
    List<Map<String, dynamic>> allRows = await dbHelper.queryAllRows();
    // Check for success
    if (allRows.isNotEmpty) {
      return allRows;
    }
    return null;
  }

  // Get single entry from Database
  Future<List<Map<String, dynamic>>> querySingleData(int id) async {
    // Get data from table
    List<Map<String, dynamic>> singleRow = await dbHelper.queryOneRow(id);
    // Check for success
    if (singleRow.isNotEmpty) {
      return singleRow;
    }
    return null;
  }

  // Get all Data from the Database which has the same value
  // at columnName
  Future<List<Map<String, dynamic>>> queryByName(String name) async {
    // Get data from table
    List<Map<String, dynamic>> allRows = await dbHelper.queryByName(name);
    // Check for success
    if (allRows.isNotEmpty) {
      return allRows;
    }
    return null;
  }

  // Delete an entry from the Database
  void delete(int id) async {
    // Pass data to method
    final rowsDeleted = await dbHelper.delete(id);
    if (rowsDeleted == 1) {
      speakOut("Eintrag erfolgreich gelöscht");
    } else {
      speakOut(errorText);
    }
  }

  // Add facedata to entry in Database
  Future<String> generateFaceData() async {
    // Get image from Gallery using ImagePicker
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 25);
    if (imageFile != null) {
      // Convert image into base64 encoded String and returning it
      base64string = await encodeBase64(imageFile);
      return base64string;
    }
    return "";
  }

  // Call an ID
  void callID(String msg) async {
    try {
      // Get single data from table
      List<Map<String, dynamic>> result = await querySingleData(int.parse(msg));
      // Create Map to make access of data easier
      Map<String, dynamic> data = result[0];
      // Converting number to int because if no number is set
      // it will automaticly go to catch block and throw an error
      int.parse(data["number"]);
      speakOut("Okay");
      launch("tel://${data["number"]}");
    } catch (e) {
      speakOut("Keine Nummer gefunden oder falsches format vorhanden");
    }
  }

  // Speak out the msg using TTS
  void speakOut(String msg) async {
    // Set language, await speech completion and finally
    // speak the msg
    await tts.setLanguage("de-DE");
    await tts.awaitSpeakCompletion(true);
    SpeechScreen.ttsEmitter.emit("SPEAKING", null, "");
    await tts.speak(msg);
    // Set isFinished to true when tts has finished speaking
    SpeechScreen.ttsEmitter.emit("Finished", null, "");
  }

  // +++Data formatting+++

  // Split a String at it's spaces so it can
  // be processed later on in the code and treated
  // as a List of Strings for the different pieces of data
  List<String> splitResult(String toSplit) {
    return toSplit.split(" ");
  }

  // Encode an image into a Base64 encoded String
  Future<String> encodeBase64(File imageFile) async {
    Uint8List bytes = await imageFile.readAsBytes();
    String encoded = base64.encode(bytes);
    return encoded;
  }

  // Decode a Base64 String into a Uint8List for
  // displaying it in Image widget
  Uint8List decodeBase64(String encoded) {
    return Uint8List.fromList(base64Decode(encoded));
  }
}
