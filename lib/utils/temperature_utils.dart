/// Utility class for temperature conversion calculations
/// 
/// This class provides static methods for converting between different
/// temperature scales with high precision and proper error handling.
class TemperatureConverter {
  /// Converts Fahrenheit to Celsius using the standard formula
  /// 
  /// Formula: °C = (°F - 32) × 5/9
  /// 
  /// [fahrenheit] The temperature value in Fahrenheit
  /// Returns the equivalent temperature in Celsius
  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  /// Converts Celsius to Fahrenheit using the standard formula
  /// 
  /// Formula: °F = °C × 9/5 + 32
  /// 
  /// [celsius] The temperature value in Celsius
  /// Returns the equivalent temperature in Fahrenheit
  static double celsiusToFahrenheit(double celsius) {
    return celsius * 9 / 5 + 32;
  }

  /// Validates if a string can be parsed as a valid temperature value
  /// 
  /// [value] The string to validate
  /// Returns true if the string represents a valid number
  static bool isValidTemperature(String value) {
    if (value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  /// Formats a temperature value to the specified number of decimal places
  /// 
  /// [value] The temperature value to format
  /// [decimalPlaces] Number of decimal places (default: 2)
  /// Returns formatted string representation
  static String formatTemperature(double value, {int decimalPlaces = 2}) {
    return value.toStringAsFixed(decimalPlaces);
  }

  /// Gets the unit symbol for a given temperature scale
  /// 
  /// [scale] The temperature scale ('Celsius' or 'Fahrenheit')
  /// Returns the appropriate unit symbol
  static String getUnitSymbol(String scale) {
    switch (scale.toLowerCase()) {
      case 'celsius':
        return '°C';
      case 'fahrenheit':
        return '°F';
      default:
        return '°';
    }
  }
}

/// Utility class for input validation and formatting
class InputValidator {
  /// Regular expression for validating decimal numbers (including negative)
  static final RegExp _numberRegex = RegExp(r'^-?\d*\.?\d*$');

  /// Validates if input matches the allowed number format
  /// 
  /// [input] The input string to validate
  /// Returns true if input is valid numeric format
  static bool isValidNumberFormat(String input) {
    return _numberRegex.hasMatch(input);
  }

  /// Sanitizes input to remove invalid characters
  /// 
  /// [input] The raw input string
  /// Returns sanitized string with only valid characters
  static String sanitizeNumericInput(String input) {
    return input.replaceAll(RegExp(r'[^0-9.-]'), '');
  }

  /// Checks if input represents a reasonable temperature value
  /// 
  /// [value] The temperature value to check
  /// [scale] The temperature scale ('Celsius' or 'Fahrenheit')
  /// Returns true if temperature is within reasonable bounds
  static bool isReasonableTemperature(double value, String scale) {
    switch (scale.toLowerCase()) {
      case 'celsius':
        // Reasonable range: -273.15°C (absolute zero) to 1000°C
        return value >= -273.15 && value <= 1000;
      case 'fahrenheit':
        // Reasonable range: -459.67°F (absolute zero) to 1832°F
        return value >= -459.67 && value <= 1832;
      default:
        return true;
    }
  }
}

/// Utility class for string formatting and display
class DisplayFormatter {
  /// Formats conversion result for display
  /// 
  /// [inputValue] The original input value
  /// [outputValue] The converted output value
  /// [fromUnit] The source temperature unit
  /// [toUnit] The target temperature unit
  /// Returns formatted display string
  static String formatConversionResult({
    required double inputValue,
    required double outputValue,
    required String fromUnit,
    required String toUnit,
  }) {
    final fromSymbol = TemperatureConverter.getUnitSymbol(fromUnit);
    final toSymbol = TemperatureConverter.getUnitSymbol(toUnit);
    final formattedInput = TemperatureConverter.formatTemperature(inputValue, decimalPlaces: 1);
    final formattedOutput = TemperatureConverter.formatTemperature(outputValue);
    
    return '$formattedInput$fromSymbol → $formattedOutput$toSymbol';
  }

  /// Formats history entry for display
  /// 
  /// [fromUnit] The source temperature unit
  /// [toUnit] The target temperature unit
  /// [inputValue] The original input value
  /// [outputValue] The converted output value
  /// Returns formatted history string
  static String formatHistoryEntry({
    required String fromUnit,
    required String toUnit,
    required double inputValue,
    required double outputValue,
  }) {
    final fromInitial = fromUnit.substring(0, 1);
    final toInitial = toUnit.substring(0, 1);
    final formattedInput = TemperatureConverter.formatTemperature(inputValue, decimalPlaces: 1);
    final formattedOutput = TemperatureConverter.formatTemperature(outputValue);
    
    return '$fromInitial to $toInitial: $formattedInput => $formattedOutput';
  }

  /// Gets appropriate hint text for temperature input
  /// 
  /// [conversionType] The current conversion type
  /// Returns appropriate hint text
  static String getInputHintText(String conversionType) {
    switch (conversionType) {
      case 'Fahrenheit to Celsius':
        return 'e.g., 72.5';
      case 'Celsius to Fahrenheit':
        return 'e.g., 22.8';
      default:
        return 'Enter temperature value';
    }
  }

  /// Gets the appropriate suffix for temperature input field
  /// 
  /// [conversionType] The current conversion type
  /// Returns unit suffix string
  static String getInputSuffix(String conversionType) {
    switch (conversionType) {
      case 'Fahrenheit to Celsius':
        return '°F';
      case 'Celsius to Fahrenheit':
        return '°C';
      default:
        return '°';
    }
  }
}

/// Constants used throughout the application
class AppConstants {
  /// Maximum number of history entries to keep
  static const int maxHistoryEntries = 20;

  /// Default decimal places for temperature display
  static const int defaultDecimalPlaces = 2;

  /// Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);

  /// Temperature conversion types
  static const String fahrenheitToCelsius = 'Fahrenheit to Celsius';
  static const String celsiusToFahrenheit = 'Celsius to Fahrenheit';

  /// Error messages
  static const String emptyInputError = 'Please enter a temperature value';
  static const String invalidNumberError = 'Please enter a valid number';
  static const String unreasonableValueError = 'Temperature value seems unreasonable';

  /// Theme colors (as hex strings for documentation)
  static const String primaryColor = '#6C63FF';
  static const String secondaryColor = '#03DAC6';
  static const String surfaceColor = '#1E1E1E';
  static const String surfaceVariantColor = '#2D2D2D';
}
