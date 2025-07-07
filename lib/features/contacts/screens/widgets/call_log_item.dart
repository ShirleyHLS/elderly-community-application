import 'package:flutter/material.dart';

class CallLogItem extends StatelessWidget {
  final String date;
  final String status;

  const CallLogItem({
    super.key,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: status == 'Missed' ? Icon(Icons.call_missed, color: Colors.red):Icon(Icons.call_received, color: Colors.green),
        title: Text(date, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(status, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: status == 'Missed' ? Colors.red : Colors.green)),
      ),
    );
  }
}