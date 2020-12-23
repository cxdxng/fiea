import 'dart:ui';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:fiea/DatabaseViewer.dart';
import 'package:fiea/TestUI.dart';
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
  },
));

class SpeechScreen extends StatefulWidget {

  static bool show = false;
  static var entries = <String>['A', 'B', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C'];


  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  stt.SpeechToText _speech;
  var _isListening = false;
  var _text = "F.I.E.A Bereit";
  var _confidence = 1.0;
  var lastStatus = "";

  // BackgroundTask return results
  static const String openDBViewer = "viewDB";


  var blueAccent = Color(0xff33e1ed);
  var darkBackground = Color(0xff1e1e2c);

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: blueAccent,
        title: Text("Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%"),
      ),
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
            listen();
            SpeechScreen.show = false;
          },
          backgroundColor: Color(0xff080e2c),
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/ai.jpg"),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(

              reverse: true,
              child: Container(
                padding: EdgeInsets.fromLTRB(30, 30, 30, 150),
                child: Text(
                  _text,
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    
  }

  

  void statusListener(String status) {
    setState(() {
      lastStatus = "$status";
      print(status);
      if (status == "notListening") {
        listen();
      }
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    var msg = result.recognizedWords;
    setState(() {
      _text = msg;
      if (result.hasConfidenceRating && result.confidence > 0) {
        _confidence = result.confidence;
      }
    });
    setState(() async{
      
      if (msg != "" && lastStatus == "notListening") {
        print("msg is: +++$msg+++");
        List<Map<String, dynamic>> result = await Background().handleResults(msg);
        if(result != null){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DbViewer(entries: result,),
            ));
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