import 'dart:async';

import 'package:android_notification_listener2/android_notification_listener2.dart';
import 'package:eventify/eventify.dart';
import 'package:fiea/BackgroundTasks.dart';

class NotifManager{

  AndroidNotificationListener _notifications;
  StreamSubscription<NotificationEventV2> _subscription;
  static EventEmitter carEmitter = new EventEmitter();

  Future<void> initPlatformState() async {

    // Check if car mode is supposed to start or 
    // to end
    carEmitter.on("start", null, (ev, context) {
      startListening();
    });

    carEmitter.on("end", null, (ev, context) {
      stopListening();
    });
    
    
  }
  // SpeakOut the Notification to the user
  void onData(NotificationEventV2 event) {
    Background().speakOut("Nachicht von ${event.packageText}: ${event.packageMessage}");
  }

  // Start listening for Notifications
  void startListening() {
    _notifications = new AndroidNotificationListener();
    try {
      _subscription = _notifications.notificationStream.listen(onData, cancelOnError: true);
      
    } on NotificationExceptionV2 catch (exception) {
      print(exception);
    }
  }

  // Stop listening for Notifications
  void stopListening() async{
    _subscription.pause();
    
  }



}