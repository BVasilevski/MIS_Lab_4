import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/Event.dart';

class EventProvider with ChangeNotifier {
  Map<DateTime, List<Event>> _events = {};

  Map<DateTime, List<Event>> get events => _events;

  EventProvider() {
    _loadEvents(); // Load events on initialization
  }

  void addEvent(Event event) {
    // Normalize the event's creation date to ignore time details for grouping
    final normalizedDate =
        DateTime(event.dateTime.year, event.dateTime.month, event.dateTime.day);

    if (!_events.containsKey(normalizedDate)) {
      _events[normalizedDate] = [];
    }

    // Ensure no duplicate events by checking the ID
    if (!_events[normalizedDate]!.any((e) => e.id == event.id)) {
      _events[normalizedDate]!.add(event);
      notifyListeners();
      _saveEvents(); // Persist the updated events
    }
  }

  void removeEvent(String eventId) {
    // Iterate through all events and remove by id
    _events.forEach((date, eventsList) {
      eventsList.removeWhere((event) => event.id == eventId);
    });

    // Clean up empty dates
    _events.removeWhere((date, eventsList) => eventsList.isEmpty);

    notifyListeners();
    _saveEvents();
  }

  void updateEvent(String eventId, Event updatedEvent) {
    _events.forEach((date, eventsList) {
      final index = eventsList.indexWhere((event) => event.id == eventId);
      if (index != -1) {
        eventsList[index] = updatedEvent;
        notifyListeners();
        _saveEvents();
        return;
      }
    });
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = _events.map((key, value) {
      return MapEntry(
          key.toIso8601String(), value.map((e) => e.toJson()).toList());
    });
    await prefs.setString('events', jsonEncode(encodedData));
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('events');

    if (jsonString != null) {
      final decodedData = jsonDecode(jsonString) as Map<String, dynamic>;
      _events = decodedData.map((key, value) {
        final date = DateTime.parse(key);
        final eventsList =
            (value as List).map((e) => Event.fromJson(e)).toList();
        return MapEntry(date, eventsList);
      });
      notifyListeners();
    }
  }
}
