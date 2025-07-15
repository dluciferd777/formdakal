class SocialUser {
  String profileImageUrl;
  String coverImageUrl;
  final String userName;
  final String userTag;
  String? bio; // Bio alanı eklendi
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
  final Map<String, String> socialLinks; // Genişletildi
  final List<String> photoUrls;
  bool isFollowing;
  final Map<String, bool> privacySettings;

  SocialUser({
    required this.profileImageUrl,
    required this.coverImageUrl,
    required this.userName,
    required this.userTag,
    this.bio, // Bio alanı eklendi
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

  // Sosyal medya link'lerinin tam URL'lerini döndürür
  String? getSocialMediaUrl(String platform) {
    final handle = socialLinks[platform];
    if (handle == null || handle.isEmpty) return null;
    
    switch (platform) {
      case 'instagram':
        return handle.startsWith('http') ? handle : 'https://instagram.com/$handle';
      case 'twitter':
        return handle.startsWith('http') ? handle : 'https://twitter.com/$handle';
      case 'youtube':
        return handle.startsWith('http') ? handle : 'https://youtube.com/@$handle';
      case 'facebook':
        return handle.startsWith('http') ? handle : 'https://facebook.com/$handle';
      case 'tiktok':
        return handle.startsWith('http') ? handle : 'https://tiktok.com/@$handle';
      case 'linkedin':
        return handle.startsWith('http') ? handle : 'https://linkedin.com/in/$handle';
      case 'github':
        return handle.startsWith('http') ? handle : 'https://github.com/$handle';
      case 'discord':
        return handle; // Discord için direkt handle gösterilir
      case 'twitch':
        return handle.startsWith('http') ? handle : 'https://twitch.tv/$handle';
      case 'snapchat':
        return handle.startsWith('http') ? handle : 'https://snapchat.com/add/$handle';
      case 'telegram':
        return handle.startsWith('http') ? handle : 'https://t.me/$handle';
      case 'whatsapp':
        return handle.startsWith('http') ? handle : 'https://wa.me/$handle';
      case 'spotify':
        return handle.startsWith('http') ? handle : 'https://open.spotify.com/user/$handle';
      case 'pinterest':
        return handle.startsWith('http') ? handle : 'https://pinterest.com/$handle';
      case 'reddit':
        return handle.startsWith('http') ? handle : 'https://reddit.com/u/$handle';
      case 'website':
        return handle.startsWith('http') ? handle : 'https://$handle';
      case 'email':
        return 'mailto:$handle';
      default:
        return handle.startsWith('http') ? handle : null;
    }
  }

  SocialUser copyWith({
    String? profileImageUrl,
    String? coverImageUrl,
    String? userName,
    String? userTag,
    String? bio,
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
      bio: bio ?? this.bio,
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