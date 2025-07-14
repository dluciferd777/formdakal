import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/social_user_model.dart';
import '../providers/social_provider.dart';
import '../providers/user_provider.dart';
import '../utils/color_themes.dart';
import '../widgets/social_post_card.dart';
import '../widgets/fitness_share_sheet.dart';

class FitProfileScreen extends StatefulWidget {
  const FitProfileScreen({super.key});

  @override
  State<FitProfileScreen> createState() => _FitProfileScreenState();
}

class _FitProfileScreenState extends State<FitProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late SocialUser _socialUser;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeSocialUser();
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

  @override
  Widget build(BuildContext context) {
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
          return [ _buildSliverAppBar(primaryColor) ];
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
          icon: Icon(Icons.palette_outlined, color: primaryColor),
          onPressed: () {},
          tooltip: 'Temayı Değiştir',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(background: _buildHeader(primaryColor)),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: primaryColor,
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'Profilim'),
          Tab(text: 'Bilgilerim'),
          Tab(text: 'Takip'),
          Tab(text: 'Fotoğraflar'),
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
          _socialIcon(FontAwesomeIcons.instagram, _socialUser.socialLinks['instagram']!), 
        if (_socialUser.socialLinks.containsKey('twitter')) 
          _socialIcon(FontAwesomeIcons.twitter, _socialUser.socialLinks['twitter']!)
      ]
    );
  }
  
  Widget _socialIcon(IconData icon, String url) {
    return IconButton(
      icon: FaIcon(icon, color: Colors.white), 
      onPressed: () async { 
        final Uri uri = Uri.parse(url); 
        if (await canLaunchUrl(uri)) { 
          await launchUrl(uri, mode: LaunchMode.externalApplication); 
        } 
      }, 
      tooltip: url
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
    return ListView(
      padding: const EdgeInsets.all(16.0), 
      children: [ 
        _infoTile('Yaş', '${_socialUser.age}'), 
        _infoTile('Boy', '${_socialUser.height} cm'), 
        _infoTile('Kilo', '${_socialUser.weight} kg'), 
        _infoTile('Sevdiği Spor', _socialUser.favoriteSport), 
        _infoTile('Favori Yemek', _socialUser.favoriteMeal), 
        _infoTile('Tuttuğu Takım', _socialUser.favoriteTeam), 
        _infoTile('Yaşadığı Yer', _socialUser.city), 
        _infoTile('Meslek', _socialUser.job), 
        _infoTile('Spor Salonu', _socialUser.gym) 
      ]
    );
  }
  
  Widget _infoTile(String title, String subtitle) { 
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.grey[400])), 
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
    ); 
  }
  
  Widget _buildFollowingTab() {
    return const Center(
      child: Text(
        'Takip özelliği yakında eklenecek!', 
        style: TextStyle(color: Colors.grey, fontSize: 16)
      )
    );
  }
  
  Widget _buildPhotosTab() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        crossAxisSpacing: 2, 
        mainAxisSpacing: 2
      ), 
      itemCount: _socialUser.photoUrls.length, 
      itemBuilder: (context, index) { 
        return CachedNetworkImage(
          imageUrl: _socialUser.photoUrls[index], 
          fit: BoxFit.cover, 
          placeholder: (context, url) => Container(color: Colors.grey[800])
        ); 
      }
    );
  }
}