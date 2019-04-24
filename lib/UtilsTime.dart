

import 'package:intl/intl.dart';


int getDaysDifference(DateTime date1, DateTime date2) {
  if (date1.month == date2.month && date1.year == date2.year) {
    return date1.day - date2.day;
  }
  var daysOfMonth = new DateTime(date1.year, date1.month, 0).day;
  if (date1.isBefore(date2)) {
    var newYear = date1.month + 1 == 13 ? date1.year + 1 : date1.year;
    var newMonth = date1.month + 1 == 13 ? 1 : date1.month + 1;
    return -(daysOfMonth - date1.day) +
        getDaysDifference(DateTime(newYear, newMonth, 1), date2);
  }
  else {
    var newYear = date1.month - 1 == 0 ? date1.year - 1 : date1.year;
    var newMonth = date1.month - 1 == 0 ? 12 : date1.month - 1;
    return (date1.day) +
        getDaysDifference(DateTime(newYear, newMonth, daysOfMonth), date2);
  }
}


String getFormattedTime(double timestamp) {

  var date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
  var compareToDate = DateTime.now();

  if (date.millisecondsSinceEpoch < 0.0) {
    return "";
  }

  var compareToDateIn = compareToDate ?? DateTime.now();
  var isFuture = compareToDateIn.isBefore(date);

  var beforeDate = date.isBefore(compareToDateIn) ? date : compareToDateIn;
  var afterDate = beforeDate == date ? compareToDateIn : date;

  var daysDiff = getDaysDifference(afterDate, beforeDate);

  if (beforeDate.year < afterDate.year) {
    String format = DateFormat.yMMMMd().add_jm().format(date);
    return format;
  }
  if (daysDiff > 6) {
    String format = DateFormat.MMMMd().add_jm().format(date);
    return format;
  }
// six days or sooner
  if (daysDiff > 1) {
    var format = DateFormat.EEEE().add_jm().format(date);
    return "${isFuture ? "" : ""} $format";
  }
// yest or sooner
  if (daysDiff > 0) {
    var hourFormat = DateFormat.jm().format(date);
    return "${isFuture ? "Tomorrow" : "Yesterday"} $hourFormat";
  }
// today
  var hourFormat = DateFormat.jm().format(date);
  return "Today $hourFormat";
}