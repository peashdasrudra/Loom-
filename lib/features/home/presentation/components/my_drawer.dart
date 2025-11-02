import 'package:flutter/material.dart';
import 'package:loom/features/home/presentation/components/my_drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              // logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Image.asset('assets/images/logo.jpg', height: 80),
              ),
              // Divide line
              Divider(
                color: Theme.of(context).colorScheme.primary,
                thickness: 1,
              ),

              // home tile
              MyDrawerTile(
                title: 'H O M E',
                icon: Icons.home,
                onTap: () => Navigator.of(context).pop(),
              ),

              // profile tile
              MyDrawerTile(
                title: 'P O F I L E',
                icon: Icons.person,
                onTap: () {},
              ),
              // search tile
              MyDrawerTile(
                title: 'S E A R C H',
                icon: Icons.search,
                onTap: () {},
              ),
              // settings tile
              MyDrawerTile(
                title: 'S E T T I N G S',
                icon: Icons.settings,
                onTap: () {},
              ),

              // about tile
              MyDrawerTile(title: 'A B O U T', icon: Icons.info, onTap: () {}),

              const Spacer(),

              // logout tile
              MyDrawerTile(
                title: 'L O G O U T',
                icon: Icons.logout,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
