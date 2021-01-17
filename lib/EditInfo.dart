import 'package:fiea/BackgroundTasks.dart';
import 'package:flutter/material.dart';

class EditPersonInfo extends StatefulWidget {

  final List<Map<String, dynamic>> entries;

  EditPersonInfo({Key key, this.entries}) : super(key: key);

  @override
  _EditPersonInfoState createState() => _EditPersonInfoState();
}

class _EditPersonInfoState extends State<EditPersonInfo> {

  Color darkBackground = Color(0xff1e1e2c);
  Color blueAccent = Color(0xff33e1ed);

  List<String> parameters = ["Name", "Geboren", "IQ", "Größe (in cm)", "Gewicht (in kg)", "Nummer", "Addresse"];
  List<String> values;
  Map data;
  String nA = "Nicht vorhanden";
  String tempId,
    tempName, 
    tempBirth, 
    tempFacedata, 
    tempHeight,
    tempIQ,
    tempWeight, 
    tempNumber,
    tempAddress;
  
  bool unsaved = true;

  @override
  void initState() {
    super.initState();
    setInfos();
  }

  @override
  Widget build(BuildContext context) {
    
    values = [tempName, tempBirth, tempIQ, tempHeight, tempWeight, tempNumber, tempAddress, tempId, tempFacedata];
    
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff2D2D44),
          onPressed: () async {
            setState(() {
              unsaved = false;
              setFabIcon();
            });
            await Background().manualUpdate(values);
            Navigator.popUntil(context, ModalRoute.withName('/'));
            Background().speakOut("Änderungen erfolgreich übernommen");
          },
          child: setFabIcon(),
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
                      padding: const EdgeInsets.only(top: 10),
                      child: FlatButton.icon(
                        onPressed: ()async{
                          String result = await Background().generateFaceData();
                          setState(() {
                            tempFacedata = result;
                          });                          
                        },
                        icon: Icon(Icons.edit),
                        label: Text("Edit",style: TextStyle(fontSize: 25)),
                      )
                    ),
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
    data = widget.entries[0];
    tempName = data["displayName"];
    return tempName;
  }

  void setInfos(){
    data = widget.entries[0];
    tempId = data["_id"].toString();
    tempName = data["name"].toString();
    tempBirth = data["birth"].toString();
    tempHeight = data["height"].toString();
    tempIQ = data["iq"].toString();
    tempWeight = data["weight"].toString();
    tempNumber = data["number"].toString();
    tempAddress = data["address"].toString();
    tempFacedata = data["facedata"].toString();
    print("ran setInfos");
  }

  Widget makeSubTitle() {
    data = widget.entries[0];
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

  Widget setFabIcon(){
    if(unsaved){
      return Icon(Icons.save);
    }else{
      return CircularProgressIndicator();
    }
  }
}