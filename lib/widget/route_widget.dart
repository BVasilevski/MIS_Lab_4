import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class RouteToEventPage extends StatefulWidget {
  final LatLng eventLocation; // Event location (latitude, longitude)

  RouteToEventPage({required this.eventLocation});

  @override
  _RouteToEventPageState createState() => _RouteToEventPageState();
}

class _RouteToEventPageState extends State<RouteToEventPage> {
  LatLng? _userLocation;
  List<LatLng> _routeCoordinates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // Fetch the current location of the user
  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _fetchRoute();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  // Fetch the route using OpenRouteService
  Future<void> _fetchRoute() async {
    if (_userLocation == null) return;

    const url = 'https://api.openrouteservice.org/v2/directions/driving-car';
    const headers = {
      'Authorization':
          '5b3ce3597851110001cf6248be9ed5f491e14176b24d8c17d50d8c71',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      "coordinates": [
        [_userLocation!.longitude, _userLocation!.latitude],
        [widget.eventLocation.longitude, widget.eventLocation.latitude],
      ],
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("API Response: $data");

        if (data['routes'] == null || data['routes'].isEmpty) {
          print("No routes available.");
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final encodedPolyline = data['routes'][0]['geometry'];
        final decodedPolyline =
            PolylinePoints().decodePolyline(encodedPolyline);

        setState(() {
          _routeCoordinates = decodedPolyline
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
          _isLoading = false;
        });
      } else {
        print('Error fetching route: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Route to Event")),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _userLocation ?? widget.eventLocation,
              // Center the map based on user or event location
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 50.0,
                      height: 50.0,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 50.0,
                      ),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.eventLocation,
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
              if (_routeCoordinates.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routeCoordinates,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
