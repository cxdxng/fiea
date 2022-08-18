import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class CovidInfo extends StatefulWidget {
  @override
  _CovidInfoState createState() => _CovidInfoState();
}

class _CovidInfoState extends State<CovidInfo> {
  
  // Bool to change UI if data is ready
  bool isDataReady = false;

  // Create List for ags   Köln     Lohmar    Bonn    FFM      Hannover Freiburg München
  List<String> cityList = ["05315", "05382", "05314", "06412", "03241", "08311", "09162"];

  // Create List of maps to store individual city data
  List<Map<dynamic, dynamic>> extractedData = [];
  Map timeData;

  @override
  void initState() {
    super.initState();
    // Fetch the data from api
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    // Create the UI
    
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            makeTop(),
            SizedBox(height: 10),

            isDataReady ?
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: cityList.length,
                itemBuilder: (BuildContext context, int index){
                  return Center(
                    child: Column(
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.zero,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Übersicht (${extractedData[index]["name"]})",
                                        style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                createTextWithIcon(Icons.trending_up_sharp,
                                    "7-tage Inzidenz: ${double.parse(extractedData[index]["weekIncidence"].toString()).toStringAsFixed(2)}"),
                                Divider(
                                  height: 40,
                                  color: Colors.black,
                                  thickness: 1,
                                ),

                                createTextWithIcon(Icons.masks_outlined,
                                    "Infektionen: ${extractedData[index]["cases"]}"),

                                Divider(
                                  height: 40,
                                  color: Colors.black,
                                  thickness: 1,
                                ),
                                createTextWithImageIcon("assets/death.png",
                                    "Todesfälle: ${extractedData[index]["deaths"]}"),

                                // Other Widgets here
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20)
                      ],
                    ),
                  );
                },
              ),
            )

            // If data is not ready yet
            // the CircularProgressIndicator will
            // show as long as data is beeing fetched
            :CircularProgressIndicator()

          ],
        ),
      ),
    );
  }

  void fetchData() async {
    // Fetch the data one by one and store data in extractedData Map
    for (var i = 0; i < cityList.length; i++) {
      // Get data for each city from api and
      // store them in extractedData Map
      Response response = await http.get(Uri.https("api.corona-zahlen.org", "/districts/${cityList[i]}"));
      Map<String, dynamic> jsonResponse = await jsonDecode(response.body);
      Map mainData = jsonResponse["data"];
      extractedData.add(mainData[cityList[i]]);

    }
    
    // State that data is ready for display
    setState(() {
      isDataReady = true;
    });
    
  }

  // Returns the Title and exit button
  Widget makeTop(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5,5,0,0),
      child: Stack(
        children: [
          InkWell(
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 30,
            ),
            onTap: (){Navigator.pop(context);}
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              "Aktuelle Situation",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createTextWithIcon(IconData icon, String text) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Icon(
            icon,
            color: Colors.black,
          ),
        ),
        Text(
          text,
          style: TextStyle(color: Colors.black, fontSize: 22),
        )
      ],
    );
  }

  Widget createTextWithImageIcon(String icon, String text) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: ImageIcon(
            AssetImage(icon),
            color: Colors.black,
          ),
        ),
        Text(
          text,
          style: TextStyle(color: Colors.black, fontSize: 22),
        )
      ],
    );
  }
}