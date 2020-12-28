import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TTS extends StatefulWidget {

  @override
  _TTSState createState() => _TTSState();
}

class _TTSState extends State<TTS> {


  @override
  Widget build(BuildContext context) {
    print("object");
    return Scaffold(
      appBar: AppBar(
        title: Text("TEST"),
      ),
      body: Column(
        children: [
          Text("Hello word"),
        ],
      )
    );
  }

  
}


