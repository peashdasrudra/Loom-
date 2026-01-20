import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loom/features/profile/domain/entities/profile_user.dart';

class UserTile extends StatelessWidget {
  final ProfileUser user;

  final VoidCallback onTap;

  const UserTile({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: CachedNetworkImageProvider(
          user.profileImageUrl.isNotEmpty
              ? user.profileImageUrl
              : 'https://via.placeholder.com/150',
        ),
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        user.email,
        style: TextStyle(color: theme.colorScheme.primary.withOpacity(0.7)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
