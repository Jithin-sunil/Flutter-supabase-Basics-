import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/category.dart';
import 'package:webapp/district.dart';
import 'package:webapp/place.dart';
import 'package:webapp/subcategory.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int? _districtCount; // Variable to store district count
  int? _placeCount; // Variable to store place count

  @override
  void initState() {
    super.initState();
    _fetchCounts(); // Fetch counts when the dashboard is initialized
  }

  Future<void> _fetchCounts() async {
    try {
      // Fetch district count
      final districtResponse = await Supabase.instance.client
          .from('tbl_district')
          .select('*', const FetchOptions(count: CountOption.exact))
          .limit(1); // Ensures no unnecessary data is fetched;

      // Fetch place count
      final placeResponse = await Supabase.instance.client
          .from('tbl_place')
          .select('*', const FetchOptions(count: CountOption.exact))
          .limit(1);

      setState(() {
        _districtCount = districtResponse.count ?? 0; // Update district count
        _placeCount = placeResponse.count ?? 0; // Update place count
      });
    } catch (e) {
      print('Error fetching counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          Icon(Icons.logout),
          SizedBox(width: 20),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text("Dashboard"),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text("District"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => District()));
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text("Place"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => PlacePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text("Category"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Category()));
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text("SubCategory"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SubCategory()));
              },
            ),
          ],
        ),
      ),
      body: Container(
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                shape: Border.all(),
                color: const Color.fromARGB(255, 231, 156, 137),
                child: Center(
                  widthFactor: 1.5,
                  heightFactor: 6,
                  child: Text(
                    "Total Districts: ${_districtCount ?? 'Loading...'}", // Display district count
                  ),
                ),
              ),
              Card(
                shape: Border.all(),
                color: const Color.fromARGB(255, 233, 182, 89),
                child: Center(
                  widthFactor: 1.5,
                  heightFactor: 6,
                  child: Text(
                    "Total Places: ${_placeCount ?? 'Loading...'}", // Display place count
                  ),
                ),
              ),
              Card(
                shape: Border.all(),
                color: const Color.fromARGB(255, 233, 182, 89),
                child: Center(
                  widthFactor: 1.5,
                  heightFactor: 6,
                  child: Text(
                    "Total Users: ", 
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
