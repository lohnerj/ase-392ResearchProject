// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:marketapp/api_service.dart';
import 'package:marketapp/sqlHelper.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

// Stateful widget for the Machine Learning page
class MachineLearningPage extends StatefulWidget {
  final int itemId;
  final String pageKey;

  const MachineLearningPage(
      {super.key, required this.itemId, required this.pageKey});

  @override
  _MachineLearningPageState createState() => _MachineLearningPageState();
}

// State class for MachineLearningPage
class _MachineLearningPageState extends State<MachineLearningPage> {
  String algorithmType = '';
  String loadTime = '';
  String dataAmount = '';
  String predictionResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Machine Learning Page: ${widget.pageKey}'), // AppBar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Algorithm Type: $algorithmType',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Load Time: $loadTime',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount of Data: $dataAmount',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Fetch data from the API
                      Map<String, String> dataValues =
                          await fetchLargeData(widget.itemId);

                      // Create or insert the data into the database
                      await sqlHelper.createOrInsertData(
                          widget.pageKey, dataValues);

                      // Show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Data fetched and inserted successfully')),
                      );
                    } catch (e) {
                      // Show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Failed to fetch or insert data: $e')),
                      );
                    }

                    // Retrieve all data from the database
                    List<Map<String, dynamic>> allData =
                        await sqlHelper.getAllData(widget.pageKey);

                    setState(() {
                      dataAmount = allData.length.toString();
                    });

                    // Measure execution time for prediction
                    final stopwatch = Stopwatch()..start();
                    double nextPrice = predictNextPrice(allData);
                    stopwatch.stop();

                    setState(() {
                      predictionResult =
                          'The predicted price for the next day is: $nextPrice';
                      loadTime =
                          'Execution time: ${stopwatch.elapsedMilliseconds} ms';
                      algorithmType = 'Linear Regression';
                    });
                  },
                  child: const Text('Get All Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              predictionResult,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Convert date string to a numeric value
  int _dateToNumeric(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return parsedDate.difference(DateTime(2024, 7, 12)).inDays;
  }

  // Predict the next price using linear regression
  double predictNextPrice(List<Map<String, dynamic>> allData) {
    List<int> dates =
        allData.map((entry) => _dateToNumeric(entry['date'])).toList();
    List<double> prices = allData
        .map((entry) => double.tryParse(entry['price'].toString()) ?? 0.0)
        .toList();

    // Prepare data for DataFrame
    List<List<dynamic>> data = [
      ['date', 'price'],
      for (int i = 0; i < dates.length; i++) [dates[i], prices[i]]
    ];

    // Create DataFrame
    final dataframe = DataFrame(data);

    // Train the linear regression model
    final linearRegressor = LinearRegressor(
      dataframe,
      'price',
      optimizerType: LinearOptimizerType.gradient,
    );

    // Predict the next price
    int nextDay = dates.last + 1;
    final predictionDf = linearRegressor.predict(DataFrame([
      ['date'],
      [nextDay]
    ]));

    // Extract the predicted value
    final predictedValue = predictionDf.rows.first.first;

    return predictedValue as double;
  }
}
