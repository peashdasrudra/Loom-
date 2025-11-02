import 'package:flutter/material.dart';

class MyDrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function()? onTap;
  const MyDrawerTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary , fontSize: 16, fontWeight: FontWeight.w500),
      ),
      leading: Icon(
        icon,
        size: 24,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: onTap,
    );
  }
}
