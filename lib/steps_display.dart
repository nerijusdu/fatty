import 'dart:ui';

import 'package:flutter/material.dart';

class StepsDisplay extends StatelessWidget {
  const StepsDisplay({
    super.key,
    required this.steps,
    this.label,
  });

  final int steps;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.pinkAccent,
        child: SizedBox(
          width: 500,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (label != null)
                Text(
                  label!,
                  textScaleFactor: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              Text(
                '$steps',
                textScaleFactor: 2,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
