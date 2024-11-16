import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Main widget for the category screen
class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

// State class for the Category widget
class _CategoryState extends State<Category> {
  // Key for the form to handle form validation
  final _formKey = GlobalKey<FormState>();
  
  // TextEditingController to control the input field for category name
  final _nameController = TextEditingController();
  
  // List to store category data fetched from Supabase
  final List<Map<String, dynamic>> _dataList = [];
  
  // Flag to check if the app is in editing mode
  bool _isEditing = false;
  
  // Index of the category being edited (if any)
  int? _editingIndex;

  // Initialize the widget and fetch data from the database
  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch the data from Supabase when the widget is initialized
  }

  // Function to fetch category data from Supabase
  Future<void> _fetchData() async {
    try {
      // Query to fetch all category data from 'tbl_category' table
      final response = await Supabase.instance.client.from('tbl_category').select();
      
      if (response != null && response is List) {
        setState(() {
          // Clear the existing data and add new data
          _dataList.clear();
          _dataList.addAll(List<Map<String, dynamic>>.from(response));
        });
      }
    } catch (e) {
      // Show an error message if data fetching fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  // Function to handle data addition or update based on editing state
  void _addOrUpdateData() async {
    if (_formKey.currentState!.validate()) { // Validate the form before proceeding
      try {
        if (_isEditing && _editingIndex != null) {
          // If in editing mode, update the existing data
          final id = _dataList[_editingIndex!]['id'];
          await Supabase.instance.client.from('tbl_category').update({'category': _nameController.text}).eq('id', id);
          
          setState(() {
            // Update the data locally
            _dataList[_editingIndex!]['category'] = _nameController.text;
            _isEditing = false;
            _editingIndex = null;
            _nameController.clear();
          });
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data updated successfully!')),
          );
        } else {
          // If not editing, insert new data
          final response = await Supabase.instance.client
              .from('tbl_category')
              .insert({'category': _nameController.text});

          if (response != null) {
            setState(() {
              // Add the new data to the list
              _dataList.add(response as Map<String, dynamic>);
              _nameController.clear();
            });
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data inserted successfully!')),
            );
          }
        }
      } catch (e) {
        // Show error message if insert or update fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during insert/update: $e')),
        );
      }
    }
  }

  // Function to enable editing of a specific category data
  void _editData(int index) {
    setState(() {
      // Set editing mode to true and populate the text field with current data
      _isEditing = true;
      _editingIndex = index;
      _nameController.text = _dataList[index]['category'];
    });
  }

  // Function to delete a category from the database
  void _deleteData(int index) async {
    try {
      final id = _dataList[index]['id'];
      await Supabase.instance.client.from('tbl_category').delete().eq('id', id);
      
      setState(() {
        // Remove the deleted data from the list
        _dataList.removeAt(index);
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data deleted successfully!')),
      );
    } catch (e) {
      // Show error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during delete: $e')),
      );
    }
  }

  // Build the UI for the category page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2F33), // Dark background color for the page
      appBar: AppBar(
        title: const Text(
          "category Manager", // Title of the app bar
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF23272A), // Dark color for app bar
        elevation: 0, // Remove app bar shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add or Edit category", // Title for the form
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Form to add or edit category
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController, // Controller for the category input field
                      decoration: InputDecoration(
                        hintText: "Enter category name",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF40444B), // Field background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        // Validation to check if the field is empty
                        if (value == null || value.isEmpty) {
                          return "Please enter a name";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addOrUpdateData, // Trigger add or update operation
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      backgroundColor: _isEditing ? Colors.orange : const Color(0xFF7289DA), // Change button color based on editing state
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(_isEditing ? "Update" : "Submit"), // Change button text based on editing state
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "category Data", // Title for displaying category data
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Card(
                elevation: 5,
                color: const Color(0xFF2A2D3E), // Background color for the card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _dataList.isEmpty
                      ? const Center(
                          child: Text(
                            "No data available", // Message when no data is available
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Index',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'category Name',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Actions',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: _dataList.asMap().entries.map((entry) {
                              int index = entry.key + 1; // category index
                              Map<String, dynamic> item = entry.value; // category data
                              return DataRow(
                                cells: [
                                  DataCell(Text(
                                    index.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  )),
                                  DataCell(Text(
                                    item['category'],
                                    style: const TextStyle(color: Colors.white),
                                  )),
                                  DataCell(Row(
                                    children: [
                                      // Edit button
                                      IconButton(
                                        onPressed: () => _editData(entry.key),
                                        icon: const Icon(Icons.edit, color: Colors.orange),
                                      ),
                                      // Delete button
                                      IconButton(
                                        onPressed: () => _deleteData(entry.key),
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                      ),
                                    ],
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
