import 'dart:math';
import 'package:fiea/BackgroundTasks.dart';

class Chatbot {
  List possibleRequests = [
    "wie geht es dir",
    "danke",
    "was kannst du",
    "wie viel Uhr ist es",
    "wie macht ein Affe"
  ];

  List howAreU = [
    "Mir geht es gut\n wie kann ich dir helfen?",
    "Naja, ich bin eine Maschine, also kann ich dir nicht sagen wie es mir geht",
    "Mir geht es hervorragend!",
    "Steht in der Gebrauchsanweisung, haha",
    "Alles paletti!"
  ];
  List thanks = [
    "Immer gern!",
    "Dafür nicht!",
    "Ich bin immer froh, wenn ich helfen kann",
    "Kein problem",
  ];
  List whatCanYouDo = [
    "Ich kann vieles\n Am besten kann ich dir jedoch bei der Erfassung menschlicher Daten helfen!",
    "Das weiß nur der, von dem ich programmiert wurde",
    "Tja\n\n das weiß ich selbst noch nicht ganz genau\n aber mit jedem tag werde ich verbessert\n zumindest so lange Marlon noch genug Kaffee hat"
  ];

  Background bg = Background();

  Future<bool> createResponse(String msg) async {
    for (int i = 0; i < possibleRequests.length; i++) {
      if (msg == possibleRequests[i]) {
        switch (i) {
          case 0:{
            bg.speakOut(getRandomAnswer(howAreU));
            return true;
          }
          break;
          case 1:{
            bg.speakOut(getRandomAnswer(thanks));
            return true;
          }
          break;
          case 2:{
            bg.speakOut(getRandomAnswer(whatCanYouDo));
            return true;
          }
          break;
          case 3:{
            DateTime now = new DateTime.now();
            bg.speakOut("Es ist ${now.hour}:${now.minute}");
            return true;
          }
          break;
          case 4:{
            bg.speakOut("Schiiiiiiiiiiisch");
            return true;
          }
          break;
          default:{
            return false;
          }
        }
      }
    }
    return false;
  }

  String getRandomAnswer(List answerList) {
    Random random = Random();
    int answerIndex = random.nextInt(answerList.length);
    return answerList[answerIndex];
  }
}
