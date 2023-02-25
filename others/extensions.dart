extension IntExt on int {
  DateTime get toDate {
    return DateTime.fromMillisecondsSinceEpoch(this);
  }

  String get monthString {
    List<String> monthStrings = const [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return monthStrings[this - 1];
  }

  String get numDatetoStringDate {
    final present = toDate;
    return "${present.month.monthString} ${present.day}, ${present.year}";
  }

  String get getTimeStamp {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(this);
    Duration difference = DateTime.now().difference(dateTime);

    int minutes = difference.inMinutes;
    int hours = difference.inHours;
    if (minutes < 1) {
      return "just now";
    } else if (minutes < 60) {
      return "$minutes minute${minutes != 1 ? 's' : ''} ago";
    } else if (hours < 24) {
      return "$hours hour${hours != 1 ? 's' : ''} ago";
    }

    return numDatetoStringDate;
  }
}
