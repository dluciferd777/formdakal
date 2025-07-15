// lib/widgets/social_post_card.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/social_post_model.dart';
import '../models/social_user_model.dart';
import '../models/comment_model.dart';
import '../providers/social_provider.dart';
import '../widgets/social_interaction_bar.dart';
import '../widgets/fitness_stats_card.dart';

class SocialPostCard extends StatelessWidget {
  final SocialPost post;
  final SocialUser currentUser;

  const SocialPostCard({
    super.key, 
    required this.post,
    required this.currentUser,
  });

  void _showOptions(BuildContext context) {
    if (post.userId != currentUser.userTag) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Wrap(
          children: <Widget>[
            if (post.type == PostType.text || post.type == PostType.image)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Düzenle'),
                onTap: () {
                  Navigator.pop(ctx);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Sil', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gönderiyi Sil'),
        content: const Text('Bu gönderiyi silmek istediğinden emin misin? Bu işlem geri alınamaz.'),
        actions: <Widget>[
          TextButton(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
            onPressed: () {
              context.read<SocialProvider>().deletePost(post.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  // YENİ: Yorum girişini gösteren metod
  void _showCommentInput(BuildContext context) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          // DÜZELTME: Bottom sheet'in klavye ve navigasyon barının üstünde kalması için padding
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(ctx).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView( // İçeriğin kaydırılabilir olmasını sağlar
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Yorum Ekle',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Yorumunuzu yazın...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (commentController.text.isNotEmpty) {
                            final newComment = Comment(
                              id: DateTime.now().toIso8601String(),
                              userName: currentUser.userName,
                              userProfileImageUrl: currentUser.profileImageUrl,
                              text: commentController.text,
                              timestamp: DateTime.now(),
                            );
                            context.read<SocialProvider>().addComment(post.id, newComment);
                            Navigator.pop(ctx);
                          }
                        },
                      ),
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 8),
                  if (post.comments.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Yorumlar (${post.comments.length})', style: Theme.of(ctx).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: post.comments.length,
                      itemBuilder: (context, index) {
                        final comment = post.comments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: CachedNetworkImageProvider(comment.userProfileImageUrl),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment.userName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      comment.text,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      _formatCommentDate(comment.timestamp),
                                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatCommentDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(context),
            const SizedBox(height: 12),
            _buildPostContent(context),
            const SizedBox(height: 8),
            const Divider(),
            SocialInteractionBar(
              post: post, 
              currentUser: currentUser,
              onCommentTap: () => _showCommentInput(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    final bool isPrivate = post.allowedUserTags != null && post.allowedUserTags!.isNotEmpty;
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: CachedNetworkImageProvider(post.userProfileImageUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text(
                    '${post.timestamp.hour}:${post.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isPrivate ? Icons.people : Icons.public,
                    size: 12,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPrivate ? 'Özel Kitle' : 'Herkese Açık',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  )
                ],
              ),
            ],
          ),
        ),
        if (post.userId == currentUser.userTag)
          IconButton(
            onPressed: () => _showOptions(context),
            icon: const Icon(Icons.more_horiz),
          ),
      ],
    );
  }

  Widget _buildPostContent(BuildContext context) {
    final textContent = post.text != null && post.text!.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              post.text!,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          )
        : const SizedBox.shrink();

    switch (post.type) {
      case PostType.fitnessStats:
        return FitnessStatsCard(fitnessData: post.fitnessData!);
      case PostType.text:
        return textContent;
      case PostType.youtubeVideo:
        final controller = YoutubePlayerController(
          initialVideoId: post.youtubeVideoId!,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: true,
          ),
        );
      case PostType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textContent,
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: kIsWeb
                  ? Image.network(
                      post.imagePath!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(post.imagePath!),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
          ],
        );
      case PostType.workout:
        return textContent;
    }
  }
}
