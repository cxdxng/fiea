
import 'package:fiea/BackgroundTasks.dart';
import 'package:fiea/personInfo.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DbViewer extends StatelessWidget {

  Color blueAccent = Color(0xff33e1ed);
  Color darkBackground = Color(0xff1e1e2c);
  final List<Map<String, dynamic>> entries;
  Map data;
  String tempId, tempName, tempBirth, tempFacedata, tempHeight, tempIQ, tempWeight, tempNumber, tempAddress;
  String nA = "Nicht vorhanden";

    
  DbViewer({Key key, this.entries}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    //print("From DatabaseViewer: $entries");

    

    return SafeArea(
      child: Scaffold(
        backgroundColor: darkBackground,
        floatingActionButton: FloatingActionButton(
          onPressed: () {Navigator.pop(context);},
          child: Icon(Icons.close),     
          ),
        body: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(35,25,35,25),
                //itemCount: entries.length,

                //For testing, only create 5 Cards
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
                          print(index);
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
                                        padding: const EdgeInsets.fromLTRB(0,10,0,5),
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
      ),
    );
  }

  String makeTitle(int index){
    data = entries[index];
    var tempId = data["_id"];
    tempName = data["name"];

    return "#$tempId: $tempName";
  }

  String makeSubTitle(int index){
    data = entries[index];
    var tempDate = data["birth"];
    tempFacedata = data["facedata"];
    

    if(tempFacedata != nA) return "Geboren: $tempDate\nGesichtsdaten: vorhanden";
    else return "Geboren: $tempDate\nGesichtsdaten: nicht vorhanden";
  }

  Widget checkForFaceData(int index){
    data = entries[index];
    tempName = data["name"];
    tempFacedata = data["facedata"];
    

    if(tempFacedata != nA){
      var image =  Background().decodeBase64(tempFacedata);
      return CircleAvatar(
        backgroundImage: MemoryImage(image),
        radius: 70,       
        );
    }else{
      return CircleAvatar(
        backgroundColor: Color(0xff152676),
        radius: 70,                          
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

  void changeRoute(BuildContext context, int index){
    data = entries[index];
    tempFacedata = data["facedata"];

    tempName = data["name"].toString();
    tempId = data["_id"].toString();
    tempBirth = data["birth"].toString();
    tempHeight = data["height"].toString();
    tempIQ = data["iq"].toString();
    tempWeight = data["weight"].toString();
    tempNumber = data["number"].toString();
    tempAddress = data["address"].toString();

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
    List<Map<String, dynamic>> lol = List();
    lol.add(content);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonCard(entries: lol,),
    ));
  }

}