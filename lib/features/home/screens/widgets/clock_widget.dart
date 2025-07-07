import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Text(
          DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now()),
          style: Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}
