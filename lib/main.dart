import 'package:flutter/material.dart';
import 'package:notekeeper/screens/note_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build (BuildContext context) {
    return MaterialApp(
      title: 'NoteKeeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: NoteList(),
    );
  }
}

//to build: flutter build apk --release --split-per-abi --no-shrink