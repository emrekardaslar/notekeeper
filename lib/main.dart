import 'package:flutter/material.dart';
import 'package:notekeeper/screens/note_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  hexColor(String colorhexcode) {
    String colorNew = '0xff' + colorhexcode;
    colorNew = colorNew.replaceAll('#', '');
    return colorNew;
  }

  @override
  Widget build (BuildContext context) {
    return MaterialApp(
      title: 'NoteKeeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: NoteList(),
      //home: LocalNotificationScreen(),
    );
  }
}

