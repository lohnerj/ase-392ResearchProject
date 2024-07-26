import 'package:flutter/material.dart';
import 'package:marketapp/api_service.dart';
import 'package:marketapp/sqlHelper.dart';
import 'package:sqflite/sqflite.dart';

class MachineLearningPage extends StatelessWidget {
  final int itemId;
  final String pageKey;
  MachineLearningPage({required this.itemId, required this.pageKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Machine Learning Page: $pageKey'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Algorithm Type: ',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Load Time: ',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Amount of Data: ',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Fetch data from the API
                      Map<String, String> dataValues =
                          await fetchLargeData(itemId);

                      // Create or insert the data into the database
                      await createOrInsertData(pageKey, dataValues);

                      // Optionally, you can show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Data fetched and inserted successfully')),
                      );
                    } catch (e) {
                      print(e);
                      // Optionally, you can show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Failed to fetch or insert data: $e')),
                      );
                    }
                  },
                  child: Text('Fetch Data'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {},
                  child: const Text('Run Algorithm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createOrInsertData(
      String tableName, Map<String, String> data) async {
    final Database db = await sqlHelper.initializeDB();

    // Check if the table already exists
    bool tableExists = await sqlHelper.checkTableExists(db, tableName);

    // If the table doesn't exist, create it
    if (!tableExists) {
      await sqlHelper.createTable(db, tableName);
    }

    // Insert data into the table
    await sqlHelper.insertData(db, tableName, data);
  }
}
