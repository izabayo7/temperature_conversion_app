import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TemperatureConverterApp());
}

/// Main application widget with custom theming
class TemperatureConverterApp extends StatelessWidget {
  const TemperatureConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      home: const TemperatureConverterScreen(),
    );
  }

  /// Creates a custom dark theme with modern design elements
  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C63FF),
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFF6C63FF),
        secondary: const Color(0xFF03DAC6),
        surface: const Color(0xFF1E1E1E),
        surfaceContainerHighest: const Color(0xFF2D2D2D),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

/// Model class to represent a conversion entry in history
class ConversionEntry {
  final String fromUnit;
  final String toUnit;
  final double inputValue;
  final double outputValue;
  final DateTime timestamp;

  ConversionEntry({
    required this.fromUnit,
    required this.toUnit,
    required this.inputValue,
    required this.outputValue,
    required this.timestamp,
  });

  /// Formats the conversion entry for display
  String get displayText {
    return '${fromUnit.substring(0, 1)} to ${toUnit.substring(0, 1)}: ${inputValue.toStringAsFixed(1)} => ${outputValue.toStringAsFixed(2)}';
  }
}

/// Main temperature converter screen with stateful widgets
class TemperatureConverterScreen extends StatefulWidget {
  const TemperatureConverterScreen({super.key});

  @override
  State<TemperatureConverterScreen> createState() => _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen>
    with TickerProviderStateMixin {
  
  // Controllers and state variables
  final TextEditingController _temperatureController = TextEditingController();
  final FocusNode _temperatureFocusNode = FocusNode();
  
  String _selectedConversion = 'Fahrenheit to Celsius';
  double? _convertedValue;
  List<ConversionEntry> _conversionHistory = [];
  
  // Animation controllers for enhanced UX
  late AnimationController _scaleAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _temperatureController.addListener(_onTemperatureChanged);
  }

