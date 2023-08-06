import 'package:chat_app/data/models/message_data.dart';
import 'package:intl/intl.dart';

class Validators {
  Validators._();

  // in audio_message
  static String formatTime(int seconds) {
    // return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');   // result is to return 00:00:00

    return '${(Duration(seconds: seconds)).toString().split(':').sublist(1).join(':')}' // result is to return 00:00
        .split('.')[0];
  }

  // in text_message
  static bool isUrl(String text) {
    // Regular expression pattern to match URLs
    // This pattern matches most common URLs, but may not match all possible URLs
    final urlPattern = RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+[/#?]?.*$',
        caseSensitive: false, multiLine: false);

    return urlPattern.hasMatch(text);
  }

  // in video_message
  static bool isYoutubeUrl(String url) {
    // Regular expression to match YouTube video URLs

    RegExp youtubeUrlPattern = RegExp(
        r'^https?:\/\/(www\.)?youtube\.com\/watch\?v=[\w-]{11}.*|^https?:\/\/(www\.)?youtu\.be\/[\w-]{11}.*');

    // Test the input URL against the regular expression

    return youtubeUrlPattern.hasMatch(url);
  }

  static String? validatePhone(String? phone) {
    if (phone!.isEmpty) {
      return "$phone can be empty";
    } else if (phone.length != 10) {
      return "Enter valid number";
    } else {
      return null;
    }
  }

  static String? validateEmail(String? email) {
    if (email!.isEmpty) {
      return "$email can be empty";
    } else if (email.length != 10) {
      return "Enter valid number";
    } else {
      return null;
    }
  }

  static bool compareDate(DateTime dateTime) {
    if (dateTime.day == DateTime.now().day &&
        dateTime.month == DateTime.now().month &&
        dateTime.year == DateTime.now().year) {
      return true;
    }
    return false;
  }

  static bool compareHour(DateTime dateTime) {
    if (dateTime.day == DateTime.now().day &&
        dateTime.month == DateTime.now().month &&
        dateTime.year == DateTime.now().year &&
        dateTime.hour == DateTime.now().hour) {
      return true;
    }
    return false;
  }

  static bool isSVG(String link) {
    if (link.contains(".svg")) {
      return true;
    }
    return false;
  }

  static int differenceHours(Message message) {
    return DateTime.now().difference(message.dateTime!.toDate()).inHours;
  }

  static bool isSameWeek(DateTime time1, DateTime time2) {
    int year1 = time1.year;
    int year2 = time2.year;
    int week1 = time1.weekday == DateTime.sunday
        ? time1.difference(DateTime(time1.year, 1, 1)).inDays ~/ 7
        : (time1.difference(DateTime(time1.year, 1, 1)).inDays ~/ 7) + 1;
    int week2 = time2.weekday == DateTime.sunday
        ? time2.difference(DateTime(time2.year, 1, 1)).inDays ~/ 7
        : (time2.difference(DateTime(time2.year, 1, 1)).inDays ~/ 7) + 1;
    return week2 == week1 && year2 == year1;
  }
}
