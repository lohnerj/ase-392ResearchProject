// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marketapp/api_service.dart';
import 'dashboard_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _namesDict = {};
  Map<String, dynamic> _filteredNames = {};

  @override
  void initState() {
    super.initState();
    fetchNames().then((data) {
      setState(() {
        _namesDict = data;
        _filteredNames = _namesDict;
      });
    });
  }

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
        title: const Text("Search Items"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Search'),
              onChanged: (value) {
                _filterNames(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNames.length,
              itemBuilder: (context, index) {
                String key = _filteredNames.keys.elementAt(index);
                return ListTile(
                  title: Text(key),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Hive.box('itemsBox').put(
                          key,
                          _namesDict[
                              key]); // Store the item ID associated with the name
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DashboardPage()));
        },
        tooltip: 'Go to Dashboard',
        child: const Icon(Icons.dashboard),
      ),
    );
  }
}
