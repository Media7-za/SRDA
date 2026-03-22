import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const int itemCount = 0; // Loading logic will be added

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery History')),
      body: itemCount == 0
          ? const Center(
              child: Text(
                'No history yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              itemCount: itemCount,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) => const ListTile(),
            ),
    );
  }
}
