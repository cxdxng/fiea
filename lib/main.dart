import 'dart:ui';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:eventify/eventify.dart';
import 'package:fiea/Chatbot.dart';
import 'package:fiea/DatabaseHelper.dart';
import 'package:fiea/DatabaseViewer.dart';
import 'package:fiea/EditInfo.dart';
import 'package:fiea/Overview.dart';
import 'package:fiea/TestUI.dart';
import 'package:fiea/personInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'BackgroundTasks.dart';
import 'DatabaseViewer.dart';

void main() => runApp(MaterialApp(

  // Declare routes for changing screens
  initialRoute: '/',
  routes: {
    '/': (context) => SpeechScreen(),
    '/test': (context) => TTS(),
    '/dbviewer': (context) => DbViewer(),
    '/personCard': (context) => PersonCard(),
    '/editInfo': (context) => EditPersonInfo(),
    '/overview': (context) => FunctionOverview(),
  },
));

class SpeechScreen extends StatefulWidget {

  // Create EventEmitter to change speech animation when TTS is finished
  static EventEmitter ttsEmitter = new EventEmitter();

  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {

  // Create necessary Objects
  stt.SpeechToText _speech;
  Background bg = Background();

  // Create necessary Variables for STT
  bool _isListening = false;
  String _stateBusy = "F.I.E.A hört zu";
  String _stateReady = "F.I.E.A Bereit";
  String _sttState = "F.I.E.A Bereit";

  // UI prediciton text
  String _text = "Sag etwas...";

  // Text for errors
  String errorText = "Fehler, bitte versuche es erneut";
  // Create List of Strings to store the message that has been splitted
  List<String> split;

  //Create Requestcodes for result of STT
  int currentRequestCode = 100;
  static const int normalRequest = 100;
  static const int newEntry = 101;
  static const int updateEntry = 102;
  static const int deleteEntry = 103;
  static const int makeCall = 104;

  bool isFinished = true;

  // Create Color variables for UI theme of the App
  Color fabColor = Color(0xff080e2c);

  // Method to check if it it the first time the app is launched
  void checkFirstSeen() async {
    // Look for a bool in the shared prefrences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = await (prefs.getBool('seen') ?? false);
    // If it is true it means the app has already been launched once so
    // the tts greets the user with his/her name
    if (_seen) {
      // Get data from Database
      var dataList = await DatabaseHelper.instance.queryName();
      // Extract username and speak out the greeting
      String username = dataList[0]["name"];
      bg.speakOut("Wilkommen $username\nWie kann ich dir helfen");
    }
    // However if it is the first launch, the user will get a 
    // little introduction and gets prompted to make a new entry
    // with his data
    else {
      DatabaseHelper.instance.deleteTable();
      // Change the bool to true so at next launch this
      // will not get executed anymore
      prefs.setBool('seen', true);
      // Set currentRequestCode to 101 so that the user does not
      // need to tell the assistant an action first
      currentRequestCode = 101;
      // Speakout the introducion
      Background().speakOut("Hallo\n und Wilkommen zu deinem persönlichen Assistenten\nIch wurde dafür ausgelegt, bei der verwaltung von Menschlichen Daten zu helfen\nZu aller erst solltest du dich selbst in die Datenbank eintragen\nDrücke dazu einfach den Mikrofon button und nenne mir danach deinen Vornamen und dein Geburtsjahr!");
    }
  }

  // Create initState to define STT Object
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText(); 
    // Check for first launch
    checkFirstSeen();
  }
  
