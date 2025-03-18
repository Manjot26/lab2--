Done by Manjot 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Desktop Calculator',
      theme: ThemeData.dark(),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';
  String input = '';
  double? num1;
  double? num2;
  String? operator;
  
  @override
  void initState() {
    super.initState();
    _loadLastResult();
  }

  Future<void> _loadLastResult() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      display = prefs.getString('lastResult') ?? '0';
    });
  }

  Future<void> _saveLastResult(String result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastResult', result);
  }

  void _onPressed(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        num1 = num2 = null;
        operator = null;
        display = '0';
      } else if (value == 'CE') {
        input = '';
        display = '0';
      } else if (['+', '-', '*', '/'].contains(value)) {
        if (input.isNotEmpty) {
          num1 = double.tryParse(input);
          operator = value;
          input = '';
        }
      } else if (value == '=') {
        if (num1 != null && input.isNotEmpty) {
          num2 = double.tryParse(input);
          double result = 0;
          if (operator == '+') result = num1! + num2!;
          if (operator == '-') result = num1! - num2!;
          if (operator == '*') result = num1! * num2!;
          if (operator == '/') {
            if (num2 == 0) {
              display = 'ERROR';
              return;
            }
            result = num1! / num2!;
          }
          display = result.toStringAsFixed(2);
          _saveLastResult(display);
          num1 = result;
          input = '';
        }
      } else {
        input += value;
        display = input;
      }
    });
  }

  Widget _buildButton(String text) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _onPressed(text),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(24),
          textStyle: TextStyle(fontSize: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.centerRight,
              child: Text(
                display,
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            ...[
              ['1', '2', '3', '+'],
              ['4', '5', '6', '-'],
              ['7', '8', '9', '*'],
              ['CE', '0', 'C', '/'],
              ['=']
            ].map((row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((button) => _buildButton(button)).toList(),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
