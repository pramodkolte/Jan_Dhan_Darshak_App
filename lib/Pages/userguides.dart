import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AtmHelp extends StatefulWidget {
  @override
  _AtmHelpState createState() => _AtmHelpState();
}

class _AtmHelpState extends State<AtmHelp> {
  FlutterTts flutterTts;

  List<String> steps = [
    'Step 1: Insert ATM Card.',
    'Step 2: Select Language.',
    'Step 3: Enter 4-Digit ATM Pin.',
    'Step 4: Select the type of Transaction.',
    'Step 5: Select the Type of Account.',
    'Step 6: Enter the withdrawal amount.',
    'Step 7: Collect the Cash.',
    'Step 8: If necessary, take a printed receipt.',
  ];

  Future _speak(String text) async {
    if (text.isNotEmpty && text != null) {
      var result = await flutterTts.speak(text);
      print(result);
    }
  }

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setVolume(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'How to use ATM',
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.grey[700],
        ),
      ),
      body: Column(
        children: <Widget>[
          Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: ListTile(
                title: Text(
                  'Steps to withdraw money from ATM',
                  style: TextStyle(fontSize: 19),
                ),
                trailing: IconButton(
                    icon: Icon(Icons.volume_up),
                    onPressed: () {
                      _speak('Steps to withdraw money from ATM');
                    }),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(steps[index]),
                  trailing: IconButton(
                      icon: Icon(Icons.volume_up),
                      onPressed: () {
                        _speak(steps[index]);
                      }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
