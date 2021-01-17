import 'package:fiea/BackgroundTasks.dart';
import 'package:fiea/EditInfo.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class PersonCard extends StatelessWidget {

  Color darkBackground = Color(0xff1e1e2c);
  Color blueAccent = Color(0xff33e1ed);

  final List<Map<String, dynamic>> entries;
  Map data;

  String tempId, tempName, tempBirth, tempFacedata, tempHeight, tempIQ, tempWeight, tempNumber, tempAddress;
  String nA = "Nicht vorhanden";

  PersonCard({Key key, this.entries}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff2D2D44),
          onPressed: () {
            changeRoute(context);
          },
          child: Icon(Icons.edit),
        ),
        body: Container(
          color: darkBackground,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
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
    tempId = data["_id"].toString();
    tempBirth = data["birth"].toString();
    tempHeight = data["height"].toString();
    tempIQ = data["iq"].toString();
    tempWeight = data["weight"].toString();
    tempNumber = data["number"].toString();
    tempAddress = data["address"].toString();

    
    return "Kennung: $tempId\nGeboren: $tempBirth\nIQ: $tempIQ\nGröße: $tempHeight\nGewicht: $tempWeight\nNummer: $tempNumber\nAddresse: $tempAddress"; 
  }

  Widget checkForFaceData() {
    data = entries[0];
    tempName = data["name"];
    tempFacedata = data["facedata"];

    if (tempFacedata != nA) {
      var image = Background().decodeBase64(tempFacedata);
      return CircleAvatar(
        backgroundImage: MemoryImage(image),
        radius: 100,
      );
    } else {
      return CircleAvatar(
        backgroundColor: Color(0xff152676),
        radius: 100,
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

  void changeRoute(BuildContext context){

    Map<String, dynamic> content = {
      "name": tempName,
      "birth": tempBirth,
      "iq": tempIQ,
      "height": tempHeight,
      "weight": tempWeight,
      "number": tempNumber,
      "address": tempAddress,
      "displayName": tempName,
      "_id": tempId,
      "facedata": tempFacedata,

      //"facedata": tempFacedata
    };
    List<Map<String, dynamic>> lol = List();
    lol.add(content);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPersonInfo(entries: lol,),
    )).then((value){
    });
  }
}