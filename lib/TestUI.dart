import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_picker/flutter_picker.dart';
import 'package:porcupine/porcupine_manager.dart';
import 'package:porcupine/porcupine_error.dart';


class TTS extends StatefulWidget {
  @override
  _TTSSTate createState() => _TTSSTate();
}

class _TTSSTate extends State<TTS> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isButtonDisabled = false;
  bool isProcessing = false;
  Color detectionColour = new Color(0xff00e5c3);
  Color defaultColour = new Color(0xfff5fcff);
  Color backgroundColour;
  String currentKeyword = "Click to choose a keyword";
  PorcupineManager _porcupineManager;
  @override
  void initState() {
    super.initState();
    this.setState(() {
      isButtonDisabled = true;
      backgroundColour = defaultColour;
    });
  }

  Future<void> loadNewKeyword(String keyword) async {
    this.setState(() {
      isButtonDisabled = true;
    });

    if (isProcessing) {
      _stopProcessing();
    }

    if (_porcupineManager != null) {
      _porcupineManager.delete();
    }
    try {
      _porcupineManager = await PorcupineManager.fromKeywords(
          ["jarvis"], wakeWordCallback,
          errorCallback: errorCallback);
      this.setState(() {
        currentKeyword = "jarvis";
      });
    } on PvError catch (ex) {
      print("Failed to initialize Porcupine: ${ex.message}");
    } finally {
      this.setState(() {
        isButtonDisabled = false;
      });
    }
  }

  void wakeWordCallback(int keywordIndex) {
    if (keywordIndex >= 0) {
      this.setState(() {
        backgroundColour = detectionColour;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        this.setState(() {
          backgroundColour = defaultColour;
        });
      });
    }
  }

  void errorCallback(PvError error) {
    print(error.message);
  }

  Future<void> _startProcessing() async {
    this.setState(() {
      isButtonDisabled = true;
    });

    try {
      await _porcupineManager.start();
      this.setState(() {
        isProcessing = true;
      });
    } on PvAudioException catch (ex) {
      print("Failed to start audio capture: ${ex.message}");
    } finally {
      this.setState(() {
        isButtonDisabled = false;
      });
    }
  }

  Future<void> _stopProcessing() async {
    this.setState(() {
      isButtonDisabled = true;
    });

    await _porcupineManager.stop();

    this.setState(() {
      isButtonDisabled = false;
      isProcessing = false;
    });
  }

  void _toggleProcessing() async {
    if (isProcessing) {
      await _stopProcessing();
    } else {
      await _startProcessing();
    }
  }

  Color picoBlue = Color.fromRGBO(55, 125, 255, 1);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundColour,
        appBar: AppBar(
          title: const Text('Porcupine Demo'),
          backgroundColor: picoBlue,
        ),
        body: Column(
          children: [buildStartButton(context), footer],
        ),
      ),
    );
  }

  

  buildStartButton(BuildContext context) {
    return new Expanded(
      flex: 2,
      child: Container(
          child: SizedBox(
              width: 150,
              height: 150,
              child: RaisedButton(
                shape: CircleBorder(),
                textColor: Colors.white,
                color: picoBlue,
                onPressed: isButtonDisabled ? null : _toggleProcessing,
                child: Text(isProcessing ? "Stop" : "Start",
                    style: TextStyle(fontSize: 30)),
              ))),
    );
  }

  Widget footer = Expanded(
      flex: 1,
      child: Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 20),
          child: const Text(
            "Made in Vancouver, Canada by Picovoice",
            style: TextStyle(color: Color(0xff666666)),
          )));

  
}
