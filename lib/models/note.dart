class Note {

	int _id;
	String _title;
	String _description;
	String _date;
  String _hour;
	int _priority;

	Note(this._title, this._date, this._hour, this._priority, [this._description]);

	Note.withId(this._id, this._title, this._date, this._hour, this._priority, [this._description]);
  
	int get id => _id;

	String get title => _title;

	String get description => _description;

	int get priority => _priority;

	String get date => _date;

  String get hour => _hour;

	set title(String newTitle) {
		if (newTitle.length <= 255) {
			this._title = newTitle;
		}
	}

	set description(String newDescription) {
		if (newDescription.length <= 255) {
			this._description = newDescription;
		}
	}

	set priority(int newPriority) {
		if (newPriority >= 1 && newPriority <= 3) {
			this._priority = newPriority;
		}
	}

	set date(String newDate) {
		this._date = newDate;
	}

  set hour(String newHour) {
    this._hour = newHour;
  }

	// Convert a Note object into a Map object
	Map<String, dynamic> toMap() {

		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['title'] = _title;
		map['description'] = _description;
		map['priority'] = _priority;
		map['date'] = _date;
    map['hour'] = _hour;

		return map;
	}

	// Extract a Note object from a Map object
	Note.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._title = map['title'];
		this._description = map['description'];
		this._priority = map['priority'];
		this._date = map['date'];
    this._hour = map['hour'];
	}
}









