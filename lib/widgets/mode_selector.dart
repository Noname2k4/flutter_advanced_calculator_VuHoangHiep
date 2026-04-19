import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/calculator_provider.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cal = Provider.of<CalculatorProvider>(context);

    String text = "";

    if (cal.mode.name == "basic") {
      text = "Basic Mode";
    } else if (cal.mode.name == "scientific") {
      text = "Scientific Mode";
    } else {
      text = "Programmer Mode";
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            cal.chuyenMode();
          },
          child: Text(
            text,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}