import 'dart:ui';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(MaterialApp(
  home: SpeechScreen(),
));

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  stt.SpeechToText _speech;
  var _isListening = false;
  var _text = "Press the button and start speaking";
  var _confidence = 1.0;
  var _state_listening = "F.I.E.A hört zu...";
  var _state_ready = "F.I.E.A Bereit";
  var _currentState = "F.I.E.A Bereit";
  var lastStatus = "";

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
        backgroundColor: Colors.redAccent,
        title: Text("Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Colors.redAccent,
        endRadius: 75,
        duration: Duration(milliseconds: 2000),
        repeatPauseDuration: Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: () {
            _listen();
          },
          backgroundColor: Colors.redAccent,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: EdgeInsets.fromLTRB(30, 30, 30, 150),
          child: Text(
            _text,
            style: TextStyle(
              fontSize: 28,
              fontStyle: FontStyle.italic,
            ),
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
        _listen();
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
      if (msg != "" && lastStatus == "notListening") {
        print(msg);
        if (msg == "info Kennung 5") {
          print("now it even works in Flutter and Dart!!!");
        }
      }
    });
  }

  void _listen() async {
    if (!_isListening) {
      _currentState = _state_listening;
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
        _currentState = _state_ready;
      });
      _speech.stop();
    }
  }
}
