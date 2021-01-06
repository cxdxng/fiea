import 'package:fiea/BackgroundTasks.dart';
import 'package:flutter/material.dart';

class EditPersonInfo extends StatelessWidget {

  Color darkBackground = Color(0xff1e1e2c);
  Color blueAccent = Color(0xff33e1ed);

  final List<Map<String, dynamic>> entries;
  List<String> parameters = ["Name", "Geboren", "IQ", "Größe", "Gewicht", "Nummer", "Addresse"];
  List<String> values;
  List<TextEditingController> controllerList;

  TextEditingController nameController, birthController, iqController, heightController, weightController, numberController, addressController = TextEditingController();
  Map data;

  String tempId, tempName, tempBirth, tempFacedata, tempHeight, tempIQ, tempWeight, tempNumber, tempAddress;
  String nA = "Nicht vorhanden";

  EditPersonInfo({Key key, this.entries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //print("From PersonInfo: $entries");

    controllerList = [nameController, birthController, iqController, heightController, weightController, numberController, addressController];
    setInfos();
    values = [tempName, tempBirth, tempIQ, tempHeight, tempWeight, tempNumber, tempAddress, tempId, tempFacedata];
    


    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff2D2D44),
          onPressed: () async {
            await Background().manualUpdate(values);
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          child: Icon(Icons.save),
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
                      child: makeSubTitle()
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
    tempName = data["displayName"];
    return tempName;
  }
  void setInfos(){
    data = entries[0];
    tempId = data["_id"].toString();
    tempName = data["name"].toString();
    tempBirth = data["birth"].toString();
    tempHeight = data["height"].toString();
    tempIQ = data["iq"].toString();
    tempWeight = data["weight"].toString();
    tempNumber = data["number"].toString();
    tempAddress = data["address"].toString();
    tempFacedata = data["facedata"].toString();
  }

  Widget makeSubTitle() {
    data = entries[0];
    var list = [];

    data.forEach((key, value) {list.add(value);});
    
    return ListView.builder(
      itemCount: data.length-3,
      itemBuilder: (BuildContext context, int index){
        return Padding(
          padding: const EdgeInsets.all(3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(3),
                child: Text(
                  parameters[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              TextFormField(
                //controller: controllerList[index],
                style: TextStyle(color: Colors.black),
                onChanged: (value) => values[index] = value,
                decoration: InputDecoration(
                  hintText: values[index],
                  
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                ),
              ),
            ],
          ),
        );
      }
    );
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
}