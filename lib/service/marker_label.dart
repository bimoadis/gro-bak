import 'package:flutter/material.dart';

class MarkerLabel extends StatelessWidget {
  final Widget label;
  final Color color;

  const MarkerLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: label,
    );
  }
}
