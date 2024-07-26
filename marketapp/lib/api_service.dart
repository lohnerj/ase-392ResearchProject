import 'dart:convert';
import 'package:http/http.dart' as http;

// Function to perform an HTTP GET request and return the JSON response
Future<Map<String, dynamic>> httpGetJson(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to fetch data with status code: ${response.statusCode}');
    }
  } on Exception catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

// Function to fetch a list of servers
Future<String> fetchServers() async {
  final response =
      await http.get(Uri.parse('https://nwmarketprices.com/api/servers/'));
  return response.body;
}

// Function to fetch the latest prices
Future<String> fetchLatestPrices() async {
  try {
    final responseData =
        await httpGetJson('https://nwmarketprices.com/api/latest-prices/15/');
    return json.encode(responseData); // Convert the response to a JSON string
  } catch (e) {
    throw Exception('Failed to fetch latest prices: $e');
  }
}

// Function to fetch price data for a specific item ID
Future<double> fetchPriceData(int itemId) async {
  try {
    final response = await http
        .get(Uri.parse('https://nwmarketprices.com/0/15?cn_id=$itemId'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['recent_lowest_price']?.toDouble() ??
          0; // Ensure it's a double
    } else {
      throw Exception(
          'Failed to fetch price: Server responded with ${response.statusCode}');
    }
  } catch (e) {
    // Log the error
    throw Exception('Error fetching price: $e');
  }
}

// Function to fetch large data for a specific item ID
Future<Map<String, String>> fetchLargeData(int itemId) async {
  try {
    final response = await http
        .get(Uri.parse('https://nwmarketprices.com/0/15?cn_id=$itemId'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      var priceGraphData = data['price_graph_data'];
      Map<String, String> avgPrices = {};

      for (var graphData in priceGraphData) {
        avgPrices[graphData['date_only'].toString()] =
            graphData['avg_price'].toString();
      }

      return avgPrices;
    } else {
      throw Exception(
          'Failed to fetch graph data: Server responded with ${response.statusCode}');
    }
  } catch (e) {
    // Log the error
    throw Exception('Error fetching graph data: $e');
  }
}

// Function to fetch the latest info for a specific item ID
Future<List<String>> fetchLatestInfo(int itemId) async {
  try {
    final response = await http
        .get(Uri.parse('https://nwmarketprices.com/0/15?cn_id=$itemId'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      var latestGraphData = data['price_graph_data'].last;

      List<String> info = [
        latestGraphData['qty'].toString(),
        latestGraphData['date_only'].toString(),
        latestGraphData['lowest_price'].toString(),
        latestGraphData['highest_buy_order'].toString(),
        latestGraphData['avg_price'].toString(),
      ];

      return info;
    } else {
      throw Exception(
          'Failed to fetch graph data: Server responded with ${response.statusCode}');
    }
  } catch (e) {
    // Log the error
    throw Exception('Error fetching graph data: $e');
  }
}

// Function to fetch graph data for a specific item ID
Future<List<double>> fetchGraphData(int itemId) async {
  try {
    final response = await http
        .get(Uri.parse('https://nwmarketprices.com/0/15?cn_id=$itemId'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      var latestGraphData = data['price_graph_data'].last;

      List<double> prices = [
        data['recent_lowest_price']?.toDouble() ??
            0.0, // recent_lowest_price from main object
        latestGraphData['lowest_price']?.toDouble() ??
            0.0, // lowest_price from the latest price graph data
        latestGraphData['highest_buy_order']?.toDouble() ??
            0.0, // highest_buy_order from the latest price graph data
        latestGraphData['avg_price']?.toDouble() ??
            0.0, // avg_price from the latest price graph data
      ];

      return prices;
    } else {
      throw Exception(
          'Failed to fetch graph data: Server responded with ${response.statusCode}');
    }
  } catch (e) {
    // Log the error
    throw Exception('Error fetching graph data: $e');
  }
}

// Function to fetch names and their IDs
Future<Map<String, dynamic>> fetchNames() async {
  final response = await http
      .get(Uri.parse('https://nwmarketprices.com/api/confirmed_names/'));
  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    Map<String, dynamic> namesDict = {};
    data.forEach((key, value) {
      if (value['name_id'] != null) {
        namesDict[value['name']] = value['name_id'];
      }
    });
    return namesDict;
  } else {
    throw Exception('Failed to load names');
  }
}
