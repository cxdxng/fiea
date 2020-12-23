import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';


import 'package:fiea/BackgroundTasks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TTS extends StatefulWidget {

  static int lol = 0;
  

  @override
  _TTSState createState() => _TTSState();
}

class _TTSState extends State<TTS> {

  var base64data = "";
  var u8List;
  var visibility = 0;
  var show = true;
   

  final List<String> entries = <String>['A', 'B', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C'];
  

  @override
  void initState() {
    super.initState();
    decodeBase64(base64data);
    
  }

  @override
  Widget build(BuildContext context) {
    print("object");
    return Scaffold(
      appBar: AppBar(
        title: Text("TEST"),
      ),
      body: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(35,25,35,25),
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Card(
                    color: Colors.blueAccent,
                    child: Container(
                      width: 100,
                      height: 300,
                      child: Column(
                        children: [
                          const ListTile(
                            title: Padding(
                              padding: EdgeInsets.fromLTRB(0,10,0,10),
                              child: Text(
                                'Marlon, 2003',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                                ),
                            ),
                            subtitle: Text(
                              'Music by Julie Gable. Lyrics by Sidney Stein.'
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
    );
  }

  void runAgain(){
    setState(() {
      
    });
  }

  

  void changeVisibility(int visibitityState){
    switch(visibitityState){
      case 0:{
        setState(() {
          show = false;
          visibility = 1;
        });
      }
      break;
      case 1:{
        setState(() {
          show = true;
          visibility = 0;
        });
      }
      break;

    }
  }

  Uint8List decodeBase64(String encoded){
    var decoded = Uint8List.fromList(base64Decode(encoded));
    setState(() {
      u8List = decoded;
      show = true;

    });
    return decoded;
  }
}


