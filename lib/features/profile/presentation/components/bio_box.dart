import 'package:flutter/material.dart';

class BioBox extends StatelessWidget {
  final String text;
  const BioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding inside
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        // color
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8.0),
      ),

      width: double.infinity,

      child: Center(
        child: Text(
          text.isNotEmpty ? text : 'No bio available...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