  /// Initialize animation controllers for smooth UI transitions
  void _initializeAnimations() {
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleAnimationController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _temperatureFocusNode.dispose();
    _scaleAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  /// Listener for real-time input validation
  void _onTemperatureChanged() {
    setState(() {
      _convertedValue = null; // Clear result when input changes
    });
  }

  /// Performs temperature conversion based on selected mode
  void _performConversion() {
    if (_temperatureController.text.isEmpty) {
      _showErrorSnackBar('Please enter a temperature value');
      return;
    }

    final double? inputTemp = double.tryParse(_temperatureController.text);
    if (inputTemp == null) {
      _showErrorSnackBar('Please enter a valid number');
      return;
    }

    // Add haptic feedback for better user experience
    HapticFeedback.lightImpact();
    
    // Trigger button press animation
    _scaleAnimationController.forward().then((_) {
      _scaleAnimationController.reverse();
    });

    double result;
    String fromUnit, toUnit;

    if (_selectedConversion == 'Fahrenheit to Celsius') {
      // Formula: °C = (°F - 32) × 5/9
      result = (inputTemp - 32) * 5 / 9;
      fromUnit = 'Fahrenheit';
      toUnit = 'Celsius';
    } else {
      // Formula: °F = °C × 9/5 + 32
      result = inputTemp * 9 / 5 + 32;
      fromUnit = 'Celsius';
      toUnit = 'Fahrenheit';
    }

    setState(() {
      _convertedValue = result;
      _addToHistory(fromUnit, toUnit, inputTemp, result);
    });

    // Trigger result fade-in animation
    _fadeAnimationController.reset();
    _fadeAnimationController.forward();
  }

  /// Adds conversion result to history with proper validation
  void _addToHistory(String fromUnit, String toUnit, double input, double output) {
    final entry = ConversionEntry(
      fromUnit: fromUnit,
      toUnit: toUnit,
      inputValue: input,
      outputValue: output,
      timestamp: DateTime.now(),
    );

    _conversionHistory.insert(0, entry); // Add to beginning for recent-first order
    
    // Limit history to prevent memory issues
    if (_conversionHistory.length > 20) {
      _conversionHistory = _conversionHistory.take(20).toList();
    }
  }

  /// Shows error messages with consistent styling
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Clears all user inputs and results
  void _clearAll() {
    setState(() {
      _temperatureController.clear();
      _convertedValue = null;
    });
    _temperatureFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? _buildPortraitLayout()
                : _buildLandscapeLayout();
          },
        ),
      ),
    );
  }

  /// Builds the UI layout for portrait orientation
  Widget _buildPortraitLayout() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildConverterCard(),
              const SizedBox(height: 24),
              _buildResultCard(),
              const SizedBox(height: 24),
              _buildHistoryCard(),
            ]),
          ),
        ),
      ],
    );
  }

  /// Builds the UI layout for landscape orientation
  Widget _buildLandscapeLayout() {
    return Column(
      children: [
        _buildCompactAppBar(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildConverterCard(),
                      const SizedBox(height: 16),
                      _buildResultCard(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildHistoryCard(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Creates an animated sliver app bar for portrait mode
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Temperature Converter',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.thermostat,
              size: 48,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a compact app bar for landscape mode
  Widget _buildCompactAppBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          'Temperature Converter',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Builds the main converter input card with enhanced styling
  Widget _buildConverterCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Conversion',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildConversionSelector(),
            const SizedBox(height: 20),
            _buildTemperatureInput(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Creates radio button selector for conversion type
  Widget _buildConversionSelector() {
    return Column(
      children: [
        _buildRadioOption('Fahrenheit to Celsius'),
        _buildRadioOption('Celsius to Fahrenheit'),
      ],
    );
  }

  /// Helper method to create individual radio button options
  Widget _buildRadioOption(String option) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedConversion == option
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 2,
        ),
        color: _selectedConversion == option
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : null,
      ),
      child: RadioListTile<String>(
        title: Text(
          option,
          style: TextStyle(
            fontWeight: _selectedConversion == option ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        value: option,
        groupValue: _selectedConversion,
        onChanged: (value) {
          setState(() {
            _selectedConversion = value!;
            _convertedValue = null; // Clear result when conversion type changes
          });
          HapticFeedback.selectionClick();
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Creates the temperature input field with validation
  Widget _buildTemperatureInput() {
    return TextFormField(
      controller: _temperatureController,
      focusNode: _temperatureFocusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: 'Enter Temperature',
        hintText: _selectedConversion == 'Fahrenheit to Celsius' ? 'e.g., 72.5' : 'e.g., 22.8',
        prefixIcon: Icon(
          Icons.thermostat,
          color: Theme.of(context).colorScheme.primary,
        ),
        suffixText: _selectedConversion == 'Fahrenheit to Celsius' ? '°F' : '°C',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      onFieldSubmitted: (_) => _performConversion(),
    );
  }

  /// Creates action buttons with animations
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ElevatedButton.icon(
              onPressed: _performConversion,
              icon: const Icon(Icons.calculate),
              label: const Text(
                'CONVERT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _clearAll,
          icon: const Icon(Icons.clear),
          label: const Text('CLEAR'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }

  /// Builds the result display card with animation
  Widget _buildResultCard() {
    if (_convertedValue == null) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Result',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildResultDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates the formatted result display
  Widget _buildResultDisplay() {
    final String inputValue = _temperatureController.text;
    final String inputUnit = _selectedConversion == 'Fahrenheit to Celsius' ? '°F' : '°C';
    final String outputUnit = _selectedConversion == 'Fahrenheit to Celsius' ? '°C' : '°F';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$inputValue$inputUnit',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.arrow_forward,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
          ),
          Text(
            '${_convertedValue!.toStringAsFixed(2)}$outputUnit',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the conversion history card
  Widget _buildHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_conversionHistory.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _conversionHistory.clear();
                      });
                    },
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  /// Creates the scrollable history list
  Widget _buildHistoryList() {
    if (_conversionHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.history_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No conversions yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start converting to see your history here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        itemCount: _conversionHistory.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = _conversionHistory[index];
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            title: Text(
              entry.displayText,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: Icon(
              Icons.trending_flat,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          );
        },
      ),
    );
  }
}
