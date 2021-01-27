import 'package:fiea/BackgroundTasks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eventify/eventify.dart';
import 'package:shared_preferences/shared_preferences.dart';
class TTS extends StatefulWidget {
  static EventEmitter emitter = new EventEmitter();
  @override
  _TTSState createState() => _TTSState();
}

class _TTSState extends State<TTS> {

  bool lul = true;
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    if (_seen) {

    }else {
      prefs.setBool('seen', true);
      Background().speakOut("Hallo\n und wilkommen zu deinem persönlichen Assistenten\nIch wurde dafür ausgelegt, bei der Datenverwaltung von Menschen zu helfen\nZu aller erst solltest du dich selbst in die Datenbank eintragen\nSage dazu einfach 'neuer Eintrag'\n und nenne mir danach deinen Namen und dein Geburtsjahr!");
    }
  }

  @override
  void initState() {
    super.initState();
    checkFirstSeen();
  }
  @override
  Widget build(BuildContext context) {
    TTS.emitter.on("lul", null, (ev, context) {
      print("megalul");
      setState(() {
        lul = true;
      });
      
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("TEST"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Hello word"),
        ],
      )
    );
  } 
}