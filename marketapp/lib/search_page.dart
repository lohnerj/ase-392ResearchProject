// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marketapp/api_service.dart';
import 'dashboard_page.dart';

// SearchPage widget which is a StatefulWidget
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

// State class for SearchPage
class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _namesDict = {}; // Dictionary to hold all names
  Map<String, dynamic> _filteredNames = {}; // Dictionary to hold filtered names

  @override
  void initState() {
    super.initState();
    // Fetch names from the API and update state
    fetchNames().then((data) {
      setState(() {
        _namesDict = data;
        _filteredNames = _namesDict;
      });
    });
  }

  // Function to filter names based on the entered keyword
  void _filterNames(String enteredKeyword) {
    Map<String, dynamic> results = {};
    if (enteredKeyword.isEmpty) {
      results = _namesDict;
    } else {
      results = Map.fromEntries(_namesDict.entries.where((entry) => entry.key
          .toString()
          .toLowerCase()
          .contains(enteredKeyword.toLowerCase())));
    }
    setState(() {
      _filteredNames = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Items"), // Title of the AppBar
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0), // Padding for the search input
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                  labelText: 'Search'), // Input decoration
              onChanged: (value) {
                _filterNames(value); // Call filter function on text change
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNames.length, // Number of filtered items
              itemBuilder: (context, index) {
                String key = _filteredNames.keys.elementAt(index);
                return ListTile(
                  title: Text(key), // Display the key (name)
                  trailing: IconButton(
                    icon: const Icon(Icons.add), // Add icon
                    onPressed: () {
                      // Store the item ID associated with the name in Hive box
                      Hive.box('itemsBox').put(key, _namesDict[key]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to DashboardPage
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DashboardPage()));
        },
        tooltip: 'Go to Dashboard', // Tooltip for the button
        child: const Icon(Icons.dashboard), // Icon for the button
      ),
    );
  }
}
