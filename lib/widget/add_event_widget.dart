import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:lab4/provider/EventProvider.dart';
import 'package:lab4/model/Event.dart'; // Ensure the Event class is correctly imported
import 'package:provider/provider.dart';
import '../model/Location.dart';
import 'pick_location.dart'; // Assuming this is the Location Picker page we created

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  DateTime? _selectedDate;
  LatLng? _selectedLocation;
  String? _selectedAddress;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Default to the current date
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!); // Initialize the date field with the current date
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPickerPage()),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = LatLng(result['latitude'], result['longitude']);
        _selectedAddress = result['address'];
        _locationController.text = _selectedAddress ?? 'No address selected'; // Update the location field
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedLocation != null) {
        final event = Event(
          id: DateTime.now().toString(), // Use current time as ID or generate unique ID
          title: _title!,
          dateTime: _selectedDate!,
          location: Location(
            address: _selectedAddress!,
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
          ),
        );

        // Add the event to the provider
        Provider.of<EventProvider>(context, listen: false).addEvent(event);

        // Return to the previous page
        Navigator.pop(context);
      } else {
        // Show error if location isn't selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a location.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value;
                },
              ),
              SizedBox(height: 16),

              // Date Field
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate!,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!); // Update the date field
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController, // Use the controller for the date field
                    decoration: InputDecoration(
                      labelText: 'Event Date',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      // Save selected date if needed
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Location Field
              GestureDetector(
                onTap: _pickLocation,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _locationController, // Use the controller for the location field
                    decoration: InputDecoration(
                      labelText: 'Event Location',
                      border: OutlineInputBorder(),
                      hintText: 'Tap to select location',
                    ),
                    onSaved: (value) {
                      // Save the location (if needed)
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text('Save Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
