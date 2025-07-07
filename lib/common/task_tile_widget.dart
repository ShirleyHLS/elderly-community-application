import 'package:flutter/material.dart';

class TaskTileWidget extends StatelessWidget {
  const TaskTileWidget({
    super.key,
    required this.title,
    required this.isDone,
    required this.time,
  });

  final String title;
  final bool isDone;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: isDone ? Colors.green : Colors.grey),
          // Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge),
                Text(time, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
