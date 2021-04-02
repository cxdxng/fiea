import 'package:flutter/material.dart';
import 'package:wifi/wifi.dart';
import 'package:ping_discover_network/ping_discover_network.dart';

class NetworkScanner extends StatefulWidget {
  @override
  _NetworkScannerState createState() => _NetworkScannerState();
}

class _NetworkScannerState extends State<NetworkScanner> {
  bool isDataReady = false;
  List<String> listOfIp = [];
  Color darkBackground = Color(0xff1e1e2c);

  void fetchData()async{
    print("running");
    final String ip = await Wifi.ip;
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final int port = 80;

    final stream = NetworkAnalyzer.discover(subnet, port, timeout: Duration(milliseconds: 100));
    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        listOfIp.add(addr.ip);
        print('Found device: ${addr.ip}');
      }
    }).onDone(() {
      setState(() {
        isDataReady = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: darkBackground,
        body: Column(
          children: [
            isDataReady?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "IP Adressen",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.w900
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: ListView.builder(
                    itemCount: listOfIp.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index){
                      return Card(
                        color: Colors.blueAccent,
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            listOfIp[index],
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ):
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  Text("Scanne Netzwerk...", 
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.w900
                    ),
                  ),
                  SizedBox(height: 20,),
                  CircularProgressIndicator(),
                ],
              )
            )
            
          ],
        ),
      ),
    );
  }
}