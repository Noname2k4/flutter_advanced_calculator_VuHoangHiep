import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/calculator_mode.dart';
import '../providers/calculator_provider.dart';
import 'calculator_button.dart';

class ButtonGrid extends StatelessWidget {
  final Function(String) onPressed;

  const ButtonGrid({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cal = Provider.of<CalculatorProvider>(context);

    List<String> nut = [];
    int cot = 4;

    if (cal.mode == CalculatorMode.basic) {
      cot = 4;
      nut = [
        'C',
        'CE',
        '%',
        '÷',
        '7',
        '8',
        '9',
        '×',
        '4',
        '5',
        '6',
        '-',
        '1',
        '2',
        '3',
        '+',
        '±',
        '0',
        '.',
        '='
      ];
    } else if (cal.mode == CalculatorMode.scientific) {
      cot = 6;
      nut = [
        '2nd',
        'sin',
        'cos',
        'tan',
        'Ln',
        'log',
        'x²',
        '√',
        'x^y',
        '(',
        ')',
        '÷',
        'MC',
        '7',
        '8',
        '9',
        'C',
        '×',
        'MR',
        '4',
        '5',
        '6',
        'CE',
        '-',
        'M+',
        '1',
        '2',
        '3',
        '%',
        '+',
        'M-',
        '±',
        '0',
        '.',
        'Π',
        '='
      ];
    } else {
      cot = 4;

      nut = [
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        '(',
        ')',
        'AND',
        'OR',
        'XOR',
        'NOT',
        '<<',
        '>>',
        '×',
        '÷',
        '7',
        '8',
        '9',
        '+',
        '4',
        '5',
        '6',
        '-',
        '1',
        '2',
        '3',
        '=',
        '0',
        'C',
        'CE',
        'HEX'
      ];
    }

    return GridView.builder(
      itemCount: nut.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cot,
      ),
      itemBuilder: (context, index) {
        return CalculatorButton(
          text: nut[index],
          onTap: () => onPressed(nut[index]),
        );
      },
    );
  }
}
