import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:fiea/DatabaseViewer.dart';
import 'package:fiea/main.dart';
import 'package:fiea/personInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'DatabaseHelper.dart';
import 'NotifManager.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Background {
  // Create necessary Objects
  final dbHelper = DatabaseHelper.instance;
  FlutterTts tts = FlutterTts();

  // Create necessary variables
  String base64string;
  String nA = "Nicht vorhanden";
  String errorText = "Fehler, bitte versuche es erneut";
  bool isTTSfinished = true;
  Map<String, dynamic> row;

  List<dynamic> mysqlData;

  // Get all data from MySQL database and save them in a local sqlite
  // database so that the database is up to date and available at all times

  void getDataFromMySQL() async {
    setupTTS();
    // Get data from MySQL

    dbHelper.emptyTable();
  }

  void insertInLocalDatabase() async {
    // Delete all data from database
    dbHelper.emptyTable();

    for (var i = 0; i < mysqlData.length; i++) {
      // Creating a map for easier access
      row = {
        DatabaseHelper.columnId: mysqlData[i]["id"],
        DatabaseHelper.columnName: mysqlData[i]["name"],
        DatabaseHelper.columnBirth: mysqlData[i]["birth"],
        DatabaseHelper.columnIQ: mysqlData[i]["iq"],
        DatabaseHelper.columnWeight: mysqlData[i]["weight"],
        DatabaseHelper.columnHeight: mysqlData[i]["height"],
        DatabaseHelper.columnPhonenumber: mysqlData[i]["number"],
        DatabaseHelper.columnAddress: mysqlData[i]["address"],
        DatabaseHelper.columnFacedata: mysqlData[i]["facedata"],
        DatabaseHelper.columnOSINT: mysqlData[i]["osint"],
      };
      // Insert every row into sqlite db
      await dbHelper.insert(row);

      speakOut("Bereit");
    }
  }

  // Process result from STT and run the correct function for the command
  Future<bool> handleNormalResult(String msg, BuildContext context) async {
    // Split the msg at spaces
    List<String> split = splitResult(msg);
    msg = msg.toLowerCase();
    // Check msg and run corresponding method
    if (msg.contains("info kennung")) {
      try {
        // Pass msg to method
        List<Map<String, dynamic>> singleData =
            await querySingleData(int.parse(split[2]));
        // Check for success
        if (singleData != null) {
          speakOut("Daten von Kennung ${split[2]}:Bitteschön");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PersonCard(entries: singleData)));
        }
        return true;
      } catch (e) {
        speakOut(errorText);
      }

      // Add face
    } else if (msg.contains("gesicht hinzufügen")) {
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

      // Show database
    } else if (msg == "datenbank anzeigen") {
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

      // Delete database
    } else if (msg == "datenbank löschen") {
      // Delete the current table from Database
      dbHelper.deleteTable();
      return true;

      // Filter database
    } else if (msg.contains(" suchen")) {
      try {
        List<Map<String, dynamic>> cardInfo = await queryByName(split[0]);
        if (cardInfo != null) {
          speakOut("Alle Ergebnisse für: ${split[0]}");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DbViewer(entries: cardInfo)));
        } else {
          speakOut("Keine Ergebnisse für ${split[0]} gefunden");
        }
      } catch (e) {
        speakOut(errorText);
      }
      // Open Apps
    } else if (msg.contains("öffne")) {
      openApp(split[1]);
      speakOut("Wird geöffnet");
      return true;
      // Scan Networks
    } else if (msg == "netzwerk scannen") {
      Navigator.pushNamed(context, "/networkScanner");
      return true;

      // Get daily covid information
    } else if (msg == "covid Info") {
      Navigator.pushNamed(context, "/covidInfo");
      return true;

      // Start Auto mode
    } else if (msg == "fahrmodus starten") {
      speakOut("Fahrmodus aktiviert");
      NotifManager().initPlatformState();
      NotifManager.carEmitter.emit("start", null, "");
      return true;
      // Stop Auto mode
    } else if (msg == "fahrmodus beenden") {
      speakOut("Fahrmodus deaktiviert");
      NotifManager.carEmitter.emit("end", null, "");
      return true;
    }

    // If non of the methods above fired, return false to go on with
    // passing the msg to the Chatbot
    return false;
  }

  // HELPER FUNCTIONS

  // Insert a new entry into the Table
  void insert(String name, int year) async {
    // Creating a map for easier access
    row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnBirth: year.toString(),
      DatabaseHelper.columnIQ: nA,
      DatabaseHelper.columnWeight: nA,
      DatabaseHelper.columnHeight: nA,
      DatabaseHelper.columnPhonenumber: nA,
      DatabaseHelper.columnAddress: nA,
      DatabaseHelper.columnFacedata: nA,
    };
    final id = await dbHelper.insert(row);
    // Add the id to the row
    row["id"] = id.toString();
    // Let user know which id the new entry has
    speakOut('Erfolgreich eingetragen...Neue Kennung: $id');
  }

  // Update one parameter of an ID with Speech input
  Future<int> update(int id, String toUpdate, String value) async {
    // Check for the column that needs to be updated
    // and create a Map with necessary data in it which is
    // the id and the new value for the column and finally pass
    // the map to dbHelper
    switch (toUpdate) {
      case "Name":
        {
          row = {
            DatabaseHelper.columnId: id,
            DatabaseHelper.columnName: value,
          };
          return await dbHelper.update(row);
        }
        break;
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
        break;
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
      DatabaseHelper.columnOSINT: data[7],
      DatabaseHelper.columnId: data[8],
      DatabaseHelper.columnFacedata: data[9],
    };

    print(row);

    // Update MySQL data
    // Pass data to method
    int success = await dbHelper.update(row);
    // Check for success
    if (success == 1) {
      speakOut("Daten erfolgreich geupdated");
    } else {
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
    // Delete MySQL entry

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
    final ImagePicker _picker = ImagePicker();

    final XFile imageFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 25);
    if (imageFile != null) {
      //Convert image into base64 encoded String and returning it
      base64string = await encodeBase64(File(imageFile.path));
      return base64string;
    }
    return "";
  }

  void setupTTS() async {
    // Set language, await speech completion, speech rate and Voice
    await tts.setLanguage("de-DE");
    await tts.setVoice({"name": "de-de-x-deb-network", "locale": "de-DE"});
    await tts.awaitSpeakCompletion(true);
    await tts.setSpeechRate(0.6);
  }

  // Speak out the msg using TTS
  void speakOut(String msg) async {
    // Set language, await speech completion and finally
    // speak the msg
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

  // Encode an image into a Base64 String
  Future<String> encodeBase64(File imageFile) async {
    Uint8List bytes = await imageFile.readAsBytes();
    String encoded = base64.encode(bytes);
    return encoded;
  }

  // Decode a Base64 String into a Uint8List for
  // displaying it in an Image widget
  Uint8List decodeBase64(String encoded) {
    return Uint8List.fromList(base64Decode(encoded));
  }

  // Update one column in MySQL database

  // Open a certain App
  void openApp(String appName) async {
    // Check for app name and open app according to its package name
    // switch (appName) {
    //   case "whatsapp":
    //     {
    //       await LaunchApp.openApp(
    //           androidPackageName: "com.whatsapp", openStore: false);
    //     }
    //     break;
    //   case "youtube":
    //     {
    //       await LaunchApp.openApp(
    //           androidPackageName: "com.google.android.youtube",
    //           openStore: false);
    //     }
    // }
  }
}
