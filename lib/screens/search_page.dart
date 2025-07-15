// lib/screens/search_page.dart
import 'package:flutter/material.dart';
import '../models/social_user_model.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../utils/color_themes.dart';
import '../widgets/user_list_tile.dart';

class SearchPage extends StatefulWidget {
  final SocialUser currentUser;

  const SearchPage({super.key, required this.currentUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _userService = UserService();
  List<UserModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // Arama alanındaki her değişikliği dinle
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    super.dispose();
  }

  // Arama işlemini gerçekleştiren fonksiyon
  void _performSearch() {
    final query = _searchController.text;
    setState(() {
      _searchResults = _userService.searchUsers(query, widget.currentUser.userTag.replaceAll('@', ''));
    });
  }

  // Arama sonuçlarındaki bir kullanıcının takip durumunu değiştir
  void _onFollowToggled(String userTag) {
    setState(() {
      _userService.toggleFollowStatus(userTag);
      // Aramayı yeniden tetikle
      _performSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar başlığı olarak doğrudan bir metin giriş alanı kullanıyoruz
        title: TextField(
          controller: _searchController,
          autofocus: true, // Sayfa açılır açılmaz klavyeyi açar
          decoration: InputDecoration(
            hintText: 'Kullanıcı adı veya @tag ile ara...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[600]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  )
                : null,
          ),
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : _buildSuggestedUsers(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Sonuç bulunamadı',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Farklı anahtar kelimeler deneyin',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return UserListTile(
          user: user,
          onFollowToggled: () => _onFollowToggled(user.userTag),
        );
      },
    );
  }

  Widget _buildSuggestedUsers() {
    final allUsers = _userService.getAllUsers(widget.currentUser.userTag.replaceAll('@', ''));
    final suggestedUsers = allUsers.take(10).toList(); // İlk 10 kullanıcıyı öner

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (suggestedUsers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Önerilen Kullanıcılar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DynamicColors.primary,
                ),
              ),
            ),
            ...suggestedUsers.map((user) => UserListTile(
              user: user,
              onFollowToggled: () => _onFollowToggled(user.userTag),
            )),
          ],
          
          // Arama önerileri
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arama İpuçları',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DynamicColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSearchTip('İsimle ara:', 'Onur, Elif, Jahrein'),
                _buildSearchTip('Tag ile ara:', '@onurstar, @jahrein'),
                _buildSearchTip('Kısaltma:', 'Onur Y, Elif D'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTip(String title, String example) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              example,
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}