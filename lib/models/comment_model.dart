class Comment {
  final String id;
  final String userName;
  final String userProfileImageUrl;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userName,
    required this.userProfileImageUrl,
    required this.text,
    required this.timestamp,
  });
}