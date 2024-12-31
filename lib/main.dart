import 'package:flutter/material.dart';
import 'package:lab4/widget/add_event_widget.dart';
import 'package:lab4/widget/map_widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lab4/provider/EventProvider.dart';
import 'model/Event.dart';
import 'widget/route_widget.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: MaterialApp(
        home: HomePage(),
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  final GlobalKey<HomePageState> homePageKey = GlobalKey<HomePageState>();

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  DateTime _selectedDay = DateTime.now();
  late ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

  List<Event> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    final events = Provider.of<EventProvider>(context, listen: false).events;
    return events.entries
        .where((entry) => _isSameDay(entry.key, normalizedDay))
        .expand((entry) => entry.value)
        .toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void updateEventsForSelectedDay(DateTime day) {
    setState(() {
      _selectedEvents.value = _getEventsForDay(day);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve all events from the provider
    var events = Provider.of<EventProvider>(context).events;

    // Get events for today
    final todayEvents = _getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Schedule App'),
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _selectedEvents.value = _getEventsForDay(selectedDay);
              });
            },
            eventLoader: (day) {
              return events[day] ?? [];
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final dayEvents = events[day] ?? [];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (dayEvents.isNotEmpty)
                      Text(
                        '${dayEvents.length} events',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      '${day.day}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Events on ${_selectedDay.toLocal().toString().split(' ')[0]}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: todayEvents.isEmpty
                ? const Center(
                    child: Text(
                      'No events today.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: todayEvents.length,
                    itemBuilder: (context, index) {
                      final event = todayEvents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(event.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Location: ${event.location.address}\nDate: ${event.dateTime.toLocal().toString().split(' ')[0]}',
                          ),
                          isThreeLine: true,
                          onTap: () {
                            // Navigate to RouteToEventPage with event's location
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RouteToEventPage(
                                  eventLocation: LatLng(
                                    event.location.latitude,
                                    event.location.longitude,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              // Navigate to EventLocationsMap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventLocationsMap(),
                ),
              );
            },
            label: Text('View All Events On Map'),
            icon: Icon(Icons.map),
            tooltip: 'View All Event Locations on Map',
          ),
          SizedBox(height: 10), // Space between buttons
          FloatingActionButton(
            onPressed: () {
              // Pass the updateEventsForSelectedDay method to AddEventPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEventPage(),
                ),
              );
            },
            tooltip: 'Add Event',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
