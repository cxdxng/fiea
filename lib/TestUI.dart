import 'package:fiea/BackgroundTasks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class TTS extends StatefulWidget {

  @override
  _TTSState createState() => _TTSState();
}

class _TTSState extends State<TTS> {

  @override
  Widget build(BuildContext context) {
    print("object");
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("TEST"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(
            onPressed: () => Background().callID("1"),
            child: Text("Call Marlon"),
          ),
          Text("Hello word"),
          Image.asset("assets/finalAI.gif")
        ],
      )
    );
  }

  
}


