// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marketapp/api_service.dart';
import 'package:marketapp/machinelearning.dart';
import 'graph_page.dart';

// DashboardPage widget which is a StatefulWidget
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

// State class for DashboardPage
class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")), // AppBar title
      body: ValueListenableBuilder(
        valueListenable: Hive.box('itemsBox').listenable(),
        builder: (context, Box box, widget) {
          return ListView.builder(
            itemCount: box.keys.length, // Number of items in the box
            itemBuilder: (context, index) {
              String key = box.keyAt(index);
              int itemId =
                  box.get(key); // Assuming the value stored is the item ID

              return ListTile(
                title: Text(key), // Display the key (name)
                subtitle: FutureBuilder<double>(
                  future: fetchPriceData(itemId), // Fetch latest price data
                  builder:
                      (BuildContext context, AsyncSnapshot<double> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Loading latest price...");
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else {
                      return Text("Latest price: ${snapshot.data.toString()}");
                    }
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Ensures the row takes minimum space required by children
                  children: [
                    IconButton(
                      icon: const Icon(
                          Icons.show_chart), // Icon for showing chart
                      onPressed: () async {
                        try {
                          List<double> prices =
                              await fetchGraphData(itemId); // Fetch graph data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    GraphPage(prices: prices)),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to load data: $e')));
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove), // Icon for removing item
                      onPressed: () {
                        box.delete(key);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                          Icons.question_mark), // Icon for fetching latest info
                      onPressed: () async {},
                    ),
                    IconButton(
                      icon: const Icon(
                          Icons.lightbulb), // Icon for machine learning
                      onPressed: () async {
                        try {
                          // Navigate to MachineLearningPage
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MachineLearningPage(
                                    itemId: itemId, pageKey: key),
                              ));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to load data: $e')));
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder function for FloatingActionButton
        }, // Icon for the button
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add), // Background color for the button
      ),
    );
  }
}
