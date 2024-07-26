import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketapp/machinelearning.dart';

void main() {
  group('MachineLearningPage Tests', () {
    testWidgets('MachineLearningPage initial state',
        (WidgetTester tester) async {
      // Provide the mock services to the widget
      await tester.pumpWidget(MaterialApp(
        home: MachineLearningPage(itemId: 1, pageKey: 'testKey'),
      ));

      // Create the Finders
      final titleFinder = find.text('Machine Learning Page: testKey');
      final algorithmTypeFinder = find.text('Algorithm Type: ');
      final loadTimeFinder = find.text('Load Time: ');
      final dataAmountFinder = find.text('Amount of Data: ');
      final currentPriceFinder = find.text('Current Price: 0.0');
      final priceDifferenceFinder = find.text('Price Difference: 0.00');

      // Verify the initial state
      expect(titleFinder, findsOneWidget);
      expect(algorithmTypeFinder, findsOneWidget);
      expect(loadTimeFinder, findsOneWidget);
      expect(dataAmountFinder, findsOneWidget);
      expect(currentPriceFinder, findsOneWidget);
      expect(priceDifferenceFinder, findsOneWidget);
    });

    testWidgets('MachineLearningPage button press',
        (WidgetTester tester) async {
      // Provide the mock services to the widget
      await tester.pumpWidget(MaterialApp(
        home: MachineLearningPage(itemId: 1, pageKey: 'testKey'),
      ));

      // Create the Finder
      final buttonFinder = find.text('Get All Data');

      // Emulate a tap on the button
      await tester.tap(buttonFinder);

      // Trigger a frame
      await tester.pump();

      expect(buttonFinder, findsOneWidget);
    });
  });
}
