import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// The main page for managing places (adding, updating, deleting)
class PlacePage extends StatefulWidget {
  const PlacePage({super.key}); // Constructor for the widget

  @override
  State<PlacePage> createState() => _PlacePageState(); // Creates the state for this page
}

// State class for PlacePage, managing logic and UI
class _PlacePageState extends State<PlacePage> {
  final _formKey = GlobalKey<FormState>(); // Form key to manage form state
  final _placeController = TextEditingController(); // Controller for the place name text field

  List<Map<String, dynamic>> _districtList = []; // List to store district data
  List<Map<String, dynamic>> _placeList = []; // List to store place data
  String? _selectedDistrictId; // Selected district ID for the place
  bool _isEditing = false; // Flag to check if we are editing a place
  int? _editingIndex; // Index of the place being edited

  // Runs when the widget is first created
  @override
  void initState() {
    super.initState();
    _fetchDistricts(); // Fetch district data when the page is initialized
    _fetchPlaces(); // Fetch place data when the page is initialized
  }

  // Fetch district data from the Supabase database
  Future<void> _fetchDistricts() async {
    try {
      final response = await Supabase.instance.client.from('tbl_district').select(); // Fetch districts from 'tbl_district'
      if (response != null && response is List) {
        setState(() {
          _districtList = List<Map<String, dynamic>>.from(response); // Populate the district list
        });
      } else {
        _showError('Failed to fetch districts'); // Show error if the response is null or not a list
      }
    } catch (e) {
      _showError('Error fetching districts: $e'); // Handle errors by showing an error message
    }
  }

  // Fetch place data from the Supabase database
  Future<void> _fetchPlaces() async {
    try {
      final response = await Supabase.instance.client
          .from('tbl_place')
          .select('id, place_name, district_id, tbl_district(district_name)'); // Fetch places along with district info
      if (response != null && response is List) {
        setState(() {
          _placeList = List<Map<String, dynamic>>.from(response); // Populate the place list
        });
      } else {
        _showError('Failed to fetch places'); // Show error if the response is null or not a list
      }
    } catch (e) {
      _showError('Error fetching places: $e'); // Handle errors by showing an error message
    }
  }

  // Add or update a place depending on the state (_isEditing)
  Future<void> _addOrUpdatePlace() async {
    if (_formKey.currentState!.validate()) { // Check if form fields are valid
      try {
        if (_isEditing && _editingIndex != null) { // If editing an existing place
          final id = _placeList[_editingIndex!]['id']; // Get the place ID from the list
          await Supabase.instance.client.from('tbl_place').update({
            'place_name': _placeController.text, // Update place name
            'district_id': _selectedDistrictId, // Update district ID
          }).eq('id', id); // Match the place ID to update the correct record
          _showMessage('Place updated successfully!'); // Show success message
        } else { // If adding a new place
          await Supabase.instance.client.from('tbl_place').insert({
            'place_name': _placeController.text, // Insert new place name
            'district_id': _selectedDistrictId, // Insert district ID
          });
          _showMessage('Place added successfully!'); // Show success message
        }
        _resetForm(); // Reset the form after adding or updating
        _fetchPlaces(); // Refresh the list of places
      } catch (e) {
        _showError('Error adding/updating place: $e'); // Handle errors by showing an error message
      }
    }
  }

  // Edit an existing place (set the form to editing state)
  void _editPlace(int index) {
    setState(() {
      _isEditing = true; // Set editing state to true
      _editingIndex = index; // Set the index of the place being edited
      _placeController.text = _placeList[index]['place_name']; // Set the place name in the text field
      _selectedDistrictId = _placeList[index]['district_id'].toString(); // Set the selected district ID
    });
  }

  // Delete a place from the database
  void _deletePlace(int index) async {
    try {
      final id = _placeList[index]['id']; // Get the place ID from the list
      await Supabase.instance.client.from('tbl_place').delete().eq('id', id); // Delete the place with the corresponding ID
      _showMessage('Place deleted successfully!'); // Show success message
      _fetchPlaces(); // Refresh the list of places
    } catch (e) {
      _showError('Error deleting place: $e'); // Handle errors by showing an error message
    }
  }