  @override
  Widget build(BuildContext context) {
    // Create listener to check if tts is speaking or not
    // and change isFinished accordingly
    SpeechScreen.ttsEmitter.on("Finished", null, (ev, context) {
      setState(() {
        isFinished = true;
      });
    });
    SpeechScreen.ttsEmitter.on("SPEAKING", null, (ev, context) {
      setState(() {
        isFinished = false;
      });
    });
    // Create the UI
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          animate: _isListening,
          glowColor: Color(0xff44D6E9),
          endRadius: 75,
          duration: Duration(milliseconds: 2000),
          repeatPauseDuration: Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton(
            onPressed: () {
              // Check if TTS has finished speaking
              if (isFinished) {
                // If so then listen to the user
                listen();
              }            
            },
            backgroundColor: fabColor,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
        ),

        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              // Set animation depending on isFinished value
              image: isFinished ? AssetImage("assets/aiIdle.gif"):AssetImage("assets/aiTalking.gif"),
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Center(
                  child: Text(
                    _sttState,
                    style: TextStyle(
                      fontSize: 45,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 150),
                  child: Text(
                    _text,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Listen for Status from STT
  void statusListener(String status) {
    // Set lastStatus to current Status so resultListener
    // knows when STT is not listening anymore
    setState(() {
      if (status == "notListening") {
        _sttState = _stateReady;
        listen();
      }else{
        _sttState = _stateBusy;
      }
    });
  }

  void resultListener(SpeechRecognitionResult result) async {
    // Get msg from resultListener
    String msg = result.recognizedWords;
    // Set the msg to _text to display it to the user
    setState(() {
      _text = msg;
    });
    // Handle results
   
    // Check if msg is empty and if STT is ready again
    if(msg != "" && _sttState == _stateReady){        
      // Check the requestCode
      switch(currentRequestCode){
        case normalRequest:{ // 100

          // Check the msg for spectific actions
          switch(msg){
            case "neuer Eintrag":{
              // Let the user know what he needs to say
              bg.speakOut("Name und Jahr bitte");
              //change the current request code to the necessary one
              currentRequestCode = newEntry;   
              
            }
            break;
            case "Eintrag updaten":{
              // Let the user know what he needs to say
              bg.speakOut("Kennung, Attribut und Wert bitte");
              //change the current request code to the necessary one
              currentRequestCode = updateEntry;
            }
            break;
            case "Eintrag löschen":{
              // Let the user know what he needs to say
              bg.speakOut("Kennung bitte");
              //change the current request code to the necessary one
              currentRequestCode = deleteEntry;     
                
            }
            break;
            case "Anruf tätigen":{
              // Let the user know what he needs to say
              bg.speakOut("Welche Kennung möchtest du anrufen?");
              // Change the current request code to the necessary one
              currentRequestCode = makeCall;
            }
            break;
            case "zeig mir was du kannst":{
              // Give the user feedback
              bg.speakOut("Das hier sind meine Funktionen");
              Navigator.pushNamed(context, "/overview");
            }
            break;
            default:{
              // Execute handleNormalResult and pass the msg
              bool performedAction = await Background().handleNormalResult(msg, context);
              // If handleNormalResult returns false then the action
              // is not known and so the result will be passed to the Chatbot
              if (!performedAction) {
                bool valid = await Chatbot().createResponse(msg);
                // If Chatbot also returns false, the action is not known and so
                // an error ill be reptoted to the user
                if(!valid){
                  bg.speakOut("Tut mir leid, das habe ich nicht verstanden");
                }
              }
            }
          }
        }
        break;
        case newEntry:{ // 101
          // Change the current request code to normal request
          // since information has already been collected
          currentRequestCode = normalRequest;
          // Split the result at spaces
          split = bg.splitResult(msg);
          // Try executing the method in BackgroundTask and catching error if one occurs
          try{
            bg.insert(split[0], int.parse(split[1]));
          }catch(e){
            bg.speakOut(errorText);
          }
        }
        break;
        case updateEntry:{ // 102
          // Change the current request code to normal request
          // since information has already been collected
          currentRequestCode = normalRequest;
          // Split the result at spaces
          split = bg.splitResult(msg);
          // Try executing the method in BackgroundTask and catching error if one occurs
          try{
            // using second index for id here because 
            // of number formatting from STT you need to say
            // "Kennung" before the id because otherwise
            // the stt returns the number in words
            int success = await bg.update(int.parse(split[1]), split[2], split[3]);
            // Let the user know whether action was successful or not
            if(success != 1){
              bg.speakOut(errorText);
            }
          }catch(FormatException){
            bg.speakOut(errorText);
          }
          
        }
        break;
        case deleteEntry:{ // 103
          // Change the current request code to normal request
          // since information has already been collected
          currentRequestCode = normalRequest;
          // Split the result at spaces
          split = bg.splitResult(msg);
          // Try executing the method in BackgroundTask and catching error if one occurs
          try{
            bg.delete(int.parse(split[1]));
          }catch(FormatException){
            bg.speakOut(errorText);
          }
        }
        break;
        case makeCall:{ // 104
          // Change the current request code to normal request
          // since information has already been collected
          currentRequestCode = normalRequest;
          // Split the result at spaces
          split = bg.splitResult(msg);
          // Try executing the method in BackgroundTask and catching error if one occurs
          try{
            //bg.speakOut("Okay");
            bg.callID(split[1]);
          }catch(Exeption){
            bg.speakOut(errorText);
          }
        }
        break;
      }
      // Now at recall of resultListener, the requestcode check at the beginning
      // will trigger and run the correct method linked to the request codes
    }
    
    



  }

  // Listen to the user
  void listen() async {
    if (!_isListening) {
      // Initialize STT
      bool available = await _speech.initialize(
        // Set status and error Listener
        onStatus: statusListener,
        onError: (val) => print("onError: $val"),
      );

      // If STT got initialzed successfully 
      // then listen to the user 
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          // Set a result Listener
          onResult: resultListener,
        );
      } 
    }else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }
}