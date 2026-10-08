import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {

  bool _isDarkMode = false;

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }
  @override
  
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F5FA),
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121318),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOut,


      home: CalculatorPage(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  
  String _input = '';
  double? _firstOperand;
  String? _selectedOperator;
  String? _errorMessage;
  bool _showingResult = false;


  static const _buttonLabels = <String>[
    '7', '8', '9', '÷',
    '4', '5', '6', '×',
    '1', '2', '3', '−',
    'AC', '0', '=', '+',
  ];

  static const _operators = <String>['+', '−', '×', '÷'];

  void _onButtonPressed(String label) {
    
    setState(() {
      if (label == 'AC') {
        _clearAll();
      } else if (label == '=') {
        _calculate();
      } else if (_operators.contains(label)) {
        _chooseOperator(label);
      } else {
        _enterDigit(label);
      }
    });
  }

  void _clearAll() {
    _input = '';
    _firstOperand = null;
    _selectedOperator = null;
    _errorMessage = null;
    _showingResult = false;
  }

  void _enterDigit(String digit) {
    if (_showingResult) {
      _clearAll();
    }

    if (_input.length >= 12) {
      _errorMessage = 'use only 12 numbers or reset';
      return;
    }

    _errorMessage = null;
    _input = _input == '0' ? digit : _input + digit;
  }

  void _chooseOperator(String operator) {
    if (_selectedOperator != null) {
      if (_input.isEmpty) {
       
        _selectedOperator = operator;
        _errorMessage = null;
      } else {
        _errorMessage = 'pres = to finish or AC to reset';
      }
      return;
    }

    if (_input.isEmpty) {
      _errorMessage = 'Enter a number before choosing an operator.';
      return;
    }

    _firstOperand = double.parse(_input);
    _selectedOperator = operator;
    _input = '';
    _showingResult = false;
    _errorMessage = null;
  }

  void _calculate() {
    final first = _firstOperand;
    final operator = _selectedOperator;
     if (first == null || operator == null) {
      _errorMessage = 'enter a number or a operator first';
      return;
    }

  

    if (_input.isEmpty) {
      _errorMessage = 'Enter the second number then press =';
      return;
    }

    final second = double.parse(_input);
    double result;

    switch (operator) {
      case '+':
        result = first + second;
        break;
      case '−':
        result = first - second;
        break;
      case '×':
        result = first * second;
        break;
      case '÷':
        if (second == 0) {
          _errorMessage = 'You can not divide by zero';
          return;
        }
        result = first / second;
        break;
      default:
        _errorMessage = 'Choose an operator';
        return;
    }

    if (!result.isFinite) {
      _errorMessage = 'The result is too large';
      return;
    }

    _input = _formatNumber(result);
    _firstOperand = null;
    _selectedOperator = null;
    _showingResult = true;
    _errorMessage = null;
  }

  String _formatNumber(double value) {
    if (value == 0) {
      return '0';
    }
  
    return value.toString().replaceFirst(RegExp(r'\.0$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final display = _input.isEmpty ? '0' : _input;
    final first = _firstOperand;
    final operation = first != null && _selectedOperator != null
        ? '${_formatNumber(first)} $_selectedOperator'
        : (_showingResult ? 'Result' : 'Enter a number');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
        Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
        Tooltip(
          message: 'Night mode',
          child: Switch(
            key: const Key('theme_toggle'),
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
          ),
        ),
        const SizedBox(width: 8),
  ],
),
      body: SafeArea(
        
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          operation,
                          key: const Key('calculator_operation'),
                          textAlign: TextAlign.right,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),
                        Semantics(
                          liveRegion: true,
                          label: 'Calculator display',
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              display,
                              key: const Key('calculator_display'),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _errorMessage ?? 'Choose an operator between two numbers.',
                        key: const Key('calculator_message'),
                        style: TextStyle(
                          color: _errorMessage == null
                              ? colors.onSurfaceVariant
                              : colors.error,
                        ),
                      ),
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 4,
                    mainAxisExtent: 64,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _buttonLabels.map((label) {
                      final isOperator = _operators.contains(label);
                      final isSelected = label == _selectedOperator;
                      final isEquals = label == '=';

                      return CalculatorButton(
                        key: Key('button_$label'),
                        label: label,
                        onPressed: () => _onButtonPressed(label),
                        backgroundColor: isSelected || isEquals
                            ? colors.primary
                            : label == 'AC'
                                ? colors.errorContainer
                                : isOperator
                                    ? colors.secondaryContainer
                                    : colors.surface,
                          foregroundColor: isSelected || isEquals
                              ? colors.onPrimary
                              : label == 'AC'
                                  ? colors.onErrorContainer
                                  : isOperator
                                      ? colors.onSecondaryContainer
                                      : colors.onSurface,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  String get _spokenLabel {
    switch (label) {
      case 'AC': return 'All clear';
      case '+': return 'Add';
      case '−': return 'Subtract';
      case '×': return 'Multiply';
      case '÷': return 'Divide';
      case '=': return 'Equals';
      default: return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.all(8),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        
        splashFactory: InkRipple.splashFactory,
        animationDuration: const Duration(milliseconds: 150),
      ),
      onPressed: onPressed,
      child: Semantics(
        label: _spokenLabel,
        excludeSemantics: true,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
