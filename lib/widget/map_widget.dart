import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../provider/EventProvider.dart';
import '../model/Event.dart';

class EventLocationsMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retrieve all events from the EventProvider
    final eventProvider = Provider.of<EventProvider>(context);
    final events = eventProvider.events;

    // Create markers for each event location
    final List<Marker> markers = events.entries
        .expand((entry) => entry.value)
        .map((event) => Marker(
      point: LatLng(event.location.latitude, event.location.longitude),
      width: 50.0,
      height: 50.0,
      child: GestureDetector(
        onTap: () {
          // Show details about the event when the marker is tapped
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(event.title),
              content: Text(
                  'Location: ${event.location.address}\nDate: ${event.dateTime.toString().split(' ')[0]}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            ),
          );
        },
        child: Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40.0,
        ),
      ),
    ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Locations'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: markers.isNotEmpty
              ? markers.first.point
              : LatLng(41.9981, 21.4254), // Default center if no events
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: markers,
          ),
        ],
      ),
    );
  }
}
