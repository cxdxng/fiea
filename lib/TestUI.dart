import 'dart:async';
import 'dart:convert';
import 'package:android_notification_listener2/android_notification_listener2.dart';
import 'package:fiea/BackgroundTasks.dart';
import 'package:flutter/material.dart';


class TTS extends StatefulWidget {
  @override
  _TTSSTate createState() => _TTSSTate();
}

class _TTSSTate extends State<TTS> {

  

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  AndroidNotificationListener _notifications;
  StreamSubscription<NotificationEventV2> _subscription;

  Future<void> initPlatformState() async {
    await startListening();
    print("STARTED");
    
  }

  Future<void> stopPlatformState() async {
    await stopListening();
  }

  void onData(NotificationEventV2 event) {

    
    print(event.packageMessage);
    Background().speakOut("Nachicht von ${event.packageText}: ${event.packageMessage}");
  }

  void startListening() {
    _notifications = new AndroidNotificationListener();
    try {
      _subscription = _notifications.notificationStream.listen(onData, cancelOnError: true);
      print("joj");
    } on NotificationExceptionV2 catch (exception) {
      print(exception);
    }
  }

  void stopListening() async{
  
    await _subscription.cancel();
    
  }
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            RaisedButton(onPressed: () => stopListening(), child: Text("data"),)
          ],
        ),
      ),
    );
  }
}