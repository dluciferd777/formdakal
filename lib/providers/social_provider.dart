import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../models/social_post_model.dart';
import '../models/social_user_model.dart';

class SocialProvider with ChangeNotifier {
  final List<SocialPost> _posts = [];

  List<SocialPost> get posts => _posts;

  SocialPost getPostById(String postId) {
    return _posts.firstWhere((p) => p.id == postId, orElse: () => throw Exception('Post not found'));
  }

  void addPost(SocialPost post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void deletePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }

  void updatePost(String postId, String newText) {
    try {
      final post = getPostById(postId);
      post.text = newText;
      notifyListeners();
    } catch (e) {
      // Post bulunamadı
    }
  }

  void toggleLike(String postId) {
    try {
      final post = getPostById(postId);
      post.isLiked = !post.isLiked;
      post.isLiked ? post.likeCount++ : post.likeCount--;
      notifyListeners();
    } catch (e) {
      // Post bulunamadı
    }
  }

  void addComment(String postId, Comment comment) {
    try {
      final post = getPostById(postId);
      post.comments.add(comment);
      post.commentCount++;
      notifyListeners();
    } catch (e) {
      // Post bulunamadı
    }
  }

  void updateUserInfoInPosts(SocialUser updatedUser) {
    for (var post in _posts) {
      if (post.userId == updatedUser.userTag) {
        post.userName = updatedUser.userName;
        post.userProfileImageUrl = updatedUser.profileImageUrl;
      }
    }
    notifyListeners();
  }
}