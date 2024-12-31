import 'Location.dart';

class Event {
  final String id;
  final String title;
  final DateTime dateTime;
  final Location location;

  Event(
      {required this.id,
      required this.title,
      required this.dateTime,
      required this.location});

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'location': location.toJson(),
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      dateTime: DateTime.parse(json['dateTime']),
      location: Location.fromJson(json['location']),
    );
  }

  @override
  String toString() {
    return 'ExamEvent(id: $id, title: $title, dateTime: $dateTime, location: $location)';
  }
}