  // Reset the form fields and the editing state
  void _resetForm() {
    setState(() {
      _isEditing = false; // Set editing state to false
      _editingIndex = null; // Reset the editing index
      _placeController.clear(); // Clear the place name text field
      _selectedDistrictId = null; // Reset the selected district ID
    });
  }

  // Show a success message in a SnackBar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); // Display the message in a SnackBar
  }

  // Show an error message in a SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: const TextStyle(color: Colors.red)))); // Display the error in a red SnackBar
  }

  // Build the UI for the PlacePage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2F33), // Set the background color of the page
      appBar: AppBar(
        title: const Text("Place Management"), // Title of the app bar
        backgroundColor: const Color(0xFF23272A), // App bar background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
          children: [
            const Text(
              "Add or Edit Place", // Header for the form
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), // Text styling
            ),
            const SizedBox(height: 10), // Spacing between header and form
            Form(
              key: _formKey, // Assign the form key for validation
              child: Row(
                children: [
                  // Dropdown for selecting a district
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "Select District", // Hint text for the dropdown
                        hintStyle: const TextStyle(color: Colors.white54), // Hint text style
                        filled: true,
                        fillColor: const Color(0xFF40444B), // Background color of the dropdown
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                          borderSide: BorderSide.none, // Remove border side
                        ),
                      ),
                      value: _selectedDistrictId, // Set the selected district ID
                      style: const TextStyle(color: Colors.white), // Text color
                      dropdownColor: const Color(0xFF40444B), // Dropdown background color
                      items: _districtList.map((district) {
                        return DropdownMenuItem<String>(
                          value: district['id'].toString(), // Set the district ID as the value
                          child: Text(district['district_name'], style: const TextStyle(color: Colors.white)), // Display the district name
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDistrictId = value; // Update the selected district ID when the user selects a district
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a district"; // Validation for district selection
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10), // Spacing between the dropdown and text field
                  // Text field for entering the place name
                  Expanded(
                    child: TextFormField(
                      controller: _placeController, // Use the place controller for the text field
                      decoration: InputDecoration(
                        hintText: "Enter place name", // Hint text for the place name field
                        hintStyle: const TextStyle(color: Colors.white54), // Hint text style
                        filled: true,
                        fillColor: const Color(0xFF40444B), // Background color of the text field
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                          borderSide: BorderSide.none, // Remove border side
                        ),
                      ),
                      style: const TextStyle(color: Colors.white), // Text color
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a place name'; // Validation for place name
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Spacing between form and buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
              children: [
                // Save button to add or update a place
                ElevatedButton(
                  onPressed: _addOrUpdatePlace, // Call the function to add or update place
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent
                    
                  ),
                  child: Text(_isEditing ? "Update Place" : "Add Place"), // Change text based on editing state
                ),
                const SizedBox(width: 20), // Spacing between the buttons
                // Cancel button to reset the form
                ElevatedButton(
                  onPressed: _resetForm, // Call the function to reset the form
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 34, 47, 53)
                   
                  ),
                  child: const Text("Cancel"), // Text for cancel button
                ),
              ],
            ),
            const SizedBox(height: 20), // Spacing before the list of places
            const Text(
              "Places List", // Header for the places list
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10), // Spacing between header and list
            Expanded(
              child: ListView.builder(
                itemCount: _placeList.length, // Number of places to display
                itemBuilder: (context, index) {
                  final place = _placeList[index]; // Get the place data at the current index
                  return ListTile(
                    title: Text(place['place_name'], style: const TextStyle(color: Colors.white)), // Display the place name
                    subtitle: Text(place['tbl_district']['district_name'], style: const TextStyle(color: Colors.white70)), // Display the district name
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Allow space for action buttons
                      children: [
                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange), // Edit icon with orange color
                          onPressed: () => _editPlace(index), // Call the function to edit the place
                        ),
                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red), // Delete icon with red color
                          onPressed: () => _deletePlace(index), // Call the function to delete the place
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
