import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// The main page for managing subcategory (adding, updating, deleting)
class SubCategory extends StatefulWidget {
  const SubCategory({super.key}); // Constructor for the widget

  @override
  State<SubCategory> createState() => _SubCategoryState(); // Creates the state for this page
}

// State class for SubCategory, managing logic and UI
class _SubCategoryState extends State<SubCategory> {
  final _formKey = GlobalKey<FormState>(); // Form key to manage form state
  final _subcategoryController = TextEditingController(); // Controller for the subcategory name text field

  List<Map<String, dynamic>> _categoryList = []; // List to store category data
  List<Map<String, dynamic>> _subcategoryList = []; // List to store subcategory data
  String? _selectedcategoryId; // Selected category ID for the subcategory
  bool _isEditing = false; // Flag to check if we are editing a subcategory
  int? _editingIndex; // Index of the subcategory being edited

  // Runs when the widget is first created
  @override
  void initState() {
    super.initState();
    _fetchcategorys(); // Fetch category data when the page is initialized
    _fetchsubcategory(); // Fetch subcategory data when the page is initialized
  }

  // Fetch category data from the Supabase database
  Future<void> _fetchcategorys() async {
    try {
      final response = await Supabase.instance.client.from('tbl_category').select(); // Fetch categorys from 'tbl_category'
      if (response != null && response is List) {
        setState(() {
          _categoryList = List<Map<String, dynamic>>.from(response); // Populate the category list
        });
      } else {
        _showError('Failed to fetch categorys'); // Show error if the response is null or not a list
      }
    } catch (e) {
      _showError('Error fetching categorys: $e'); // Handle errors by showing an error message
    }
  }

  // Fetch subcategory data from the Supabase database
  Future<void> _fetchsubcategory() async {
    try {
      final response = await Supabase.instance.client
          .from('tbl_subcategory')
          .select('id, subcategory_name, category_id, tbl_category(category)'); // Fetch subcategory along with category info
      if (response != null && response is List) {
        setState(() {
          _subcategoryList = List<Map<String, dynamic>>.from(response); // Populate the subcategory list
        });
      } else {
        _showError('Failed to fetch subcategory'); // Show error if the response is null or not a list
      }
    } catch (e) {
      _showError('Error fetching subcategory: $e'); // Handle errors by showing an error message
    }
  }

  // Add or update a subcategory depending on the state (_isEditing)
  Future<void> _addOrUpdatesubcategory() async {
    if (_formKey.currentState!.validate()) { // Check if form fields are valid
      try {
        if (_isEditing && _editingIndex != null) { // If editing an existing subcategory
          final id = _subcategoryList[_editingIndex!]['id']; // Get the subcategory ID from the list
          await Supabase.instance.client.from('tbl_subcategory').update({
            'subcategory_name': _subcategoryController.text, // Update subcategory name
            'category_id': _selectedcategoryId, // Update category ID
          }).eq('id', id); // Match the subcategory ID to update the correct record
          _showMessage('subcategory updated successfully!'); // Show success message
        } else { // If adding a new subcategory
          await Supabase.instance.client.from('tbl_subcategory').insert({
            'subcategory_name': _subcategoryController.text, // Insert new subcategory name
            'category_id': _selectedcategoryId, // Insert category ID
          });
          _showMessage('subcategory added successfully!'); // Show success message
        }
        _resetForm(); // Reset the form after adding or updating
        _fetchsubcategory(); // Refresh the list of subcategory
      } catch (e) {
        _showError('Error adding/updating subcategory: $e'); // Handle errors by showing an error message
      }
    }
  }

  // Edit an existing subcategory (set the form to editing state)
  void _editsubcategory(int index) {
    setState(() {
      _isEditing = true; // Set editing state to true
      _editingIndex = index; // Set the index of the subcategory being edited
      _subcategoryController.text = _subcategoryList[index]['subcategory_name']; // Set the subcategory name in the text field
      _selectedcategoryId = _subcategoryList[index]['category_id'].toString(); // Set the selected category ID
    });
  }

