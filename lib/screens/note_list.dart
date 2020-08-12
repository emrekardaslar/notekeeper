import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/screens/note_detail.dart';
import 'package:notekeeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';


class NoteList extends StatefulWidget {

	@override
  State<StatefulWidget> createState() {

    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {

	DatabaseHelper databaseHelper = DatabaseHelper();
	List<Note> noteList;
	int count = 0;

	@override
  Widget build(BuildContext context) {

		if (noteList == null) {
			noteList = List<Note>();
			updateListView();
		}

    return Scaffold(
      //backgroundColor: const Color(0xFFEFEFEF),
	    appBar: AppBar(
		    title: Text('Notes'),
	    ),

	    body: getNoteListView(),

	    floatingActionButton: FloatingActionButton(
		    onPressed: () {
		      navigateToDetail(Note('', '', '', 2), 'Add Note');
		    },

		    tooltip: 'Add Note',

		    child: Icon(Icons.add),

	    ),
    );
  }

  ListView getNoteListView() {

		TextStyle titleStyle = Theme.of(context).textTheme.subhead;

		return ListView.builder(
			itemCount: count,
			itemBuilder: (BuildContext context, int position) {
				return Card(
					color: Colors.white,
					elevation: 2.0,
					child: ListTile(

						leading: CircleAvatar(
							backgroundColor: getPriorityColor(this.noteList[position].priority),
							child: Icon(Icons.keyboard_arrow_right),
						),

						title: Text(this.noteList[position].title, style: titleStyle,),

						subtitle: Text(this.noteList[position].date + " " + this.noteList[position].hour),

						trailing: GestureDetector(
							child: Icon(Icons.delete, color: Colors.grey,),
							onTap: () {
								_delete(context, noteList[position]);
							},
						),


						onTap: () {
							navigateToDetail(this.noteList[position],'Edit Note');
						},

					),
				);
			},
		);
  }

  // Returns the priority color
	Color getPriorityColor(int priority) {
		switch (priority) {
			case 1:
				return Colors.red;
				break;
			case 2:
				return Colors.orange;
				break;
      case 3:
        return Colors.yellow;
        break;

			default:
				return Colors.yellow;
		}
	}

	void _delete(BuildContext context, Note note) async {

		int result = await databaseHelper.deleteNote(note.id);
		if (result != 0) {
			_showSnackBar(context, 'Note Deleted Successfully');
			updateListView();
		}
	}

	void _showSnackBar(BuildContext context, String message) {

		final snackBar = SnackBar(content: Text(message));
		Scaffold.of(context).showSnackBar(snackBar);
	}

  void navigateToDetail(Note note, String title) async {
	  bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
		  return NoteDetail(note, title);
	  }));

	  if (result == true) {
	  	updateListView();
	  }
  }

  void updateListView() {

		final Future<Database> dbFuture = databaseHelper.initializeDatabase();
		dbFuture.then((database) {

			Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
			noteListFuture.then((noteList) {
				setState(() {
				  this.noteList = noteList;
				  this.count = noteList.length;
				});
			});
		});
  }

  List<DateTime> prepareNotifications(List<Note> noteList, int size) {
    List<DateTime> datesToSchedule = new List<DateTime>();
    for (int i=0; i<size;i++) {
      if (noteList[i].date != null)
        datesToSchedule.add(stringToDateTime(noteList[i].date)); 
    }
    return datesToSchedule;
  }

   DateTime stringToDateTime(String dateTime) {
    DateTime tempDate = DateTime.now();
    // ignore: prefer_is_not_empty
    if (!dateTime.isEmpty) tempDate = new DateFormat("MMM dd, yy").parse(dateTime);

    return tempDate;
  }

  String hourFormat(TimeOfDay timeOfDay) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat.Hm();
    return format.format(dt);
  }


}






