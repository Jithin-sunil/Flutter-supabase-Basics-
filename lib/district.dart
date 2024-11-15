import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class District extends StatefulWidget {
  const District({super.key});

  @override
  State<District> createState() => _DistrictState();
}

class _DistrictState extends State<District> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<Map<String, String>> _dataList = [];

  void _addData() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await Supabase.instance.client
            .from('tbl_district')
            .insert({'district': _nameController.text})
            .select();

        if (response != null) {
          setState(() {
            _dataList.add({'name': _nameController.text});
            _nameController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data inserted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to insert data.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during insert: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2F33), // Dark theme background color.
      appBar: AppBar(
        title: const Text(
          "District Manager",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF23272A), // Dark app bar.
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter District",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Enter district name",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF40444B), // Dark input field.
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a name";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      backgroundColor: const Color(0xFF7289DA), // Modern purple button.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Submitted Data",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _dataList.isEmpty
                  ? const Center(
                      child: Text(
                        "No data submitted yet",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _dataList.length,
                      itemBuilder: (context, index) {
                        final item = _dataList[index];
                        return Card(
                          color: const Color(0xFF40444B), // Dark card background.
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF7289DA),
                              child: Text(
                                item['name']![0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              item['name']!,
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
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
