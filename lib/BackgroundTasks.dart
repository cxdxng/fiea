class Background{

  void handleResults(String msg)async{

    if (msg == "datenbank anzeigen"){
      print("DATENBANK");
    }
    //Add a facedata to ID in database
    else if (msg.contains("gesicht hinzufügen")){
      print("ADD FACE");
    }
    //Delete facedata from database
    else if (msg.contains("gesicht löschen")){
      print("DELETE FACE");
    }
    //Output all data from requested ID
    else if (msg.contains("info kennung")){
      print("ID DATA");
    }

    else if (msg == "herunterfahren"){
      print("SHUTDOWN");
    }

  }

  void speakOut(String msg){

  }

}

class HumanData{
  final int id;
  final String name;
  final int birthyear;
  final String facedata;


  HumanData({this.id, this.name, this.birthyear, this.facedata});

}