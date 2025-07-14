import 'comment_model.dart';

enum PostType { workout, text, youtubeVideo, image, fitnessStats }

// Fitness verilerini paylaşmak için özel sınıf
class FitnessStatsData {
  final int? steps;
  final double? consumedCalories;
  final double? burnedCalories;
  final double? waterIntake;
  final double? stepProgress;
  final double? consumedCalorieProgress;
  final double? burnedCalorieProgress;
  final double? waterProgress;

  FitnessStatsData({
    this.steps,
    this.consumedCalories,
    this.burnedCalories,
    this.waterIntake,
    this.stepProgress,
    this.consumedCalorieProgress,
    this.burnedCalorieProgress,
    this.waterProgress,
  });
}

class SocialPost {
  final String id;
  final String userId;
  String userName;
  String userProfileImageUrl;
  final PostType type;
  final DateTime timestamp;
  
  final FitnessStatsData? fitnessData; 
  String? text;
  final String? youtubeVideoId;
  final String? imagePath;
  final List<String>? allowedUserTags;

  int likeCount;
  int commentCount;
  bool isLiked;
  final List<Comment> comments;

  SocialPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImageUrl,
    required this.type,
    required this.timestamp,
    this.fitnessData,
    this.text,
    this.youtubeVideoId,
    this.imagePath,
    this.allowedUserTags,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    List<Comment>? comments,
  }) : comments = comments ?? [];
}