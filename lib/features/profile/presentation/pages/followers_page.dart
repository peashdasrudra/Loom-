import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:loom/features/profile/domain/entities/profile_user.dart';
import 'package:loom/features/profile/presentation/components/user_tile.dart';
import 'package:loom/features/profile/presentation/pages/profile_page.dart';

class FollowersPage extends StatelessWidget {
  final List<String> ids;
  final String title;

  const FollowersPage({super.key, required this.ids, required this.title});

  @override
  Widget build(BuildContext context) {
    if (ids.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('No $title yet')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: ids.length,
        itemBuilder: (_, index) {
          final uid = ids[index];

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get(),
            builder: (_, snap) {
              if (!snap.hasData) return const SizedBox();

              final user = ProfileUser.fromJson(
                uid,
                snap.data!.data() as Map<String, dynamic>,
              );

              return UserTile(
                user: user,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(uid: user.uid),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
