import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class LocationPickerPage extends StatefulWidget {
  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _selectedLocation;
  String? _selectedAddress;

  // Function to fetch address from coordinates using Nominatim (OpenStreetMap)
  Future<void> _getAddressFromLatLng(LatLng location) async {
    print(
        'Fetching address for coordinates: ${location.latitude}, ${location.longitude}');
    try {
      // Use Nominatim API to fetch the address
      final url =
          'https://nominatim.openstreetmap.org/reverse?lat=${location.latitude}&lon=${location.longitude}&format=json';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address != null) {
          setState(() {
            _selectedAddress = "${address['road'] ?? 'Unknown Street'}, "
                "${address['city'] ?? 'Unknown City'}, "
                "${address['country'] ?? 'Unknown Country'}";
          });
        } else {
          setState(() {
            _selectedAddress = "No address found for this location.";
          });
        }
      } else {
        setState(() {
          _selectedAddress = "Failed to fetch address.";
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = "Error fetching address: $e";
      });
      print("Error fetching address: $e");
    }
  }

  // When the user taps on the map, we update the selected location and fetch the address
  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedLocation = position;
      _getAddressFromLatLng(position);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a Location'),
      ),
      body: Stack(
        children: [
          // FlutterMap widget to display OpenStreetMap
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(41.9981, 21.4254), // Default to Skopje
              initialZoom: 13.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 50.0,
                      height: 50.0,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50.0,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Displaying the fetched address at the bottom
          if (_selectedAddress != null)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Address: $_selectedAddress',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
      // Floating button to confirm the selected location and address
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedLocation != null && _selectedAddress != null) {
            Navigator.pop(
              context,
              {
                'latitude': _selectedLocation!.latitude,
                'longitude': _selectedLocation!.longitude,
                'address': _selectedAddress,
              },
            );
          }
        },
        child: Icon(Icons.check),
        tooltip: 'Confirm Location',
      ),
    );
  }
}
