import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';


class TTS extends StatefulWidget {
  @override
  _TTSSTate createState() => _TTSSTate();
}

class _TTSSTate extends State<TTS> {

  

  @override
  void initState() {
    super.initState();
  }

  void sendMessage(){
    FlutterOpenWhatsapp.sendSingleMessage("1713006650", "Test");
  }

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            RaisedButton(onPressed: () => sendMessage(), child: Text("data"),)
          ],
        ),
      ),
    );
  }
}