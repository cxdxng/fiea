import 'package:flutter/material.dart';

class TTS extends StatefulWidget {
  @override
  _TTSSTate createState() => _TTSSTate();
}

class _TTSSTate extends State<TTS> {
  @override
  void initState() {
    super.initState();
  }

  void sendMessage() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () => sendMessage(),
              child: Text("data"),
            )
          ],
        ),
      ),
    );
  }
}
