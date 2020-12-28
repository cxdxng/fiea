import 'package:fiea/BackgroundTasks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class PersonCard extends StatelessWidget {
  Color darkBackground = Color(0xff1e1e2c);
  Color blueAccent = Color(0xff33e1ed);

  final List<Map<String, dynamic>> entries;
  Map data;
  String tempName;
  String tempBirth;
  String tempFacedata;

  PersonCard({Key key, this.entries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //print("From PersonInfo: $entries");

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff2D2D44),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.close),
        ),
        body: Container(
          color: darkBackground,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              //color: Color(0xff2D2D44),
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
                child: Column(
                  children: [
                    checkForFaceData(),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Text(
                        makeTitle(),
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Divider(
                      height: 60,
                      thickness: 2,
                      color: darkBackground,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 20),
                              child: Text(
                                makeSubTitle(),
                                style: TextStyle(
                                  fontSize: 30,
                                  height: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String makeTitle() {
    data = entries[0];
    tempName = data["name"];
    return tempName;
  }

  String makeSubTitle() {
    data = entries[0];
    var tempId = data["_id"];
    var tempDate = data["birth"];
    var tempHeight = "${data["height"]} cm";
    var tempIQ = data["iq"];
    var tempWeight = "${data["weight"]} kg";

    if(tempHeight == "null cm"){
      tempHeight = "Nicht vorhanden";    
      }
    if(tempIQ == null){
      tempIQ = "Nicht vorhanden";
    }
    if(tempWeight == "null kg"){
      tempWeight = "Nicht vorhanden";
    }

    var personInfo =
        "Kennung: $tempId\nGeboren: $tempDate\nIQ: $tempIQ\nGröße: $tempHeight\nGewicht: $tempWeight";

    return personInfo;
  }

  Widget checkForFaceData() {
    data = entries[0];
    tempName = data["name"];
    tempFacedata = data["facedata"];

    if (tempFacedata != null) {
      var image = Background().decodeBase64(tempFacedata);
      return CircleAvatar(
        backgroundImage: MemoryImage(image),
        radius: 130,
      );
    } else {
      return CircleAvatar(
        backgroundColor: Color(0xff152676),
        radius: 130,
        child: Text(
          tempName[0],
          style: TextStyle(
            fontSize: 50,
            color: Colors.white,
          ),
        ),
      );
    }
  }
}
