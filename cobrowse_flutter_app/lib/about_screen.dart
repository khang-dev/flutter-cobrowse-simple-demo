import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text(
            'Issues when doing Cobrowse remote session',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(
            height: 16,
          ),
          Text('1. Agent can not type in all the TextFields (iOS)'),
          SizedBox(
            height: 16,
          ),
          Text('2. Agent can not do vertical and horizontal scrolling (iOS + Android)'),
          SizedBox(
            height: 16,
          ),
          Text('3. Very often the frames are not updated to the Agent view when navigating between screens (Android)'),
        ]),
      )),
    );
  }
}
