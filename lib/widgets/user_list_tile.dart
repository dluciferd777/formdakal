// lib/widgets/user_list_tile.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../utils/color_themes.dart';

class UserListTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onFollowToggled;

  const UserListTile({
    super.key,
    required this.user,
    required this.onFollowToggled,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = DynamicColors.primary;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[300],
        backgroundImage: user.profileImagePath != null && user.profileImagePath!.isNotEmpty
            ? CachedNetworkImageProvider(user.profileImagePath!)
            : null,
        child: user.profileImagePath == null || user.profileImagePath!.isEmpty
            ? Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
      title: Text(
        user.name, 
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        )
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${user.userTag}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              user.bio!,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              if (user.country != null && user.country!.isNotEmpty) ...[
                Icon(
                  Icons.location_on,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 2),
                Text(
                  user.country!,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (user.favoriteTeam != null && user.favoriteTeam!.isNotEmpty) ...[
                Icon(
                  Icons.sports_soccer,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 2),
                Text(
                  user.favoriteTeam!,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: SizedBox(
        width: 100,
        child: ElevatedButton(
          onPressed: onFollowToggled,
          style: ElevatedButton.styleFrom(
            backgroundColor: user.isFollowing ? Colors.grey[700] : primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: Text(
            user.isFollowing ? 'Takibi Bırak' : 'Takip Et',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}