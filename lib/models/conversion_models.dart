import '../utils/temperature_utils.dart';

/// Enumeration for supported temperature scales
enum TemperatureScale {
  celsius('Celsius'),
  fahrenheit('Fahrenheit');

  const TemperatureScale(this.displayName);

  /// Human-readable name for the temperature scale
  final String displayName;

  /// Gets the unit symbol for this temperature scale
  String get symbol => TemperatureConverter.getUnitSymbol(displayName);

  /// Gets the scale from a string representation
  static TemperatureScale fromString(String value) {
    switch (value.toLowerCase()) {
      case 'celsius':
        return TemperatureScale.celsius;
      case 'fahrenheit':
        return TemperatureScale.fahrenheit;
      default:
        throw ArgumentError('Unknown temperature scale: $value');
    }
  }
}

/// Enumeration for conversion directions
enum ConversionType {
  fahrenheitToCelsius('Fahrenheit to Celsius', TemperatureScale.fahrenheit, TemperatureScale.celsius),
  celsiusToFahrenheit('Celsius to Fahrenheit', TemperatureScale.celsius, TemperatureScale.fahrenheit);

  const ConversionType(this.displayName, this.fromScale, this.toScale);

  /// Human-readable name for the conversion type
  final String displayName;

  /// Source temperature scale
  final TemperatureScale fromScale;

  /// Target temperature scale
  final TemperatureScale toScale;

  /// Performs the conversion calculation
  double convert(double inputValue) {
    switch (this) {
      case ConversionType.fahrenheitToCelsius:
        return TemperatureConverter.fahrenheitToCelsius(inputValue);
      case ConversionType.celsiusToFahrenheit:
        return TemperatureConverter.celsiusToFahrenheit(inputValue);
    }
  }

  /// Gets conversion type from display name
  static ConversionType fromDisplayName(String displayName) {
    for (ConversionType type in ConversionType.values) {
      if (type.displayName == displayName) {
        return type;
      }
    }
    throw ArgumentError('Unknown conversion type: $displayName');
  }
}

/// Model class representing a single temperature conversion entry
/// 
/// This class encapsulates all information about a temperature conversion
/// including input/output values, units, and timestamp for history tracking.
class ConversionEntry {
  /// The conversion type used for this entry
  final ConversionType conversionType;

  /// The original input temperature value
  final double inputValue;

  /// The calculated output temperature value
  final double outputValue;

  /// Timestamp when this conversion was performed
  final DateTime timestamp;

