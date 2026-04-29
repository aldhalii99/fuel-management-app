import 'package:flutter/material.dart';
import '../../db/database_helper.dart';

class FuelScreen extends StatefulWidget {
  const FuelScreen({super.key});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  final List<Map<String, dynamic>> _fuels = [
    {'id': 1, 'name': 'ديزل', 'unit': 'لتر', 'color': Colors.orange},
    {'id': 2, 'name': 'بترول', 'unit': 'لتر', 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة أنواع الوقود'),
      ),
      body: ListView.builder(
        itemCount: _fuels.length,
        itemBuilder: (context, index) {
          final fuel = _fuels[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: fuel['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_gas_station,
                  color: fuel['color'],
                ),
              ),
              title: Text(fuel['name']),
              subtitle: Text('الوحدة: ${fuel['unit']}'),
              trailing: const Icon(Icons.chevron_left),
            ),
          );
        },
      ),
    );
  }
}