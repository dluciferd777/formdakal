// lib/screens/fit_profile_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/social_user_model.dart';
import '../models/social_post_model.dart';
import '../models/user_model.dart';
import '../providers/social_provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../utils/color_themes.dart';
import '../widgets/social_post_card.dart';
import '../widgets/fitness_share_sheet.dart';
import '../widgets/user_list_tile.dart';
import '../screens/edit_profile_page.dart';
import '../screens/search_page.dart';
import '../screens/privacy_settings_page.dart';

class FitProfileScreen extends StatefulWidget {
  const FitProfileScreen({super.key});

  @override
  State<FitProfileScreen> createState() => _FitProfileScreenState();
}

class _FitProfileScreenState extends State<FitProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late SocialUser _socialUser;
  final ImagePicker _picker = ImagePicker();
  final UserService _userService = UserService();
  late List<UserModel> _followingUsers;
  late List<UserModel> _followers;
  
  Map<String, bool> _privacySettings = {
    'infoVisible': true,
    'followVisible': true,
    'photosVisible': true,
    'profilePublic': true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeSocialUser();
    _followingUsers = _userService.getFollowingUsers();
    _followers = _userService.getFollowerUsers();
  }

  void _initializeSocialUser() {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;
    
    if (user != null) {
      _socialUser = SocialUser(
        userName: user.name,
        userTag: '@${user.userTag}',
        bio: user.bio,
        profileImageUrl: user.profileImagePath ?? 'https://i.pravatar.cc/150?img=27',
        coverImageUrl: user.coverImageUrl ?? 'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?fit=crop&w=1200&h=400&q=80',
        age: user.age,
        height: user.height,
        weight: user.weight,
        favoriteSport: user.favoriteSport ?? 'Henüz belirtilmemiş',
        favoriteMeal: user.favoriteMeal ?? 'Henüz belirtilmemiş',
        favoriteTeam: user.favoriteTeam ?? 'Henüz belirtilmemiş',
        city: user.country ?? 'Henüz belirtilmemiş',
        job: 'Fitness Tutkunu',
        gym: 'FormdaKal Ailesi',
        followers: 0,
        following: 0,
        socialLinks: {
          if (user.instagram != null && user.instagram!.isNotEmpty) 'instagram': user.instagram!,
          if (user.twitter != null && user.twitter!.isNotEmpty) 'twitter': user.twitter!,
          if (user.facebook != null && user.facebook!.isNotEmpty) 'facebook': user.facebook!,
          if (user.tiktok != null && user.tiktok!.isNotEmpty) 'tiktok': user.tiktok!,
          if (user.kick != null && user.kick!.isNotEmpty) 'kick': user.kick!,
          if (user.twitch != null && user.twitch!.isNotEmpty) 'twitch': user.twitch!,
          if (user.discord != null && user.discord!.isNotEmpty) 'discord': user.discord!,
          if (user.whatsapp != null && user.whatsapp!.isNotEmpty) 'whatsapp': user.whatsapp!,
          if (user.spotify != null && user.spotify!.isNotEmpty) 'spotify': user.spotify!,
        },
        photoUrls: List.generate(15, (index) => 'https://picsum.photos/seed/${index + 50}/500/500'),
      );
    } else {
      _socialUser = SocialUser(
        userName: 'Fitness Kullanıcı',
        userTag: '@fituser',
        bio: 'FormdaKal ile fitness yolculuğuma başladım!',
        profileImageUrl: 'https://i.pravatar.cc/150?img=27',
        coverImageUrl: 'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?fit=crop&w=1200&h=400&q=80',
        age: 25,
        height: 170,
        weight: 70,
        favoriteSport: 'Henüz belirtilmemiş',
        favoriteMeal: 'Henüz belirtilmemiş',
        favoriteTeam: 'Henüz belirtilmemiş',
        city: 'Henüz belirtilmemiş',
        job: 'Fitness Tutkunu',
        gym: 'FormdaKal Ailesi',
        followers: 0,
        following: 0,
        socialLinks: {},
        photoUrls: List.generate(15, (index) => 'https://picsum.photos/seed/${index + 50}/500/500'),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, {required bool isProfile}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final userProvider = context.read<UserProvider>();
        if (isProfile) {
          await userProvider.updateProfileImage(pickedFile.path);
        } else {
          await userProvider.updateCoverImage(pickedFile.path);
        }
        _initializeSocialUser();
        setState(() {});
        context.read<SocialProvider>().updateUserInfoInPosts(_socialUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resim seçilemedi: $e')),
        );
      }
    }
  }

  Future<void> _deleteImage({required bool isProfile}) async {
    final userProvider = context.read<UserProvider>();
    if (isProfile) {
      await userProvider.deleteProfileImage();
    } else {
      await userProvider.deleteCoverImage();
    }
    _initializeSocialUser();
    setState(() {});
    context.read<SocialProvider>().updateUserInfoInPosts(_socialUser);
  }

  void _showPicker(BuildContext context, {required bool isProfile}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Wrap(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    isProfile ? 'Profil Fotoğrafını Değiştir' : 'Kapak Fotoğrafını Değiştir',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeriden Seç'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickImage(ImageSource.gallery, isProfile: isProfile);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Kamera ile Çek'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickImage(ImageSource.camera, isProfile: isProfile);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(isProfile ? 'Profil Fotoğrafını Kaldır' : 'Kapak Fotoğrafını Kaldır', style: const TextStyle(color: Colors.red)),
                  onTap: () {
                    _deleteImage(isProfile: isProfile);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  ImageProvider _getImageProvider(String? path) { 
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/images/default_placeholder.png');
    }
    if (kIsWeb) {
      return NetworkImage(path);
    } else {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return CachedNetworkImageProvider(path);
      } else {
        final file = File(path);
        if (file.existsSync()) { 
          return FileImage(file);
        } else {
          return const AssetImage('assets/images/default_placeholder.png'); 
        }
      }
    }
  }

  void _navigateToPrivacySettings() async {
    final newSettings = await Navigator.push<Map<String, bool>>(
      context,
      MaterialPageRoute(builder: (context) => const PrivacySettingsPage()),
    );
    if (newSettings != null) {
      setState(() {
        _privacySettings = newSettings;
      });
    }
  }

  void _navigateToSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage(currentUser: _socialUser)),
    );
  }

  void _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
    _initializeSocialUser();
    setState(() {});
  }

  Widget _buildTabWithLock({required String label, required bool isVisible}) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (!isVisible) ...[
            const SizedBox(width: 4),
            const Icon(Icons.lock, size: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildLockedContent(String title, String settingKey) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Bu bölüm gizlilik ayarlarından gizlenmiş', 
            style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _privacySettings[settingKey] = true;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: DynamicColors.primary, foregroundColor: Colors.white),
            child: const Text('Görünür Yap'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final primaryColor = DynamicColors.primary;

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FitnessShareSheet(currentUser: _socialUser),
              );
            },
            backgroundColor: primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [_buildSliverAppBar(primaryColor)];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildInfoTab(),
                _buildFollowingTab(),
                _buildPhotosTab(),
              ],
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(Color primaryColor) {
    return SliverAppBar(
      expandedHeight: 350.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: primaryColor),
          onPressed: _navigateToSearchPage,
          tooltip: 'Kullanıcı Ara',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
        const SizedBox(width: 4.0),
        IconButton(
          icon: Icon(Icons.edit, color: primaryColor),
          onPressed: _navigateToEditProfile,
          tooltip: 'Profili Düzenle',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
        const SizedBox(width: 4.0),
        IconButton(
          icon: Icon(Icons.settings, color: primaryColor),
          onPressed: _navigateToPrivacySettings,
          tooltip: 'Gizlilik Ayarları',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
        const SizedBox(width: 8.0),
      ],
      flexibleSpace: FlexibleSpaceBar(background: _buildHeader(primaryColor)),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: primaryColor,
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        tabs: [
          _buildTabWithLock(label: 'Profilim', isVisible: true),
          _buildTabWithLock(label: 'Bilgilerim', isVisible: _privacySettings['infoVisible'] ?? true),
          _buildTabWithLock(label: 'Takip', isVisible: _privacySettings['followVisible'] ?? true),
          _buildTabWithLock(label: 'Fotoğraflar', isVisible: _privacySettings['photosVisible'] ?? true),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: _getImageProvider(_socialUser.coverImageUrl),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _showPicker(context, isProfile: false);
              },
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black54, Colors.transparent, Colors.black87], 
              begin: Alignment.topCenter, 
              end: Alignment.bottomCenter, 
              stops: [0.0, 0.5, 1.0]
            )
          )
        ),
        Positioned(
          bottom: 70.0, 
          left: 0, 
          right: 0, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [ 
              _buildProfilePicture(primaryColor), 
              const SizedBox(height: 12), 
              Text(_socialUser.userName, 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, 
                  shadows: [Shadow(blurRadius: 5.0, color: Colors.black54)])
              ), 
              Text(_socialUser.userTag, style: TextStyle(fontSize: 16, color: Colors.grey[300])), 
              const SizedBox(height: 16), 
              _buildSocialIcons() 
            ]
          )
        )
      ],
    );
  }
  
  Widget _buildProfilePicture(Color primaryColor) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (BuildContext bc) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Wrap(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: const Text(
                        'Resim Değiştir',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Profil Fotoğrafını Değiştir'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _pickImage(ImageSource.gallery, isProfile: true);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.image),
                      title: const Text('Kapak Fotoğrafını Değiştir'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _pickImage(ImageSource.gallery, isProfile: false);
                      },
                    ),
                    if (_socialUser.profileImageUrl != 'https://i.pravatar.cc/150?img=27')
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text('Profil Fotoğrafını Kaldır', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          _deleteImage(isProfile: true);
                          Navigator.of(context).pop();
                        },
                      ),
                    if (_socialUser.coverImageUrl != 'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?fit=crop&w=1200&h=400&q=80')
                      ListTile(
                        leading: const Icon(Icons.delete_forever, color: Colors.red),
                        title: const Text('Kapak Fotoğrafını Kaldır', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          _deleteImage(isProfile: false);
                          Navigator.of(context).pop();
                        },
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Stack( 
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              border: Border.all(color: primaryColor, width: 3.0), 
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15.0, offset: Offset(0, 5))]
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[800],
              backgroundImage: _getImageProvider(_socialUser.profileImageUrl),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.edit, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSocialIcons() {
    final Map<String, IconData> socialPlatforms = {
      'instagram': FontAwesomeIcons.instagram,
      'twitter': FontAwesomeIcons.twitter,
      'facebook': FontAwesomeIcons.facebook,
      'tiktok': FontAwesomeIcons.tiktok,
      'kick': FontAwesomeIcons.play,
      'twitch': FontAwesomeIcons.twitch,
      'discord': FontAwesomeIcons.discord,
      'whatsapp': FontAwesomeIcons.whatsapp,
      'spotify': FontAwesomeIcons.spotify,
    };

    List<Widget> activeIcons = [];
    
    for (String platform in socialPlatforms.keys) {
      if (_socialUser.socialLinks[platform]?.isNotEmpty ?? false) { 
        activeIcons.add(
          _socialIcon(socialPlatforms[platform]!, _getSocialMediaUrl(platform, _socialUser.socialLinks[platform]!))
        );
      }
    }

    if (activeIcons.isEmpty) {
      activeIcons = [
        _socialIcon(FontAwesomeIcons.instagram, 'https://instagram.com', isInactive: true),
        _socialIcon(FontAwesomeIcons.twitter, 'https://twitter.com', isInactive: true),
        _socialIcon(FontAwesomeIcons.twitch, 'https://twitch.tv', isInactive: true),
      ];
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: activeIcons),
    );
  }

  String _getSocialMediaUrl(String platform, String handle) {
    switch (platform) {
      case 'instagram':
        return handle.startsWith('http') ? handle : 'https://instagram.com/$handle';
      case 'twitter':
        return handle.startsWith('http') ? handle : 'https://twitter.com/$handle';
      case 'facebook':
        return handle.startsWith('http') ? handle : 'https://facebook.com/$handle';
      case 'tiktok':
        return handle.startsWith('http') ? handle : 'https://tiktok.com/@$handle';
      case 'kick':
        return handle.startsWith('http') ? handle : 'https://kick.com/$handle';
      case 'twitch':
        return handle.startsWith('http') ? handle : 'https://twitch.tv/$handle';
      case 'discord':
        return handle;
      case 'whatsapp':
        return handle.startsWith('http') ? handle : 'https://wa.me/$handle';
      case 'spotify':
        return handle.startsWith('http') ? handle : 'https://open.spotify.com/user/$handle';
      default:
        return handle.startsWith('http') ? handle : handle;
    }
  }
  
  Widget _socialIcon(IconData icon, String url, {bool isInactive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: FaIcon(icon, color: isInactive ? Colors.white.withOpacity(0.5) : Colors.white, size: 20), 
        onPressed: isInactive ? null : () async { 
          final Uri uri = Uri.parse(url); 
          if (await canLaunchUrl(uri)) { 
            await launchUrl(uri, mode: LaunchMode.externalApplication); 
          } 
        }, 
        tooltip: isInactive ? 'Henüz eklenmemiş' : url
      ),
    );
  }
  
  Widget _buildProfileTab() {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        final posts = socialProvider.posts;
        if (posts.isEmpty) {
          return const Center(
            child: Text('Henüz hiçbir şey paylaşmadın.\nSağ alttaki + butonuna basarak fitness verilerini paylaş!', 
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey))
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return SocialPostCard(post: posts[index], currentUser: _socialUser);
          },
        );
      },
    );
  }
  
  Widget _buildInfoTab() {
    final userProvider = context.watch<UserProvider>();
    final isOwner = userProvider.user?.userTag == _socialUser.userTag.replaceAll('@', '');
    final bool isVisibleForOthers = _privacySettings['infoVisible'] ?? true;

    if (!isOwner && !isVisibleForOthers) {
      return _buildLockedContent('Bilgiler gizli', 'infoVisible');
    }
    
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [ 
                _buildSectionHeader('Kişisel Bilgiler'),
                _infoTile('Yaş', '${_socialUser.age} yaşında'), 
                _infoTile('Boy', '${_socialUser.height.toInt()} cm'), 
                _infoTile('Ülke', _socialUser.city), 
                
                const SizedBox(height: 24),
                _buildSectionHeader('Favorilerim'),
                _infoTile('Favori Yemek', _socialUser.favoriteMeal), 
                _infoTile('Favori Spor', _socialUser.favoriteSport), 
                _infoTile('Favori Takım', _socialUser.favoriteTeam), 
                
                if (_socialUser.bio != null && _socialUser.bio!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader('Bio'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _socialUser.bio!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ]
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: DynamicColors.primary,
        ),
      ),
    );
  }
  
  Widget _infoTile(String title, String subtitle) { 
    return ListTile(
      // DÜZELTME: title ve subtitle için Expanded kullanıldı
      title: Row(children: [Expanded(child: Text(title, style: TextStyle(color: Colors.grey[400])))],), 
      subtitle: Row(children: [Expanded(child: Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))],),
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
    ); 
  }
  
  Widget _buildFollowingTab() {
    final userProvider = context.watch<UserProvider>();
    final isOwner = userProvider.user?.userTag == _socialUser.userTag.replaceAll('@', '');
    final bool isVisibleForOthers = _privacySettings['followVisible'] ?? true;

    if (!isOwner && !isVisibleForOthers) {
      return _buildLockedContent('Takip listesi gizli', 'followVisible');
    }
    
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: DynamicColors.primary,
            labelColor: DynamicColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Takip Edilenler (${_followingUsers.length})'),
              Tab(text: 'Takipçiler (${_followers.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUserListView(_followingUsers, isFollowingList: true),
                _buildUserListView(_followers, isFollowingList: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListView(List<UserModel> users, {required bool isFollowingList}) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFollowingList ? Icons.person_add_outlined : Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isFollowingList ? 'Kimseyi takip etmiyorsun.' : 'Henüz takipçin yok.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              isFollowingList 
                ? 'Takip etmek için kullanıcı ara' 
                : 'Paylaşımların beğenildiğinde takipçin olacak',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserListTile(
          user: user,
          onFollowToggled: () {
            setState(() {
              _userService.toggleFollowStatus(user.userTag);
              _followingUsers = _userService.getFollowingUsers();
              _followers = _userService.getFollowerUsers();
            });
          },
        );
      },
    );
  }
  
  Widget _buildPhotosTab() {
    final userProvider = context.watch<UserProvider>();
    final isOwner = userProvider.user?.userTag == _socialUser.userTag.replaceAll('@', '');
    final bool isVisibleForOthers = _privacySettings['photosVisible'] ?? true;

    if (!isOwner && !isVisibleForOthers) {
      return _buildLockedContent('Fotoğraflar gizli', 'photosVisible');
    }
    
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        final photoPosts = socialProvider.posts
            .where((post) => post.type == PostType.image && post.imagePath != null)
            .toList();
        
        photoPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (photoPosts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Henüz fotoğraf paylaşmadın', style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Fotoğraf paylaştığında burada görünecek', 
                  style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    crossAxisSpacing: 4, 
                    mainAxisSpacing: 4,
                    childAspectRatio: 1.0,
                  ), 
                  itemCount: photoPosts.length, 
                  itemBuilder: (context, index) { 
                    final post = photoPosts[index];
                    final imagePath = post.imagePath!;
                    
                    return GestureDetector(
                      onTap: () => _showPhotoDetail(context, post),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              kIsWeb
                                  ? Image.network(imagePath, fit: BoxFit.cover, 
                                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.error)))
                                  : Image.file(File(imagePath), fit: BoxFit.cover, 
                                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.error))),
                              
                              Positioned(
                                bottom: 4, right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(4)),
                                  child: Text(_formatPostDate(post.timestamp), 
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                                ),
                              ),
                              
                              if (post.likeCount > 0)
                                Positioned(
                                  bottom: 4, left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(4)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.favorite, color: Colors.red, size: 12),
                                        const SizedBox(width: 2),
                                        Text(post.likeCount.toString(), 
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  String _formatPostDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}g';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}s';
    } else {
      return 'Şimdi';
    }
  }
  
  void _showPhotoDetail(BuildContext context, dynamic post) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(post.imagePath!, fit: BoxFit.contain)
                    : Image.file(File(post.imagePath!), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40, right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (post.text != null && post.text!.isNotEmpty)
              Positioned(
                bottom: 40, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8), 
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text(
                    post.text!, 
                    style: const TextStyle(color: Colors.white, fontSize: 16), 
                    textAlign: TextAlign.center
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