  /// Creates a new conversion entry
  /// 
  /// [conversionType] The type of conversion performed
  /// [inputValue] The original temperature value entered by user
  /// [outputValue] The calculated result of the conversion
  /// [timestamp] When the conversion was performed (defaults to now)
  ConversionEntry({
    required this.conversionType,
    required this.inputValue,
    required this.outputValue,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Gets the source temperature unit for this conversion
  String get fromUnit => conversionType.fromScale.displayName;

  /// Gets the target temperature unit for this conversion
  String get toUnit => conversionType.toScale.displayName;

  /// Gets the source temperature unit symbol
  String get fromSymbol => conversionType.fromScale.symbol;

  /// Gets the target temperature unit symbol
  String get toSymbol => conversionType.toScale.symbol;

  /// Formats the conversion entry for display in history
  /// 
  /// Returns a string in the format: "F to C: 72.5 => 22.50"
  String get displayText {
    return DisplayFormatter.formatHistoryEntry(
      fromUnit: fromUnit,
      toUnit: toUnit,
      inputValue: inputValue,
      outputValue: outputValue,
    );
  }

  /// Formats the conversion for detailed display
  /// 
  /// Returns a string in the format: "72.5°F → 22.50°C"
  String get detailedDisplayText {
    return DisplayFormatter.formatConversionResult(
      inputValue: inputValue,
      outputValue: outputValue,
      fromUnit: fromUnit,
      toUnit: toUnit,
    );
  }

  /// Checks if this conversion is equal to another
  /// 
  /// Two conversions are considered equal if they have the same
  /// conversion type, input value, and output value
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversionEntry &&
        other.conversionType == conversionType &&
        other.inputValue == inputValue &&
        other.outputValue == outputValue;
  }

  /// Generates hash code for this conversion entry
  @override
  int get hashCode {
    return Object.hash(conversionType, inputValue, outputValue);
  }

  /// String representation of this conversion entry
  @override
  String toString() {
    return 'ConversionEntry('
        'type: ${conversionType.displayName}, '
        'input: $inputValue${fromSymbol}, '
        'output: ${outputValue.toStringAsFixed(2)}${toSymbol}, '
        'timestamp: ${timestamp.toIso8601String()}'
        ')';
  }

  /// Creates a copy of this conversion entry with optional parameter overrides
  /// 
  /// This is useful for creating modified versions of existing entries
  ConversionEntry copyWith({
    ConversionType? conversionType,
    double? inputValue,
    double? outputValue,
    DateTime? timestamp,
  }) {
    return ConversionEntry(
      conversionType: conversionType ?? this.conversionType,
      inputValue: inputValue ?? this.inputValue,
      outputValue: outputValue ?? this.outputValue,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Creates a ConversionEntry from a JSON map
  /// 
  /// This could be useful for persistence or data transfer
  factory ConversionEntry.fromJson(Map<String, dynamic> json) {
    return ConversionEntry(
      conversionType: ConversionType.fromDisplayName(json['conversionType']),
      inputValue: json['inputValue'].toDouble(),
      outputValue: json['outputValue'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  /// Converts this ConversionEntry to a JSON map
  /// 
  /// This could be useful for persistence or data transfer
  Map<String, dynamic> toJson() {
    return {
      'conversionType': conversionType.displayName,
      'inputValue': inputValue,
      'outputValue': outputValue,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Model class for managing conversion history
/// 
/// This class provides functionality for maintaining a list of conversion
/// entries with automatic cleanup and utility methods for history management.
class ConversionHistory {
  /// Internal list of conversion entries
  final List<ConversionEntry> _entries = [];

  /// Maximum number of entries to keep in history
  final int maxEntries;

  /// Creates a new conversion history manager
  /// 
  /// [maxEntries] Maximum number of entries to keep (default: 20)
  ConversionHistory({this.maxEntries = AppConstants.maxHistoryEntries});

  /// Gets an immutable list of all conversion entries
  /// 
  /// Entries are ordered with most recent first
  List<ConversionEntry> get entries => List.unmodifiable(_entries);

  /// Gets the number of entries in history
  int get length => _entries.length;

  /// Checks if history is empty
  bool get isEmpty => _entries.isEmpty;

  /// Checks if history is not empty
  bool get isNotEmpty => _entries.isNotEmpty;

  /// Gets the most recent conversion entry
  /// 
  /// Returns null if history is empty
  ConversionEntry? get latest => _entries.isNotEmpty ? _entries.first : null;

  /// Adds a new conversion entry to history
  /// 
  /// The entry is added to the beginning of the list (most recent first).
  /// If the history exceeds maxEntries, oldest entries are removed.
  /// 
  /// [entry] The conversion entry to add
  void addEntry(ConversionEntry entry) {
    _entries.insert(0, entry);
    
    // Remove excess entries if we exceed the maximum
    if (_entries.length > maxEntries) {
      _entries.removeRange(maxEntries, _entries.length);
    }
  }

  /// Creates and adds a conversion entry from raw values
  /// 
  /// This is a convenience method for adding entries without creating
  /// a ConversionEntry object manually.
  /// 
  /// [conversionType] The type of conversion performed
  /// [inputValue] The original temperature value
  /// [outputValue] The calculated result
  void addConversion({
    required ConversionType conversionType,
    required double inputValue,
    required double outputValue,
  }) {
    final entry = ConversionEntry(
      conversionType: conversionType,
      inputValue: inputValue,
      outputValue: outputValue,
    );
    addEntry(entry);
  }

  /// Removes a specific entry from history
  /// 
  /// [entry] The entry to remove
  /// Returns true if the entry was found and removed
  bool removeEntry(ConversionEntry entry) {
    return _entries.remove(entry);
  }

  /// Removes an entry at a specific index
  /// 
  /// [index] The index of the entry to remove
  /// Returns the removed entry
  ConversionEntry removeAt(int index) {
    if (index < 0 || index >= _entries.length) {
      throw RangeError('Index out of range: $index');
    }
    return _entries.removeAt(index);
  }

  /// Clears all entries from history
  void clear() {
    _entries.clear();
  }

  /// Gets entries filtered by conversion type
  /// 
  /// [conversionType] The type of conversions to include
  /// Returns a list of entries matching the specified type
  List<ConversionEntry> getEntriesByType(ConversionType conversionType) {
    return _entries.where((entry) => entry.conversionType == conversionType).toList();
  }

  /// Gets entries within a specific date range
  /// 
  /// [startDate] The earliest date to include (inclusive)
  /// [endDate] The latest date to include (inclusive)
  /// Returns a list of entries within the date range
  List<ConversionEntry> getEntriesByDateRange(DateTime startDate, DateTime endDate) {
    return _entries.where((entry) {
      return entry.timestamp.isAfter(startDate.subtract(const Duration(milliseconds: 1))) &&
             entry.timestamp.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Gets statistics about the conversion history
  /// 
  /// Returns a map with various statistics about the conversions
  Map<String, dynamic> getStatistics() {
    if (_entries.isEmpty) {
      return {
        'totalConversions': 0,
        'fahrenheitToCelsiusCount': 0,
        'celsiusToFahrenheitCount': 0,
        'averageInputValue': 0.0,
        'averageOutputValue': 0.0,
      };
    }

    final fahrenheitToCelsiusEntries = getEntriesByType(ConversionType.fahrenheitToCelsius);
    final celsiusToFahrenheitEntries = getEntriesByType(ConversionType.celsiusToFahrenheit);

    final totalInputValue = _entries.fold<double>(0.0, (sum, entry) => sum + entry.inputValue);
    final totalOutputValue = _entries.fold<double>(0.0, (sum, entry) => sum + entry.outputValue);

    return {
      'totalConversions': _entries.length,
      'fahrenheitToCelsiusCount': fahrenheitToCelsiusEntries.length,
      'celsiusToFahrenheitCount': celsiusToFahrenheitEntries.length,
      'averageInputValue': totalInputValue / _entries.length,
      'averageOutputValue': totalOutputValue / _entries.length,
      'oldestEntry': _entries.last.timestamp,
      'newestEntry': _entries.first.timestamp,
    };
  }

  /// Exports history to a JSON-serializable format
  /// 
  /// Returns a list of maps that can be serialized to JSON
  List<Map<String, dynamic>> toJson() {
    return _entries.map((entry) => entry.toJson()).toList();
  }

  /// Imports history from a JSON-serializable format
  /// 
  /// [jsonList] List of maps representing conversion entries
  /// [clearExisting] Whether to clear existing entries before importing
  void fromJson(List<Map<String, dynamic>> jsonList, {bool clearExisting = true}) {
    if (clearExisting) {
      clear();
    }

    for (final json in jsonList) {
      try {
        final entry = ConversionEntry.fromJson(json);
        _entries.add(entry);
      } catch (e) {
        // Skip invalid entries but continue processing
        continue;
      }
    }

    // Sort by timestamp (newest first) and limit to maxEntries
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (_entries.length > maxEntries) {
      _entries.removeRange(maxEntries, _entries.length);
    }
  }
}
