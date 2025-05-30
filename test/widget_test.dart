import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temperature_conversion_app/main.dart';

void main() {
  group('Temperature Converter App Tests', () {
    testWidgets('App loads with correct title and initial state', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const TemperatureConverterApp());

      // Verify that the app title is displayed
      expect(find.text('Temperature Converter'), findsOneWidget);
      
      // Verify conversion selector options are present
      expect(find.text('Fahrenheit to Celsius'), findsOneWidget);
      expect(find.text('Celsius to Fahrenheit'), findsOneWidget);
      
      // Verify initial conversion type is selected
      expect(find.byType(RadioListTile<String>), findsNWidgets(2));
      
      // Verify convert button is present
      expect(find.text('CONVERT'), findsOneWidget);
      
      // Verify clear button is present
      expect(find.text('CLEAR'), findsOneWidget);
      
      // Verify history section is present
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('Fahrenheit to Celsius conversion works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());
      
      // Find the temperature input field
      final temperatureField = find.byType(TextFormField);
      
      // Enter a temperature value (32°F should convert to 0°C)
      await tester.enterText(temperatureField, '32');
      
      // Tap the convert button
      await tester.tap(find.text('CONVERT'));
      await tester.pumpAndSettle();
      
      // Verify the result is displayed correctly
      expect(find.text('0.00°C'), findsOneWidget);
      expect(find.text('32°F'), findsOneWidget);
    });

    testWidgets('Celsius to Fahrenheit conversion works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());
      
      // Select Celsius to Fahrenheit conversion
      await tester.tap(find.text('Celsius to Fahrenheit'));
      await tester.pumpAndSettle();
      
      // Enter a temperature value (0°C should convert to 32°F)
      final temperatureField = find.byType(TextFormField);
      await tester.enterText(temperatureField, '0');
      
      // Tap the convert button
      await tester.tap(find.text('CONVERT'));
      await tester.pumpAndSettle();
      
      // Verify the result is displayed correctly
      expect(find.text('32.00°F'), findsOneWidget);
      expect(find.text('0°C'), findsOneWidget);
    });

    testWidgets('Conversion history is updated correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());
      
      // Perform a conversion
      final temperatureField = find.byType(TextFormField);
      await tester.enterText(temperatureField, '72.5');
      await tester.tap(find.text('CONVERT'));
      await tester.pumpAndSettle();
      
      // Check that history entry is created
      expect(find.text('F to C: 72.5 => 22.50'), findsOneWidget);
      
      // Perform another conversion
      await tester.tap(find.text('Celsius to Fahrenheit'));
      await tester.pumpAndSettle();
      
      await tester.enterText(temperatureField, '25');
      await tester.tap(find.text('CONVERT'));
      await tester.pumpAndSettle();
      
      // Check that both history entries are present
      expect(find.text('C to F: 25.0 => 77.00'), findsOneWidget);
      expect(find.text('F to C: 72.5 => 22.50'), findsOneWidget);
    });

    testWidgets('Clear button works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());
      
      // Enter a temperature value
      final temperatureField = find.byType(TextFormField);
      await tester.enterText(temperatureField, '100');
      
      // Perform conversion
      await tester.tap(find.text('CONVERT'));
      await tester.pumpAndSettle();
      
      // Verify result is displayed
      expect(find.text('37.78°C'), findsOneWidget);
      
      // Tap clear button
      await tester.tap(find.text('CLEAR'));
      await tester.pumpAndSettle();
      
      // Verify input field is cleared and result is hidden
      final TextFormField textField = tester.widget(temperatureField);
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('Invalid input shows error message', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());
      
      // Try to convert without entering a value
      await tester.tap(find.text('CONVERT'));
      await tester.pumpAndSettle();
      
      // Verify error message is shown
      expect(find.text('Please enter a temperature value'), findsOneWidget);
      
      // Enter invalid text
      final temperatureField = find.byType(TextFormField);
      await tester.enterText(temperatureField, 'abc');
      await tester.tap(find.text('CONVERT'));
      await tester.pumpAndSettle();
      
      // Verify error message for invalid number
      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('Conversion selector switches correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());
      
      // Initially Fahrenheit to Celsius should be selected
      RadioListTile<String> fahrenheitRadio = tester.widget(
        find.widgetWithText(RadioListTile<String>, 'Fahrenheit to Celsius'),
      );
      expect(fahrenheitRadio.groupValue, 'Fahrenheit to Celsius');
      
      // Tap Celsius to Fahrenheit option
      await tester.tap(find.text('Celsius to Fahrenheit'));
      await tester.pumpAndSettle();
      
      // Verify selection changed
      RadioListTile<String> celsiusRadio = tester.widget(
        find.widgetWithText(RadioListTile<String>, 'Celsius to Fahrenheit'),
      );
      expect(celsiusRadio.groupValue, 'Celsius to Fahrenheit');
    });

    testWidgets('Decimal precision is correct', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());
      
      // Test with a value that results in many decimal places
      final temperatureField = find.byType(TextFormField);
      await tester.enterText(temperatureField, '98.6');
      await tester.tap(find.text('CONVERT'));
      await tester.pumpAndSettle();
      
      // Verify result is rounded to 2 decimal places
      expect(find.text('37.00°C'), findsOneWidget);
    });

    testWidgets('History clear functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());
      
      // Perform a conversion to create history
      final temperatureField = find.byType(TextFormField);
      await tester.enterText(temperatureField, '50');
      await tester.tap(find.text('CONVERT'));
      await tester.pumpAndSettle();
      
      // Verify history entry exists
      expect(find.text('F to C: 50.0 => 10.00'), findsOneWidget);
      
      // Find and tap the clear history button
      await tester.tap(find.widgetWithText(TextButton, 'Clear'));
      await tester.pumpAndSettle();
      
      // Verify history is cleared
      expect(find.text('No conversions yet'), findsOneWidget);
    });
  });

  group('ConversionEntry Model Tests', () {
    test('ConversionEntry creates correct display text', () {
      final entry = ConversionEntry(
        fromUnit: 'Fahrenheit',
        toUnit: 'Celsius',
        inputValue: 72.5,
        outputValue: 22.50,
        timestamp: DateTime.now(),
      );
      
      expect(entry.displayText, 'F to C: 72.5 => 22.50');
    });

    test('ConversionEntry handles different units correctly', () {
      final entry = ConversionEntry(
        fromUnit: 'Celsius',
        toUnit: 'Fahrenheit',
        inputValue: 25.0,
        outputValue: 77.00,
        timestamp: DateTime.now(),
      );
      
      expect(entry.displayText, 'C to F: 25.0 => 77.00');
    });
  });

  group('Temperature Conversion Logic Tests', () {
    test('Fahrenheit to Celsius conversion formula', () {
      // Test known conversion values
      // 32°F = 0°C
      double result = (32 - 32) * 5 / 9;
      expect(result, 0.0);
      
      // 212°F = 100°C
      result = (212 - 32) * 5 / 9;
      expect(result, 100.0);
      
      // 98.6°F = 37°C
      result = (98.6 - 32) * 5 / 9;
      expect(result, closeTo(37.0, 0.1));
    });

    test('Celsius to Fahrenheit conversion formula', () {
      // Test known conversion values
      // 0°C = 32°F
      double result = 0 * 9 / 5 + 32;
      expect(result, 32.0);
      
      // 100°C = 212°F
      result = 100 * 9 / 5 + 32;
      expect(result, 212.0);
      
      // 37°C = 98.6°F
      result = 37 * 9 / 5 + 32;
      expect(result, 98.6);
    });

    test('Negative temperature conversions', () {
      // -40°F = -40°C (special case where both scales meet)
      double result = (-40 - 32) * 5 / 9;
      expect(result, -40.0);
      
      // -40°C = -40°F
      result = -40 * 9 / 5 + 32;
      expect(result, -40.0);
    });
  });

  group('Responsive Design Tests', () {
    testWidgets('Portrait orientation layout', (WidgetTester tester) async {
      // Set portrait orientation
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(const TemperatureConverterApp());
      
      // Verify SliverAppBar is used in portrait mode
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('Landscape orientation layout', (WidgetTester tester) async {
      // Set landscape orientation
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(const TemperatureConverterApp());
      
      // Verify Row layout is used in landscape mode
      expect(find.byType(Row), findsWidgets);
      
      // Clean up
      addTearDown(tester.view.reset);
    });
  });

  group('Input Validation Tests', () {
    testWidgets('Accepts valid decimal numbers', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());
      
      final temperatureField = find.byType(TextFormField);
      
      // Test various valid inputs
      const validInputs = ['123', '123.45', '-10', '-10.5', '0', '0.0'];
      
      for (String input in validInputs) {
        await tester.enterText(temperatureField, input);
        await tester.tap(find.text('CONVERT'));
        await tester.pumpAndSettle();
        
        // Should not show error message for valid inputs
        expect(find.text('Please enter a valid number'), findsNothing);
        
        // Clear for next test
        await tester.tap(find.text('CLEAR'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Rejects invalid inputs', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());
      
      final temperatureField = find.byType(TextFormField);
      
      // Test invalid inputs
      const invalidInputs = ['abc', '12.34.56', '--10', '++5'];
      
      for (String input in invalidInputs) {
        await tester.enterText(temperatureField, input);
        await tester.tap(find.text('CONVERT'));
        await tester.pumpAndSettle();
        
        // Should show error message for invalid inputs
        expect(find.text('Please enter a valid number'), findsOneWidget);
        
        // Dismiss snackbar and clear for next test
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('CLEAR'));
        await tester.pumpAndSettle();
      }
    });
  });
}
