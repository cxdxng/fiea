import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class CovidInfo extends StatefulWidget {
  @override
  _CovidInfoState createState() => _CovidInfoState();
}

class _CovidInfoState extends State<CovidInfo> {
  bool isDataReady = false;

  List<String> cityList = ["05315", "05382"];

  List<dynamic> cityMap;

  Map extractedData;
  Map timeData;

  @override
  void initState() {
    super.initState();
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
            
            isDataReady ?

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: 1,
                itemBuilder: (BuildContext context, int index){
                  return Center(
                    child: Card(
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
                                    "Übersicht (${extractedData["name"]})",
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
                                "7-tage Inzidenz: ${double.parse(extractedData["weekIncidence"].toString()).toStringAsFixed(2)}"),
                            Divider(
                              height: 40,
                              color: Colors.black,
                              thickness: 1,
                            ),

                            createTextWithIcon(Icons.masks_outlined,
                                "Infektionen: ${extractedData["cases"]}"),

                            Divider(
                              height: 40,
                              color: Colors.black,
                              thickness: 1,
                            ),
                            createTextWithImageIcon("assets/death.png",
                                "Todesfälle: ${extractedData["deaths"]}"),

                            // Other Widgets here
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )

            :CircularProgressIndicator()

          ],
        ),
      ),
    );
  }

  void fetchData() async {

    
      
    Response response = await http.get(Uri.https("api.corona-zahlen.org", "/districts/${cityList[0]}"));
    Map<String, dynamic> jsonResponse = await jsonDecode(response.body);

    Map mainData = jsonResponse["data"];
    extractedData = mainData[cityList[0]];

    setState(() {
      isDataReady = true;
    });
    
  }

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

  Widget makeCard(){
    
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