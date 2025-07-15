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

  // Takip sistemi için user service ve listeler
  final UserService _userService = UserService();
  late List<UserModel> _followingUsers;
  late List<UserModel> _followers;
  
  // Gizlilik ayarları
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
    
    // Takip listelerini yükle
    _followingUsers = _userService.getFollowingUsers();
    _followers = _userService.getFollowerUsers();
  }

  void _initializeSocialUser() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    if (user != null) {
      _socialUser = SocialUser(
        userName: user.name,
        userTag: '@${user.userTag}',
        profileImageUrl: user.profileImagePath ?? 'https://i.pravatar.cc/150?img=27',
        coverImageUrl: 'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?fit=crop&w=1200&h=400&q=80',
        age: user.age,
        height: user.height,
        weight: user.weight,
        favoriteSport: 'Fitness',
        favoriteMeal: 'Protein',
        favoriteTeam: user.favoriteTeam ?? 'Favori takım yok',
        city: user.country ?? 'Şehir belirtilmemiş',
        job: 'Fitness Tutkunu',
        gym: 'FormdaKal Ailesi',
        followers: 0,
        following: 0,
        socialLinks: {
          if (user.instagram != null) 'instagram': user.instagram!,
          if (user.twitter != null) 'twitter': user.twitter!,
        },
        photoUrls: List.generate(15, (index) => 'https://picsum.photos/seed/${index + 50}/500/500'),
      );
    } else {
      _socialUser = SocialUser(
        userName: 'Fitness Kullanıcı',
        userTag: '@fituser',
        profileImageUrl: 'https://i.pravatar.cc/150?img=27',
        coverImageUrl: 'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?fit=crop&w=1200&h=400&q=80',
        age: 25,
        height: 170,
        weight: 70,
        favoriteSport: 'Fitness',
        favoriteMeal: 'Protein',
        favoriteTeam: 'Favori takım yok',
        city: 'Şehir belirtilmemiş',
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
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _socialUser.profileImageUrl = pickedFile.path;
        } else {
          _socialUser.coverImageUrl = pickedFile.path;
        }
        context.read<SocialProvider>().updateUserInfoInPosts(_socialUser);
      });
    }
  }

  void _showPicker(BuildContext context, {required bool isProfile}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeriden Seç'),
                  onTap: () {
                    _pickImage(ImageSource.gallery, isProfile: isProfile);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera, isProfile: isProfile);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (kIsWeb) {
      return NetworkImage(path);
    } else {
      if (path.startsWith('http')) {
        return CachedNetworkImageProvider(path);
      } else {
        return FileImage(File(path));
      }
    }
  }

  // Gizlilik ayarları sayfasına git
  void _navigateToPrivacySettings() async {
    final newSettings = await Navigator.push<Map<String, bool>>(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacySettingsPage(),
      ),
    );

    if (newSettings != null) {
      setState(() {
        _privacySettings = newSettings;
      });
    }
  }

  // Arama sayfasına git
  void _navigateToSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage(currentUser: _socialUser)),
    );
  }

  // Profil düzenleme sayfasına git
  void _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
    
    // Profil düzenlendikten sonra sosyal kullanıcı bilgilerini güncelle
    _initializeSocialUser();
    setState(() {});
  }

  // Tema değiştirme fonksiyonu
  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tema Seçin',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Tema modu seçimi
                  ListTile(
                    leading: Icon(themeProvider.currentThemeIcon),
                    title: const Text('Tema Modu'),
                    subtitle: Text(themeProvider.currentThemeText),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                  
                  const Divider(),
                  
                  // Renk teması seçimi
                  const Text(
                    'Renk Teması',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ColorThemes.allThemes.length,
                      itemBuilder: (context, index) {
                        final theme = ColorThemes.allThemes[index];
                        final isSelected = themeProvider.colorTheme == theme;
                        
                        return GestureDetector(
                          onTap: () {
                            themeProvider.setColorTheme(theme);
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: ColorThemes.getTheme(theme).primary,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected 
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                              boxShadow: isSelected 
                                ? [BoxShadow(
                                    color: ColorThemes.getTheme(theme).primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )]
                                : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  ColorThemes.getTheme(theme).icon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ColorThemes.getTheme(theme).name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DynamicColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Tamam'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // EKSİK METOD: Tab başlıklarında kilit ikonu ile birlikte tab oluşturma
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

  // EKSİK METOD: Kilitli içerik gösterme
  Widget _buildLockedContent(String title, String settingKey) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bu bölüm gizlilik ayarlarından gizlenmiş',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _privacySettings[settingKey] = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DynamicColors.primary,
              foregroundColor: Colors.white,
            ),
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
        ),
        IconButton(
          icon: Icon(Icons.edit, color: primaryColor),
          onPressed: _navigateToEditProfile,
          tooltip: 'Profili Düzenle',
        ),
        IconButton(
          icon: Icon(Icons.settings, color: primaryColor),
          onPressed: _navigateToPrivacySettings,
          tooltip: 'Gizlilik Ayarları',
        ),
        IconButton(
          icon: Icon(Icons.palette_outlined, color: primaryColor),
          onPressed: _showThemeSelector,
          tooltip: 'Temayı Değiştir',
        ),
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
    return GestureDetector(
      onTap: () => _showPicker(context, isProfile: false),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: _getImageProvider(_socialUser.coverImageUrl),
            fit: BoxFit.cover,
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
                Text(
                  _socialUser.userName, 
                  style: const TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white, 
                    shadows: [Shadow(blurRadius: 5.0, color: Colors.black54)]
                  )
                ), 
                Text(
                  _socialUser.userTag, 
                  style: TextStyle(fontSize: 16, color: Colors.grey[300])
                ), 
                const SizedBox(height: 16), 
                _buildSocialIcons() 
              ]
            )
          )
        ],
      ),
    );
  }
  
  Widget _buildProfilePicture(Color primaryColor) {
    return GestureDetector(
      onTap: () => _showPicker(context, isProfile: true),
      child: Container(
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
    );
  }
  
  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        if (_socialUser.socialLinks.containsKey('instagram')) 
          _socialIcon(FontAwesomeIcons.instagram, 'https://instagram.com/${_socialUser.socialLinks['instagram']!}'), 
        if (_socialUser.socialLinks.containsKey('twitter')) 
          _socialIcon(FontAwesomeIcons.twitter, 'https://twitter.com/${_socialUser.socialLinks['twitter']!}'),
        if (_socialUser.socialLinks.containsKey('youtube')) 
          _socialIcon(FontAwesomeIcons.youtube, _socialUser.socialLinks['youtube']!),
        if (_socialUser.socialLinks.containsKey('facebook')) 
          _socialIcon(FontAwesomeIcons.facebook, _socialUser.socialLinks['facebook']!),
        // En az bir ikon göster (boşsa da)
        if (_socialUser.socialLinks.isEmpty) ...[
          _socialIcon(FontAwesomeIcons.instagram, 'https://instagram.com', isInactive: true),
          _socialIcon(FontAwesomeIcons.twitter, 'https://twitter.com', isInactive: true),
        ]
      ]
    );
  }
  
  Widget _socialIcon(IconData icon, String url, {bool isInactive = false}) {
    return IconButton(
      icon: FaIcon(
        icon, 
        color: isInactive ? Colors.white.withOpacity(0.5) : Colors.white,
        size: 20,
      ), 
      onPressed: isInactive ? null : () async { 
        final Uri uri = Uri.parse(url); 
        if (await canLaunchUrl(uri)) { 
          await launchUrl(uri, mode: LaunchMode.externalApplication); 
        } 
      }, 
      tooltip: isInactive ? 'Henüz eklenmemiş' : url
    );
  }
  
  Widget _buildProfileTab() {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        final posts = socialProvider.posts;
        if (posts.isEmpty) {
          return const Center(
            child: Text(
              'Henüz hiçbir şey paylaşmadın.\nSağ alttaki + butonuna basarak fitness verilerini paylaş!', 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 16, color: Colors.grey)
            )
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
    final bool isVisible = _privacySettings['infoVisible'] ?? true;
    
    if (!isVisible) {
      return _buildLockedContent('Bilgiler gizli', 'infoVisible');
    }
    
    return ListView(
      padding: const EdgeInsets.all(16.0), 
      children: [ 
        // Kişisel Bilgiler Bölümü
        _buildSectionHeader('Kişisel Bilgiler'),
        _infoTile('Yaş', '${_socialUser.age}'), 
        _infoTile('Boy', '${_socialUser.height} cm'), 
        _infoTile('Kilo', '${_socialUser.weight} kg'), 
        _infoTile('Sevdiği Spor', _socialUser.favoriteSport), 
        _infoTile('Favori Yemek', _socialUser.favoriteMeal), 
        _infoTile('Tuttuğu Takım', _socialUser.favoriteTeam), 
        _infoTile('Yaşadığı Yer', _socialUser.city), 
        _infoTile('Meslek', _socialUser.job), 
        _infoTile('Spor Salonu', _socialUser.gym),
      ]
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
      title: Text(title, style: TextStyle(color: Colors.grey[400])), 
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
    ); 
  }
  
  Widget _buildFollowingTab() {
    final bool isVisible = _privacySettings['followVisible'] ?? true;
    
    if (!isVisible) {
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
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFollowingList 
                ? 'Takip etmek için kullanıcı ara' 
                : 'Paylaşımların beğenildiğinde takipçin olacak',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
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
    final bool isVisible = _privacySettings['photosVisible'] ?? true;
    
    if (!isVisible) {
      return _buildLockedContent('Fotoğraflar gizli', 'photosVisible');
    }
    
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        // Sadece fotoğraf içeren postları filtrele
        final photoPosts = socialProvider.posts
            .where((post) => post.type == PostType.image && post.imagePath != null)
            .toList();
        
        // Tarihe göre sırala (en yeni en başta)
        photoPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (photoPosts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Henüz fotoğraf paylaşmadın',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Fotoğraf paylaştığında burada görünecek',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
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
              onTap: () {
                // Fotoğrafa tıklandığında büyük görünüm göster
                _showPhotoDetail(context, post);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Fotoğraf
                      kIsWeb
                          ? Image.network(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  ),
                            )
                          : Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  ),
                            ),
                      
                      // Tarih overlay (sağ alt köşede)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatPostDate(post.timestamp),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      
                      // Beğeni sayısı (sol alt köşede)
                      if (post.likeCount > 0)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  post.likeCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }
  
  // Tarih formatlama fonksiyonu
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
  
  // Fotoğraf detay sayfası
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
                    ? Image.network(
                        post.imagePath!,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        File(post.imagePath!),
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (post.text != null && post.text!.isNotEmpty)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.text!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}