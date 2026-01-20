import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int posts;
  final int followers;
  final int following;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;

  const ProfileStats({
    super.key,
    required this.posts,
    required this.followers,
    required this.following,
    required this.onFollowersTap,
    required this.onFollowingTap,
  });

  Widget _item(String label, int value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _item('Posts', posts, () {}),
        _item('Followers', followers, onFollowersTap),
        _item('Following', following, onFollowingTap),
      ],
    );
  }
}
