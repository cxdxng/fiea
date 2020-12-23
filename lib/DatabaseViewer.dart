import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DbViewer extends StatelessWidget {

  var blueAccent = Color(0xff33e1ed);
  var darkBackground = Color(0xff1e1e2c);
  final List<Map<String, dynamic>> entries;
  DbViewer({Key key, this.entries}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    print("From DatabaseViewer: $entries");
    return SafeArea(
      child: Scaffold(
        backgroundColor: darkBackground,
        floatingActionButton: FloatingActionButton(
          onPressed: () {Navigator.pop(context);},
          backgroundColor: Colors.white,
          child: Text("X", style: TextStyle(color: Colors.black),),
        ),
        body: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(35,25,35,25),
                //itemCount: entries.length,
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Card(
                      color: Colors.blueAccent,
                      child: Container(
                        width: 100,
                        height: 300,
                        child: Column(
                          children: [
                            const ListTile(
                              title: Padding(
                                padding: EdgeInsets.fromLTRB(0,10,0,10),
                                child: Text(
                                  'Marlon, 2003',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                              ),
                              subtitle: Text(
                                'Music by Julie Gable. Lyrics by Sidney Stein.'
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              ),
      ),
    );
  }
}