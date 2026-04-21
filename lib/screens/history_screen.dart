import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cal = Provider.of<CalculatorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch sử tính toán',
        ),
      ),
      body: cal.lichSu.isEmpty
          ? const Center(
              child: Text(
                'Chưa có lịch sử',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cal.lichSu.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.history,
                    ),
                    title: Text(
                      cal.lichSu[index],
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
