import 'dart:math';

import 'package:fiea/BackgroundTasks.dart';
class Chatbot{
  
  List possibleRequests = ["wie geht es dir", "wie viel Uhr ist es", "danke", "was kannst du"];

  List answers1 = [
    "Mir geht es gut\n wie kann ich dir helfen?",
    "Naja, ich bin eine Maschine, also kann ich dir nicht sagen wie es mir geht",
    "Mir geht es hervorragend!",
    "Steht in der Gebrauchsanweisung, haha",
    "Alles paletti!"
    ];
  List answers2 = [
    "Immer gern!",
    "Dafür nicht!",
    "Ich bin immer froh, wenn ich helfen kann"
    "Kein problem",
  ];
  List answers3 = [
    "Ich kann vieles\n Am besten kann ich dir jedoch bei der Erfassung menschlicher Daten helfen!",
    "Das weiß nur der, von dem ich programmiert wurde",
    "Tja\n\n das weiß ich selbst noch nicht ganz genau\n aber mit jedem tag werde ich verbessert\n zumindest so lange Marlon noch genug Kaffee hat"
  ];
  List answers4 = [];
  List answers5 = [];
  List answers6 = [];

  Background bg = Background();

  void analyseMsg(String msg){

    for (var item in possibleRequests) {
      print(item);
      if (item == msg) {
        createResponse(msg);
      }
    }
  }

  void createResponse(String msg){
    var lol = getRandomAnswer(answers3);
    bg.speakOut(lol);
  }

  String getRandomAnswer(List answerList) {
    Random random = Random();
    var answerIndex = random.nextInt(answerList.length);
    return answerList[2];
  }
}