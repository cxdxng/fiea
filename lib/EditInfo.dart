import 'package:fiea/BackgroundTasks.dart';
import 'package:flutter/material.dart';

class EditPersonInfo extends StatefulWidget {

  final List<Map<String, dynamic>> entries;
  
  EditPersonInfo({Key key, this.entries}) : super(key: key);

  @override
  _EditPersonInfoState createState() => _EditPersonInfoState();
}

class _EditPersonInfoState extends State<EditPersonInfo> {

  // Create color variables for UI
  Color darkBackground = Color(0xff1e1e2c);
  Color blueAccent = Color(0xff33e1ed);

  // Create necessary variables
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

  //set infos when the Class starts
  @override
  void initState() {
    super.initState();
    setInfos();
  }

  @override
  Widget build(BuildContext context) {
    // Add the parameter Strings to the List
    values = [tempName, tempBirth, tempIQ, tempHeight, tempWeight, tempNumber, tempAddress, tempId, tempFacedata];
    // Create the UI
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff2D2D44),
          onPressed: () async {
            setState(() {
              unsaved = false;
              setFabIcon();
            });
            // Update values when the save button is clicked
            await Background().manualUpdate(values);
            // Go back to homescreeen
            Navigator.popUntil(context, ModalRoute.withName('/'));
            
          },
          child: setFabIcon(),
        ),
        body: Stack(
          children: [
            Container(
              color: darkBackground,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
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
                              // Run generateFacedata for picking and generating new facedata
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
                          padding: const EdgeInsets.only(top: 10),
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
    data = widget.entries[0];
    // Get necessary data from Map
    tempName = data["displayName"];
    // Return the name as String for the title
    return tempName;
  }
  // Set parameter Strings to the current values for displaying them as 
  // a hint in the textfields
  void setInfos(){
    data = widget.entries[0];
    tempId = data["id"].toString();
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
    
    // Store information in Map for later use
    data = widget.entries[0];
    // Create a List and add data into it for use in Listview builder
    List<dynamic> list = [];
    data.forEach((key, value) {list.add(value);});
    
    // Create a Listview that contains all necessary textfields
    // for editing the values from the user
    return ListView.builder(
      // Subtract 3 from length because id and dispayName should not be edited
      // and thus don't need a textfield and facedata is edited via the edit button
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
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: TextFormField(
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) => values[index] = value,
                  decoration: InputDecoration(
                    hintText: values[index],
                    
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget checkForFaceData() {
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

  // Set and change the icon of the FloatingActionButton
  Widget setFabIcon(){
    if(unsaved){
      return Icon(Icons.save);
    }else{
      return CircularProgressIndicator();
    }
  }
}