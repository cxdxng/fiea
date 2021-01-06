import 'dart:ui';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:fiea/Chatbot.dart';
import 'package:fiea/DatabaseViewer.dart';
import 'package:fiea/EditInfo.dart';
import 'package:fiea/TestUI.dart';
import 'package:fiea/personInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'BackgroundTasks.dart';
import 'DatabaseViewer.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',

  routes: {
    '/': (context) => SpeechScreen(),
    '/test': (context) => TTS(),
    '/dbviewer': (context) => DbViewer(),
    '/personCard': (context) => PersonCard(),
    '/editInfo': (context) => EditPersonInfo(),
  },
));

class SpeechScreen extends StatefulWidget {

  static bool isFinishedWithTalking = true;
  
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  stt.SpeechToText _speech;
  var bg = Background();
  var _isListening = false;
  var _stateBusy = "F.I.E.A hört zu";
  var _stateReady = "F.I.E.A Bereit";
  var _sttState = "F.I.E.A Bereit";
  var _text = "Sag etwas...";
  var errorText = "Fehler, bitte versuche es erneut";
  var lastStatus = "";
  List<String> split;

  var currentRequestCode = 100;
  static const int normalRequest = 100;
  static const int newEntry = 101;
  static const int updateEntry = 102;
  static const int deleteEntry = 103;
  static const int makeCall = 104;

  /* Request codes
  100 = normal Request
  101 = new entry
  102 = update entry
  103 = delete entry
  104 = make call
   */

  var blueAccent = Color(0xff33e1ed);
  var darkBackground = Color(0xff1e1e2c);
  Color fabColor = Color(0xff080e2c);

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          animate: _isListening,
          glowColor: Color(0xff44D6E9),
          endRadius: 75,
          duration: Duration(milliseconds: 2000),
          repeatPauseDuration: Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton(
            onPressed: () {
              if (SpeechScreen.isFinishedWithTalking) {
                listen();
              }            
            },
            backgroundColor: fabColor,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
        ),

        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/finalAI.gif"),
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Center(
                  child: Text(
                    _sttState,
                    style: TextStyle(
                      fontSize: 45,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                ),
              ),
              SingleChildScrollView(
                reverse: true,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 150),
                  child: Text(
                    _text,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      //fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = "$status";
      print(status);
      
      if (status == "notListening") {
        _sttState = _stateReady;
        listen();
      }else{
        _sttState = _stateBusy;
      }
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    var msg = result.recognizedWords;
    setState(() {
      _text = msg;
    });
    setState(() async{
      if(msg != "" && lastStatus == "notListening"){
        print("currentRequestCode: $currentRequestCode");

        switch(currentRequestCode){
          case normalRequest:{
            List<Map<String, dynamic>> result = await Background().handleResults(msg);
            if(result != null && msg=="Datenbank anzeigen"){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DbViewer(entries: result,),
                ));
            }else if(result != null && msg.contains("info Kennung")){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonCard(entries: result,),
                ));
            }else if(result == null && msg=="Datenbank anzeigen"){
              bg.speakOut("Keine Daten vorhanden");
            }else{
              bg.speakOut("Das habe ich nicht verstanden");
            }
            print("ran 100");
          }
          break;
          case newEntry:{
            currentRequestCode = normalRequest;
            split = bg.splitResult(msg);
            try{
              bg.insert(split[0], int.parse(split[1]));
            }catch(FormatException){
              bg.speakOut(errorText);
            }
          }
          break;
          case updateEntry:{
            currentRequestCode = normalRequest;
            split = bg.splitResult(msg);
            try{
              // using second index for id here because 
              // of number formatting you need to say
              // "Kennung" before the id because otherwise
              // the stt returns the number in words
              int success = bg.update(int.parse(split[1]), split[2], split[3]) as int;
              if(success == 1){
                bg.speakOut("Änderungen erfolgreich übernommen");
              }

            }catch(FormatException){
              bg.speakOut(errorText);
            }
            print("ran 102");
          }
          break;
          case deleteEntry:{
            currentRequestCode = normalRequest;
            split = bg.splitResult(msg);
            try{
              bg.delete(int.parse(split[1]));
            }catch(FormatException){
              bg.speakOut(errorText);
            }
          }
          break;
          case makeCall:{
            currentRequestCode = normalRequest;
            split = bg.splitResult(msg);
            bg.callID(split[1]);
          }
          break;
        }

        switch(msg){
          case "neuer Eintrag":{
            bg.speakOut("Name und Jahr bitte");
            currentRequestCode = newEntry;   
          }
          break;
          case "Eintrag updaten":{
            bg.speakOut("Kennung, Attribut und Wert bitte");
            currentRequestCode = updateEntry;
          }
          break;
          case "Eintrag löschen":{
            bg.speakOut("Kennung bitte");
            currentRequestCode = deleteEntry;          
          }
          break;
          case "anruf tätigen":{
            print(msg);
            bg.speakOut("Welche Kennung möchten Sie anrufen?");
            currentRequestCode = makeCall;
          }
        }
      }
    });
  }

  void listen() async {
    if (!_isListening) {
      var available = await _speech.initialize(
        onStatus: statusListener,
        onError: (val) => print("onError: $val"),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: resultListener,
        );
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }
}