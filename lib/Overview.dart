import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
class FunctionOverview extends StatelessWidget {

  // Create color variables for UI
  Color darkBackground = Color(0xff1e1e2c);
  Color blueAccent = Color(0xff33e1ed);

  // Create Lists to store all actions and their corrisponding icons so that
  // same index in Listview.builder can be used to get the action and the icon
  List<String> actions = ['"Neuer Eintrag"','"Eintrag updaten"','"Gesicht hinzufügen"','"Eintrag löschen"','"Datenbank anzeigen"','"Datenbank löschen"','"info Kennung ..."','"... suchen"','"Anruf tätigen"','"Zeig mir was du kannst"','"Wie viel Uhr ist es?"',];
  List<IconData> icons = [Icons.add_circle, Icons.update, Icons.face, Icons.delete, Icons.table_rows_rounded, Icons.delete, Icons.info, Icons.filter_alt_rounded, Icons.call, Icons.featured_play_list, Icons.timelapse];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Stack(
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
                        Text(
                          "Meine Funktionen:",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(
                          height: 50,
                          thickness: 2,
                          color: darkBackground,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: actions.length,
                            itemBuilder: (BuildContext context, int index){
                              return Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Icon(icons[index]),
                                    ),
                                    Text(
                                      actions[index],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    
                                  ],
                                ),
                              );
                            },
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
              onTap:() => Navigator.pop(context)
            ),
          ],
        ),
      ),
    );
  }
}