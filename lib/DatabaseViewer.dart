import 'package:fiea/BackgroundTasks.dart';
import 'package:fiea/personInfo.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DbViewer extends StatelessWidget {

  // Create color variables for UI
  Color blueAccent = Color(0xff33e1ed);
  Color darkBackground = Color(0xff1e1e2c);

  // Create necessary variables
  final List<Map<String, dynamic>> entries;
  Map data;
  String tempId, tempName, tempBirth, tempFacedata, tempHeight, tempIQ, tempWeight, tempNumber, tempAddress;
  String nA = "Nicht vorhanden";

  DbViewer({Key key, this.entries}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // Create the UI
    return SafeArea(
      child: Scaffold(
        backgroundColor: darkBackground,    
        body: Stack(
          children: [
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(35,25,35,25),
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Card(
                    color: Colors.blueAccent,
                    elevation: 10,
                    child: InkWell(
                      splashColor: Colors.white,
                      onTap: (){
                        changeRoute(context, index);
                      },
                      child: Container(
                        width: 100,
                        child: Column(
                          children: [
                            ListTile(
                              title: Padding(
                                padding: EdgeInsets.fromLTRB(0,20,0,20),
                                child: Column(
                                  children: [
                                    checkForFaceData(index),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        makeTitle(index),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        ),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  makeSubTitle(index),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
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
              onTap: ()=> Navigator.pop(context)
            ),
          ],
        ),
      ),
    );
  }

  // Method for format the Title 
  String makeTitle(int index){
    // Store information in Map for later use
    data = entries[index];
    // Get necessary data from Map
    tempId = data["_id"].toString();
    tempName = data["name"];
    // Return the title as a String
    return "#$tempId: $tempName";
  }

  // Method for formatting the subtitle
  String makeSubTitle(int index){
    // Store information in Map for later use
    data = entries[index];
    // Get necessary data from Map
    tempBirth = data["birth"].toString();
    tempFacedata = data["facedata"];
    
    // Check if facedata is available and return the corrisponding subtitle
    if(tempFacedata != nA) return "Geboren: $tempBirth\nGesichtsdaten: vorhanden";
    else return "Geboren: $tempBirth\nGesichtsdaten: nicht vorhanden";
  }

  // Method for checking for available facedata
  Widget checkForFaceData(int index){
    // Store information in Map
    data = entries[index];
    // Get necessary data from Map
    tempName = data["name"];
    tempFacedata = data["facedata"];

    // if facedata is available create a CircleAvatar and display 
    // the facedata in it and return it
    if(tempFacedata != nA){
      // Decode base64 String to Memory image for displaying
      var image = Background().decodeBase64(tempFacedata);
      return CircleAvatar(
        backgroundImage: MemoryImage(image),
        radius: 70,       
        backgroundColor: Colors.white,
      );
    // if facedata is not available return a CircleAvatar
    // with first letter of the name  
    }else{
      return CircleAvatar(
        backgroundColor: Color(0xff152676),
        radius: 70,                          
        child: Text(
          // Get first letter from name
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
  void changeRoute(BuildContext context, int index){
    // Store information in Map
    data = entries[index];
    // Get necessary data from Map
    tempFacedata = data["facedata"];
    tempName = data["name"].toString();
    tempId = data["_id"].toString();
    tempBirth = data["birth"].toString();
    tempHeight = data["height"].toString();
    tempIQ = data["iq"].toString();
    tempWeight = data["weight"].toString();
    tempNumber = data["number"].toString();
    tempAddress = data["address"].toString();
    // Create Map with String and dynamic type and fill
    // it with user info for passing to PersonCard
    Map<String, dynamic> content = {
      "_id": tempId,
      "name": tempName,
      "birth": tempBirth,
      "facedata": tempFacedata,
      "iq": tempIQ,
      "height": tempHeight,
      "weight": tempWeight,
      "number": tempNumber,
      "address": tempAddress,
    };
    // Add the Map to a Lst because it is necessary for passing
    List<Map<String, dynamic>> dataList = List();
    dataList.add(content);
    // Push to Personcard and pass user data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonCard(entries: dataList,),
    ));
  }

}