import 'package:flutter/material.dart';

class DisplayArea extends StatelessWidget {
  final String phepTinh;
  final String ketQua;

  const DisplayArea({
    super.key,
    required this.phepTinh,
    required this.ketQua,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            phepTinh,
            style: const TextStyle(fontSize: 28, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            ketQua,
            style: const TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}