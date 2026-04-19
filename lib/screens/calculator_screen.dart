import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/display_area.dart';
import '../widgets/button_grid.dart';
import '../widgets/mode_selector.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cal = Provider.of<CalculatorProvider>(context);
    final theme = Provider.of<ThemeProviderApp>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scientific Calculator"),
        actions: [
          TextButton(
            onPressed: () {
              cal.doiGoc();
            },
            child: Text(
              cal.laDo ? "DEG" : "RAD",
              style: const TextStyle(fontSize: 18),
            ),
          ),
          IconButton(
            onPressed: () {
              theme.doiTheme();
            },
            icon: const Icon(Icons.dark_mode),
          ),
        ],
      ),
      body: Column(
        children: [
          const ModeSelector(),

          Expanded(
            child: DisplayArea(
              phepTinh: cal.phepTinh,
              ketQua: cal.ketQua,
            ),
          ),

          Expanded(
            flex: 2,
            child: ButtonGrid(
              onPressed: cal.bamNut,
            ),
          ),
        ],
      ),
    );
  }
}