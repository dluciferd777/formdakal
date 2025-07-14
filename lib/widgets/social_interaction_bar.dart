import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/social_post_model.dart';
import '../models/social_user_model.dart';
import '../providers/social_provider.dart';
import '../utils/color_themes.dart'; // FITNESS UYGULAMASI İÇİN

class SocialInteractionBar extends StatelessWidget {
  final SocialPost post;
  final SocialUser currentUser;

  const SocialInteractionBar({
    super.key, 
    required this.post,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = DynamicColors.primary; // FITNESS RENK SİSTEMİ
    final likeIcon = post.isLiked ? Icons.favorite : Icons.favorite_border;
    final likeColor = post.isLiked ? primaryColor : Colors.grey;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInteractionButton(
          context: context,
          icon: likeIcon,
          color: likeColor,
          text: post.likeCount.toString(),
          onTap: () {
            context.read<SocialProvider>().toggleLike(post.id);
          },
        ),
        _buildInteractionButton(
          context: context,
          icon: Icons.comment_outlined,
          text: post.commentCount.toString(),
          onTap: () {
            // Yorum sayfasına git - şimdilik boş
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Yorum özelliği yakında eklenecek!')),
            );
          },
        ),
        _buildInteractionButton(
          context: context,
          icon: Icons.share_outlined,
          text: 'Paylaş',
          onTap: () {
            String shareText = "FormdaKal'da harika bir fitness verisi gördüm!";
            if(post.text != null) {
              shareText = post.text!;
            } else if (post.type == PostType.fitnessStats) {
              shareText = "${post.userName} bugünkü fitness verilerini paylaştı!";
            }
            Share.share(shareText);
          },
        ),
      ],
    );
  }

  Widget _buildInteractionButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey, size: 22),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: color ?? Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}