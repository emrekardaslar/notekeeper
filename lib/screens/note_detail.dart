import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/utils/database_helper.dart';
import 'package:notekeeper/utils/notification_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Moderate', 'Low'];
  TimeOfDay _time = TimeOfDay.now();

  DateTime _date = DateTime.now();
  NotificationHelper notificationHelper = new NotificationHelper();
  

  Future<Null> selectTime(BuildContext context) async {
    TimeOfDay _picked = await showTimePicker(
      context: context,
      initialTime: stringToTimeOfDay(note.hour),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    if (_picked != null) {
      setState(() {
        _time = _picked;
        updateHour();
      });
    }
  }

  Future<Null> selectDate(BuildContext context) async {
    final DateTime _picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(new Duration(days: 1)),
        lastDate: DateTime.now().add(new Duration(days: 732)));
    if (_picked != null) {
      setState(() {
        _date = _picked;
        updateDate();
      });
    }
  }

  Future<Null> selectNewDate(BuildContext context) async {
    DateTime _picked;
    if (stringToDateTime(note.date).isBefore(DateTime.now())) {
      _picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(new Duration(days: 1)),
        lastDate: DateTime.now().add(new Duration(days: 732)));
    }
    else {
    _picked = await showDatePicker(
        context: context,
        initialDate: stringToDateTime(note.date),
        firstDate: DateTime.now().subtract(new Duration(days: 1)),
        lastDate: DateTime.now().add(new Duration(days: 732)));
    }
    
    if (_picked != null) {
      setState(() {
        _date = _picked;
        updateDate();
      });
    }
  }

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(

        // ignore: missing_return
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                // First element: Priority Menu, Date and Time Labels
                Row(
                  children: <Widget>[
                    //Text('Priority: ',style: textStyle),
                    Expanded(
                      child: ListTile(
                        title: DropdownButton(
                            items: _priorities.map((String dropDownStringItem) {
                              return DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            style: textStyle,
                            value: getPriorityAsString(note.priority),
                            onChanged: (valueSelectedByUser) {
                              setState(() {
                                updatePriorityAsInt(valueSelectedByUser);
                              });
                            }),
                      ),
                    ),
                    Text(note.date + ' ',
                    style: textStyle,
                    ),
                    Text(note.hour,
                    style: textStyle, 
                    ),
                  ],
                ),

                // Second Element: Title, Date and Hour Buttons
                Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: titleController,
                            style: textStyle,
                            onChanged: (value) {
                              updateTitle();
                            },
                            decoration: InputDecoration(
                                labelText: 'Title',
                                labelStyle: textStyle,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Date',
                          icon: Icon(Icons.calendar_today),
                          onPressed: () {
                            if (note.date.isEmpty)
                              selectDate(context);
                            else
                              selectNewDate(context);
                          },
                        ),
                        IconButton(
                          tooltip: 'Hour',
                          icon: Icon(Icons.alarm),
                          onPressed: () {
                            selectTime(context);
                          },
                        ),
                        
                      ],
                    )),
                // Third Element: Description
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    maxLines: null,
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Fourth Element: Buttons
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              _save();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              _delete();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Moderate':
        note.priority = 2;
        break;
      case 'Low':
        note.priority = 3;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Moderate'
        break;
      case 3:
        priority = _priorities[2]; // 'Low'
        break;
      default:
        priority = _priorities[2];
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  void updateHour() {
    if (_time != null) note.hour = formatTimeOfDay(_time);
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.Hm();
    // ignore: prefer_is_not_empty
    if (!tod.isEmpty)
      return TimeOfDay.fromDateTime(format.parse(tod));
    else
      return TimeOfDay.now();
  }

  DateTime stringToDateTime(String dt) {
    DateTime tempDate = DateTime.now();
    // ignore: prefer_is_not_empty
    if (!dt.isEmpty) tempDate = new DateFormat("MMM dd, yy").parse(dt);

    return tempDate;
  }

  void updateDate() {
    if (_date != null) {
      note.date = DateFormat.yMMMd().format(_date);
    }
  }

  String formatTimeOfDay(TimeOfDay tod, {bool alwaysUse24HourFormat: true}) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.Hm();
    return format.format(dt);
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();    
    int result;

    if (note.date != null && note.hour != null)
      if (note.id != null) {
        // Case 1: Update operation
        result = await helper.updateNote(note);
        if (stringToDateTime(note.date) != DateTime.now() && 
    stringToTimeOfDay(note.hour) != TimeOfDay.now())
          notificationHelper.scheduleNotification(result,note.title, note.description, stringToDateTime(note.date),stringToTimeOfDay(note.hour));
        
      } else {
        // Case 2: Insert Operation
        result = await helper.insertNote(note);
        if (stringToDateTime(note.date) != DateTime.now() && 
    stringToTimeOfDay(note.hour) != TimeOfDay.now())
        notificationHelper.scheduleNotification(result,note.title, note.description, stringToDateTime(note.date),stringToTimeOfDay(note.hour));
      }

    if (result == 0) 
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');

  }

  void _delete() async {
    moveToLastScreen();
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id);
    await _cancelNotification(note.id);
    
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  Future<void> _cancelNotification(int id) async {
    await notificationHelper.flutterLocalNotificationsPlugin.cancel(id);
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
