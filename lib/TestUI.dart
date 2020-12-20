import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fiea/BackgroundTasks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TTS extends StatefulWidget {
  @override
  _TTSState createState() => _TTSState();
}

class _TTSState extends State<TTS> {

  var base64data = "";
  var textOrWhat = "Hello world";
  var u8List;
  var visibility = 0;
  var showImage = false;


  @override
  void initState() {
    super.initState();
    decodeBase64(base64data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TEST"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /* RaisedButton(
              child: Text("change"),
                onPressed: () async {
                  File imageFile =
                  await ImagePicker.pickImage(source: ImageSource.gallery);
                  if (imageFile != null) {
                    base64data = await encodeBase64(imageFile);
                    print(base64data);
                  }
                },
            ), */
            RaisedButton(
              child: Text("change Visibility"),
              onPressed: (){
                changeVisibility(visibility);
                print(visibility);
              },
            ),
            Text(textOrWhat),
            if (showImage) Image(image: AssetImage("assets/ai.jpg")),
          ],
        ),
      ),
    );
  }

  Future<String> encodeBase64(File imageFile) async{
    Uint8List bytes = await imageFile.readAsBytes();
    var encoded = base64.encode(bytes);
    decodeBase64(encoded);
    return encoded;
  }

  void changeVisibility(int visibitityState){
    switch(visibitityState){
      case 0:{
        setState(() {
          showImage = false;
          visibility = 1;
        });
      }
      break;
      case 1:{
        setState(() {
          showImage = true;
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
      showImage = true;

    });
    return decoded;
  }
}