  // Delete a subcategory from the database
  void _deletesubcategory(int index) async {
    try {
      final id = _subcategoryList[index]['id']; // Get the subcategory ID from the list
      await Supabase.instance.client.from('tbl_subcategory').delete().eq('id', id); // Delete the subcategory with the corresponding ID
      _showMessage('subcategory deleted successfully!'); // Show success message
      _fetchsubcategory(); // Refresh the list of subcategory
    } catch (e) {
      _showError('Error deleting subcategory: $e'); // Handle errors by showing an error message
    }
  }

  // Reset the form fields and the editing state
  void _resetForm() {
    setState(() {
      _isEditing = false; // Set editing state to false
      _editingIndex = null; // Reset the editing index
      _subcategoryController.clear(); // Clear the subcategory name text field
      _selectedcategoryId = null; // Reset the selected category ID
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

  // Build the UI for the SubCategory
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2F33), // Set the background color of the page
      appBar: AppBar(
        title: const Text("subcategory Management"), // Title of the app bar
        backgroundColor: const Color(0xFF23272A), // App bar background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
          children: [
            const Text(
              "Add or Edit subcategory", // Header for the form
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), // Text styling
            ),
            const SizedBox(height: 10), // Spacing between header and form
            Form(
              key: _formKey, // Assign the form key for validation
              child: Row(
                children: [
                  // Dropdown for selecting a category
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "Select category", // Hint text for the dropdown
                        hintStyle: const TextStyle(color: Colors.white54), // Hint text style
                        filled: true,
                        fillColor: const Color(0xFF40444B), // Background color of the dropdown
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                          borderSide: BorderSide.none, // Remove border side
                        ),
                      ),
                      value: _selectedcategoryId, // Set the selected category ID
                      style: const TextStyle(color: Colors.white), // Text color
                      dropdownColor: const Color(0xFF40444B), // Dropdown background color
                      items: _categoryList.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'].toString(), // Set the category ID as the value
                          child: Text(category['category'], style: const TextStyle(color: Colors.white)), // Display the category name
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedcategoryId = value; // Update the selected category ID when the user selects a category
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a category"; // Validation for category selection
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10), // Spacing between the dropdown and text field
                  // Text field for entering the subcategory name
                  Expanded(
                    child: TextFormField(
                      controller: _subcategoryController, // Use the subcategory controller for the text field
                      decoration: InputDecoration(
                        hintText: "Enter subcategory name", // Hint text for the subcategory name field
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
                          return 'Please enter a subcategory name'; // Validation for subcategory name
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
                // Save button to add or update a subcategory
                ElevatedButton(
                  onPressed: _addOrUpdatesubcategory, // Call the function to add or update subcategory
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent
                    
                  ),
                  child: Text(_isEditing ? "Update subcategory" : "Add subcategory"), // Change text based on editing state
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
            const SizedBox(height: 20), // Spacing before the list of subcategory
            const Text(
              "subcategory List", // Header for the subcategory list
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10), // Spacing between header and list
            Expanded(
              child: ListView.builder(
                itemCount: _subcategoryList.length, // Number of subcategory to display
                itemBuilder: (context, index) {
                  final subcategory = _subcategoryList[index]; // Get the subcategory data at the current index
                  return ListTile(
                    title: Text(subcategory['subcategory_name'], style: const TextStyle(color: Colors.white)), // Display the subcategory name
                    subtitle: Text(subcategory['tbl_category']['category'], style: const TextStyle(color: Colors.white70)), // Display the category name
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Allow space for action buttons
                      children: [
                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange), // Edit icon with orange color
                          onPressed: () => _editsubcategory(index), // Call the function to edit the subcategory
                        ),
                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red), // Delete icon with red color
                          onPressed: () => _deletesubcategory(index), // Call the function to delete the subcategory
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
