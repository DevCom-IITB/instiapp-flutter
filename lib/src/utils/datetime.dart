class DateTimeUtil {
  static String getDate(String dtStart) {
    var date = DateTime.parse(dtStart);
    var now = DateTime.now();
    Duration diff = now.difference(date);

    int seconds = diff.inSeconds;
    int minutes = diff.inMinutes;
    int hours = diff.inHours;
    int days = diff.inDays;

    if (seconds <= 0) {
      return "Now";
    } else if (seconds < 60 && seconds > 1) {
      return "$seconds seconds ago";
    } else if (minutes == 1) {
      return "1 minute ago";
    } else if (minutes < 60 && minutes > 1) {
      return "$minutes minutes ago";
    } else if (hours == 1) {
      return "An hour ago";
    } else if (hours < 24 && hours > 1) {
      return "$hours hours ago";
    } else if (days == 0)
      return "Today";
    else if (days == 1)
      return "Yesterday";
    else if (days < 14)
      return "$days days ago";
    else if (days < 30) if ((days ~/ 7) == 1)
      return "A week ago";
    else
      return "${(days ~/ 7)} weeks ago";
    else if (days < 365) if ((days ~/ 30) == 1)
      return "A month ago";
    else
      return "${(days ~/ 30)} months ago";
    else if ((days ~/ 365) == 1)
      return "A year ago";
    else
      return "${(days ~/ 365)} years ago";
  }
}
