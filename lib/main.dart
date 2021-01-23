import 'dart:ui';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:fiea/DatabaseViewer.dart';
import 'package:fiea/EditInfo.dart';
import 'package:fiea/TestUI.dart';
import 'package:fiea/personInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'BackgroundTasks.dart';
import 'DatabaseViewer.dart';

void main() => runApp(MaterialApp(

  // Declare routes for changing Screens
  initialRoute: '/',
  routes: {
    '/': (context) => SpeechScreen(),
    '/test': (context) => TTS(),
    '/dbviewer': (context) => DbViewer(),
    '/personCard': (context) => PersonCard(),
    '/editInfo': (context) => EditPersonInfo(),
  },
));

class SpeechScreen extends StatefulWidget {

  // Create local bool that stores if TTS 
  // is finished talking or not
  static bool isFinished = true;

  
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {

  // Create necessary Objects
  stt.SpeechToText _speech;
  var bg = Background();

  TextEditingController controller = TextEditingController();

  // Create necessary Variables for STT
  var _isListening = false;
  var _stateBusy = "F.I.E.A hört zu";
  var _stateReady = "F.I.E.A Bereit";
  var _sttState = "F.I.E.A Bereit";

  // Ui Text
  var _text = "Sag etwas...";

  // text for errors
  var errorText = "Fehler, bitte versuche es erneut";
  List<String> split;

  //Create Requestcodes for result of STT
  int currentRequestCode = 100;
  static const int normalRequest = 100;
  static const int newEntry = 101;
  static const int updateEntry = 102;
  static const int deleteEntry = 103;
  static const int makeCall = 104;

  /* Request codes
  100 = normal Request
  101 = new entry
  102 = update entry
  103 = delete entry
  104 = make call
   */

  // Create Color variables for UI theme of the App
  var blueAccent = Color(0xff33e1ed);
  var darkBackground = Color(0xff1e1e2c);
  Color fabColor = Color(0xff080e2c);

  //Create initState to define STT Object
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }
  
  @override
  Widget build(BuildContext context) {
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
              if (SpeechScreen.isFinished) {
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
              image: AssetImage("assets/lol.gif"),
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
                reverse: true,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 150),
                  child: Text(
                    _text,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      //fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              /* RaisedButton(
                onPressed: (){bg.handleNormalResult("Datenbank anzeigen", context);},
                child: Text("Datenbank Anzeigen"),
              ), */
              
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

  void resultListener(SpeechRecognitionResult result) {
    // Get msg from resultListener
    var msg = result.recognizedWords;
    
    // Set the msg to _text to display it to the user
    setState(() {
      _text = msg;
    });
    // Handle results
    setState(() async{
      // Check if msg is empty and if STT is ready again
      if(msg != "" && _sttState == _stateReady){
        print("lul");
        // Set isFinished to false so that there can no longer be
        // speech input from the user untill result has been fully processed
        SpeechScreen.isFinished = false;
        
        
        // Check the requestCode
        switch(currentRequestCode){
          case normalRequest:{ // 100
            // Execute handleNormalResult and pass the msg
            bool performedAction = await Background().handleNormalResult(msg, context);
            // If handleNormalResult returns null then the action
            // is not known and so TTS reports an error to the user
            
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
              int success = bg.update(int.parse(split[1]), split[2], split[3]) as int;
              // Let the user know whether action was successful or not
              if(success == 1){
                bg.speakOut("Änderungen erfolgreich übernommen");
              }else{
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
              bg.callID(msg);
            }catch(Exeption){
              bg.speakOut(errorText);
            }
          }
          break;
        }



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
          case "anruf tätigen":{
            // Let the user know what he needs to say
            bg.speakOut("Welche Kennung möchten Sie anrufen?");
            //change the current request code to the necessary one
            currentRequestCode = makeCall;
          }
        }
        
        
        

        // Now at recall of resultListener, the requestcode check at teh beginning
        // will trigger and run the correct method linked to the request codes
      }
    });
  }

  // Listen to the user
  void listen() async {
    if (!_isListening) {
      // Initialize STT
      var available = await _speech.initialize(
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