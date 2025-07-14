class SocialUser {
  String profileImageUrl;
  String coverImageUrl;
  final String userName;
  final String userTag;
  final int age;
  final double height;
  final double weight;
  final String favoriteSport;
  final String favoriteMeal;
  final String favoriteTeam;
  final String city;
  final String job;
  final String gym;
  final int followers;
  final int following;
  final Map<String, String> socialLinks;
  final List<String> photoUrls;
  bool isFollowing;
  final Map<String, bool> privacySettings;

  SocialUser({
    required this.profileImageUrl,
    required this.coverImageUrl,
    required this.userName,
    required this.userTag,
    required this.age,
    required this.height,
    required this.weight,
    required this.favoriteSport,
    required this.favoriteMeal,
    required this.favoriteTeam,
    required this.city,
    required this.job,
    required this.gym,
    this.followers = 0,
    this.following = 0,
    this.socialLinks = const {},
    this.photoUrls = const [],
    this.isFollowing = false,
    this.privacySettings = const {
      'infoVisible': true,
      'followVisible': true,
      'photosVisible': true,
    },
  });

  SocialUser copyWith({
    String? profileImageUrl,
    String? coverImageUrl,
    String? userName,
    String? userTag,
    int? age,
    double? height,
    double? weight,
    String? favoriteSport,
    String? favoriteMeal,
    String? favoriteTeam,
    String? city,
    String? job,
    String? gym,
    int? followers,
    int? following,
    bool? isFollowing,
    Map<String, String>? socialLinks,
    Map<String, bool>? privacySettings,
  }) {
    return SocialUser(
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      userName: userName ?? this.userName,
      userTag: userTag ?? this.userTag,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      favoriteSport: favoriteSport ?? this.favoriteSport,
      favoriteMeal: favoriteMeal ?? this.favoriteMeal,
      favoriteTeam: favoriteTeam ?? this.favoriteTeam,
      city: city ?? this.city,
      job: job ?? this.job,
      gym: gym ?? this.gym,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      socialLinks: socialLinks ?? this.socialLinks,
      photoUrls: photoUrls,
      isFollowing: isFollowing ?? this.isFollowing,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }
}