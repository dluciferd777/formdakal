// lib/screens/tag_setup_screen.dart - Kullanıcı Tag Oluşturma - DÜZELTİLMİŞ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/friend_service.dart';
import '../providers/theme_provider.dart';
import '../models/user_model.dart';

class TagSetupScreen extends StatefulWidget {
  final UserModel user; // Önceki adımlardan gelen user bilgisi
  
  const TagSetupScreen({super.key, required this.user});

  @override
  State<TagSetupScreen> createState() => _TagSetupScreenState();
}

class _TagSetupScreenState extends State<TagSetupScreen> {
  final TextEditingController _tagController = TextEditingController();
  List<String> _suggestions = [];
  bool _isChecking = false;
  bool _isAvailable = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _generateSuggestions();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _generateSuggestions() async {
    final suggestions = await FriendService.generateTagSuggestions(widget.user.name);
    if (mounted) {
      setState(() {
        _suggestions = suggestions;
      });
    }
  }

  Future<void> _checkTagAvailability(String tag) async {
    if (tag.length < 3) {
      setState(() {
        _errorMessage = 'Tag en az 3 karakter olmalıdır';
        _isAvailable = false;
      });
      return;
    }

    if (!FriendService.isValidTag(tag)) {
      setState(() {
        _errorMessage = 'Sadece harf ve rakam kullanabilirsiniz';
        _isAvailable = false;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = '';
    });

    final isAvailable = await FriendService.isTagAvailable(tag);
    
    if (mounted) {
      setState(() {
        _isChecking = false;
        _isAvailable = isAvailable;
        _errorMessage = isAvailable ? '' : 'Bu tag zaten kullanımda';
      });
    }
  }

  Future<void> _selectTag(String tag) async {
    _tagController.text = tag;
    await _checkTagAvailability(tag);
  }

  Future<void> _finishSetup() async {
    if (!_isAvailable || _tagController.text.isEmpty) return;

    // User'ı tag ile birlikte kaydet
    final updatedUser = widget.user.copyWith(userTag: _tagController.text);
    final success = await FriendService.registerUser(updatedUser);
    
    if (mounted) {
      if (success) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        setState(() {
          _errorMessage = 'Kayıt başarısız oldu, lütfen tekrar deneyin';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().currentColorPalette;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Adınızı Oluşturun'),
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Açıklama
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: palette.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Kullanıcı Adınız',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: palette.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Arkadaşlarınızın sizi bulabilmesi için benzersiz bir kullanıcı adı oluşturun. '
                    'Örnek: ${widget.user.name.toUpperCase()}#2536',
                    style: TextStyle(
                      color: palette.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tag Input
            Text(
              'Kullanıcı Tag\'iniz:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    '${widget.user.name.toUpperCase()}#',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: 'TAG2536',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        borderSide: BorderSide(color: palette.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        borderSide: BorderSide(color: palette.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        borderSide: BorderSide(color: palette.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      suffixIcon: _isChecking
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _tagController.text.isNotEmpty
                              ? Icon(
                                  _isAvailable ? Icons.check_circle : Icons.error,
                                  color: _isAvailable ? Colors.green : Colors.red,
                                )
                              : null,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    onChanged: (value) {
                      if (value.length >= 3) {
                        _checkTagAvailability(value);
                      } else {
                        setState(() {
                          _isAvailable = false;
                          _errorMessage = value.isEmpty ? '' : 'En az 3 karakter gerekli';
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            
            // Error/Success Message
            if (_errorMessage.isNotEmpty || _isAvailable)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage.isNotEmpty ? _errorMessage : 'Tag kullanılabilir! ✓',
                  style: TextStyle(
                    color: _errorMessage.isNotEmpty ? Colors.red : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Öneriler
            Text(
              'Önerilen Tag\'ler:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return InkWell(
                    onTap: () => _selectTag(suggestion),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: palette.primary.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(8),
                        color: palette.primary.withValues(alpha: 0.05),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.user.name.toUpperCase()}#$suggestion',
                          style: TextStyle(
                            color: palette.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Devam Et Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAvailable ? _finishSetup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isAvailable ? 'Hesabımı Oluştur' : 'Geçerli Bir Tag Seçin',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}