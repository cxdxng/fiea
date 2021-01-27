import 'package:fiea/BackgroundTasks.dart';
import 'package:fiea/EditInfo.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class PersonCard extends StatelessWidget {
  
  // Create color variables for UI
  Color darkBackground = Color(0xff1e1e2c);
  Color blueAccent = Color(0xff33e1ed);
  // Create necessary variables
  final List<Map<String, dynamic>> entries;
  Map data;
  String tempId, tempName, tempBirth, tempFacedata, tempHeight, tempIQ, tempWeight, tempNumber, tempAddress;
  String nA = "Nicht vorhanden";

  PersonCard({Key key, this.entries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create the UI
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff2D2D44),
          onPressed: () {
            changeRoute(context);
          },
          child: Icon(Icons.edit),
        ),
        body: Stack(
          children: [
            Container(
              color: darkBackground,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
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
            InkWell(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5,5,0,0),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              onTap: (){Navigator.pop(context);}
            ),

          ],
        ),
      ),
    );
  }

  // Method for format the title 
  String makeTitle() {
    // Store information in Map for later use
    data = entries[0];
    // Get necessary data from Map
    tempName = data["name"];
    // Return the name as String for the title
    return tempName;
  }

  String makeSubTitle() {
    // Store information in Map for later use
    data = entries[0];
    // Get necessary data from Map
    tempId = data["_id"].toString();
    tempBirth = data["birth"].toString();
    tempHeight = data["height"].toString();
    tempIQ = data["iq"].toString();
    tempWeight = data["weight"].toString();
    tempNumber = data["number"].toString();
    tempAddress = data["address"].toString();
    // Return user info as correctly formatted String
    return "Kennung: $tempId\nGeboren: $tempBirth\nIQ: $tempIQ\nGröße: $tempHeight\nGewicht: $tempWeight\nNummer: $tempNumber\nAddresse: $tempAddress"; 
  }

  Widget checkForFaceData() {
    // Store information in Map for later use
    data = entries[0];
    // Get necessary data from Map
    tempName = data["name"];
    tempFacedata = data["facedata"];
    // if facedata is available create a CircleAvatar and display 
    // the facedata in it and return it
    if (tempFacedata != nA) {
      var image = Background().decodeBase64(tempFacedata);
      return CircleAvatar(
        backgroundImage: MemoryImage(image),
        radius: 100,
      );
    // if facedata is not available return a CircleAvatar
    // with first letter of the name  
    }else {
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

  // Method for passing user info to PersonCard
  void changeRoute(BuildContext context){
    
    // Create Map with String and dynamic type and fill
    // it with user info for passing to EditInfo
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
    };
    // Add the Map to a Lst because it is necessary for passing
    List<Map<String, dynamic>> dataList = List();
    dataList.add(content);
    // Push to Personcard and pass user data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPersonInfo(entries: dataList,),
    )).then((value){
    });
  }
}