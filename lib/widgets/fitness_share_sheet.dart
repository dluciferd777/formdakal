import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/social_post_model.dart';
import '../models/social_user_model.dart';
import '../providers/social_provider.dart';
import '../providers/user_provider.dart';
import '../providers/food_provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/step_counter_provider.dart';
import '../utils/color_themes.dart';
import '../widgets/fitness_stats_card.dart';

class FitnessShareSheet extends StatefulWidget {
  final SocialUser currentUser;
  const FitnessShareSheet({super.key, required this.currentUser});

  @override
  State<FitnessShareSheet> createState() => _FitnessShareSheetState();
}

class _FitnessShareSheetState extends State<FitnessShareSheet> {
  List<String> _selectedAudience = [];
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _youtubeUrlController = TextEditingController();
  String? _imagePath;

  @override
  void dispose() {
    _textController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  void _shareFitnessStats() {
    final userProvider = context.read<UserProvider>();
    final foodProvider = context.read<FoodProvider>();
    final exerciseProvider = context.read<ExerciseProvider>();
    final stepProvider = context.read<StepCounterProvider>();
    final socialProvider = context.read<SocialProvider>();

    final today = DateTime.now();
    final user = userProvider.user;
    
    final steps = stepProvider.dailySteps;
    final consumedCalories = foodProvider.getDailyCalories(today);
    final burnedCalories = exerciseProvider.getDailyBurnedCalories(today);
    final waterIntake = userProvider.getDailyWaterIntake(today);

    final stepGoal = user?.dailyStepGoal ?? 8000;
    final calorieNeeds = user?.dailyCalorieNeeds ?? 2000;
    final waterNeeds = 2.0;

    final fitnessData = FitnessStatsData(
      steps: steps,
      consumedCalories: consumedCalories,
      burnedCalories: burnedCalories,
      waterIntake: waterIntake,
      stepProgress: steps / stepGoal,
      consumedCalorieProgress: consumedCalories / calorieNeeds,
      burnedCalorieProgress: burnedCalories / (calorieNeeds * 0.2),
      waterProgress: waterIntake / waterNeeds,
    );

    final newPost = SocialPost(
      id: DateTime.now().toIso8601String(),
      userId: widget.currentUser.userTag,
      userName: widget.currentUser.userName,
      userProfileImageUrl: widget.currentUser.profileImageUrl,
      type: PostType.fitnessStats,
      timestamp: DateTime.now(),
      fitnessData: fitnessData,
      allowedUserTags: _selectedAudience.isNotEmpty ? _selectedAudience : null,
    );

    socialProvider.addPost(newPost);
    // DÜZELTME: Sadece FitnessShareSheet'i kapat
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitness verileriniz başarıyla paylaşıldı!')),
    );
  }

  // DÜZELTME: Yazı paylaşma fonksiyonu, artık kendi dialogunu kapatacak
  void _shareTextPost(BuildContext dialogContext) {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(dialogContext).showSnackBar( // dialogContext kullanıldı
        const SnackBar(content: Text('Lütfen bir yazı girin.'), backgroundColor: Colors.red),
      );
      return;
    }
    final socialProvider = context.read<SocialProvider>();
    final newPost = SocialPost(
      id: DateTime.now().toIso8601String(),
      userId: widget.currentUser.userTag,
      userName: widget.currentUser.userName,
      userProfileImageUrl: widget.currentUser.profileImageUrl,
      type: PostType.text,
      timestamp: DateTime.now(),
      text: _textController.text.trim(),
      allowedUserTags: _selectedAudience.isNotEmpty ? _selectedAudience : null,
    );
    socialProvider.addPost(newPost);
    _textController.clear(); // Metni temizle
    Navigator.pop(dialogContext); // Sadece bu dialogu kapat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yazınız başarıyla paylaşıldı!')),
    );
  }

  // DÜZELTME: YouTube videosu paylaşma fonksiyonu, artık kendi dialogunu kapatacak
  void _shareYoutubeVideo(BuildContext dialogContext) {
    final videoId = YoutubePlayer.convertUrlToId(_youtubeUrlController.text.trim());
    if (videoId == null || videoId.isEmpty) {
      ScaffoldMessenger.of(dialogContext).showSnackBar( // dialogContext kullanıldı
        const SnackBar(content: Text('Lütfen geçerli bir YouTube URL\'si girin.'), backgroundColor: Colors.red),
      );
      return;
    }
    final socialProvider = context.read<SocialProvider>();
    final newPost = SocialPost(
      id: DateTime.now().toIso8601String(),
      userId: widget.currentUser.userTag,
      userName: widget.currentUser.userName,
      userProfileImageUrl: widget.currentUser.profileImageUrl,
      type: PostType.youtubeVideo,
      timestamp: DateTime.now(),
      youtubeVideoId: videoId,
      text: _textController.text.trim().isNotEmpty ? _textController.text.trim() : null,
      allowedUserTags: _selectedAudience.isNotEmpty ? _selectedAudience : null,
    );
    socialProvider.addPost(newPost);
    _youtubeUrlController.clear(); // URL'yi temizle
    _textController.clear(); // Metni temizle
    Navigator.pop(dialogContext); // Sadece bu dialogu kapat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('YouTube videosu başarıyla paylaşıldı!')),
    );
  }

  // DÜZELTME: Fotoğraf paylaşma fonksiyonu, artık kendi dialogunu kapatacak
  void _shareImagePost(BuildContext dialogContext) async {
    // TODO: Image Picker entegrasyonu
    ScaffoldMessenger.of(dialogContext).showSnackBar( // dialogContext kullanıldı
      const SnackBar(content: Text('Fotoğraf seçme özelliği yakında eklenecek!'), backgroundColor: Colors.orange),
    );
    final socialProvider = context.read<SocialProvider>();
    final newPost = SocialPost(
      id: DateTime.now().toIso8601String(),
      userId: widget.currentUser.userTag,
      userName: widget.currentUser.userName,
      userProfileImageUrl: widget.currentUser.profileImageUrl,
      type: PostType.image,
      timestamp: DateTime.now(),
      imagePath: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/500/500',
      text: _textController.text.trim().isNotEmpty ? _textController.text.trim() : null,
      allowedUserTags: _selectedAudience.isNotEmpty ? _selectedAudience : null,
    );
    socialProvider.addPost(newPost);
    _imagePath = null; // Resim yolunu temizle
    _textController.clear(); // Metni temizle
    Navigator.pop(dialogContext); // Sadece bu dialogu kapat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fotoğraf başarıyla paylaşıldı!')),
    );
  }

  void _showAudienceSelectionDialog() {
    final List<String> availableUsers = ['@onurstar', '@altug', '@jahrein', '@busechan'];
    List<String> tempSelectedAudience = List.from(_selectedAudience);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Kimler Görebilir?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('Herkese Açık'),
                    value: tempSelectedAudience.isEmpty || tempSelectedAudience.contains('public'),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          tempSelectedAudience.clear();
                          tempSelectedAudience.add('public');
                        } else {
                          tempSelectedAudience.remove('public');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Sadece Takipçilerim'),
                    value: tempSelectedAudience.contains('followers_only'),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          tempSelectedAudience.clear();
                          tempSelectedAudience.add('followers_only');
                        } else {
                          tempSelectedAudience.remove('followers_only');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Belirli Kişiler'),
                    value: tempSelectedAudience.isNotEmpty && !tempSelectedAudience.contains('public') && !tempSelectedAudience.contains('followers_only'),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          tempSelectedAudience.clear();
                          tempSelectedAudience.addAll(availableUsers);
                        } else {
                          if (tempSelectedAudience.isNotEmpty && !tempSelectedAudience.contains('public') && !tempSelectedAudience.contains('followers_only')) {
                            tempSelectedAudience.clear();
                          }
                        }
                      });
                    },
                  ),
                  if (tempSelectedAudience.isNotEmpty && !tempSelectedAudience.contains('public') && !tempSelectedAudience.contains('followers_only'))
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: availableUsers.length,
                        itemBuilder: (context, index) {
                          final userTag = availableUsers[index];
                          final isSelected = tempSelectedAudience.contains(userTag);
                          return CheckboxListTile(
                            title: Text(userTag),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  tempSelectedAudience.add(userTag);
                                } else {
                                  tempSelectedAudience.remove(userTag);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (tempSelectedAudience.isEmpty || tempSelectedAudience.contains('public')) {
                        _selectedAudience = [];
                      } else {
                        _selectedAudience = tempSelectedAudience;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = DynamicColors.primary;
    final bool isPrivate = _selectedAudience.isNotEmpty;
    
    return Padding(
      // DÜZELTME: Bottom sheet'in klavye ve navigasyon barının üstünde kalması için padding
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        // DÜZELTME: İçeriğin tamamını kaydırılabilir yapmak için SingleChildScrollView
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, 
                  height: 5, 
                  decoration: BoxDecoration(
                    color: Colors.grey[600], 
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Yeni Paylaşım Oluştur',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  color: primaryColor
                )
              ),
              const SizedBox(height: 24),
              
              _buildOptionTile(
                context, 
                icon: Icons.article, 
                title: 'Yazı Paylaş', 
                onTap: () {
                  // DÜZELTME: Dialog'u açarken context'i doğrudan kullan
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) => _buildTextInputDialog(
                      ctx, // Dialog context'i
                      title: 'Yazı Paylaş',
                      hintText: 'Ne düşünüyorsun?',
                      controller: _textController,
                      onShare: _shareTextPost,
                    ),
                  );
                },
              ),
              _buildOptionTile(
                context, 
                icon: FontAwesomeIcons.youtube, 
                title: 'YouTube Videosu Paylaş', 
                onTap: () {
                  // DÜZELTME: Dialog'u açarken context'i doğrudan kullan
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) => _buildYoutubeInputDialog(
                      ctx, // Dialog context'i
                      title: 'YouTube Videosu Paylaş',
                      hintText: 'YouTube URL\'si',
                      controller: _youtubeUrlController,
                      onShare: _shareYoutubeVideo,
                    ),
                  );
                },
              ),
              _buildOptionTile(
                context, 
                icon: Icons.photo_camera, 
                title: 'Fotoğraf Paylaş', 
                onTap: () {
                  // DÜZELTME: Dialog'u açarken context'i doğrudan kullan
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) => _buildImageInputDialog(
                      ctx, // Dialog context'i
                      title: 'Fotoğraf Paylaş',
                      onShare: _shareImagePost,
                    ),
                  );
                },
              ),
              const Divider(height: 32),

              const Text(
                'Günlük Fitness İstatistikleri', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
              ),
              const SizedBox(height: 12),
              
              Consumer4<UserProvider, FoodProvider, ExerciseProvider, StepCounterProvider>(
                builder: (context, userProvider, foodProvider, exerciseProvider, stepProvider, child) {
                  final today = DateTime.now();
                  final user = userProvider.user;
                  final steps = stepProvider.dailySteps;
                  final consumedCalories = foodProvider.getDailyCalories(today);
                  final burnedCalories = exerciseProvider.getDailyBurnedCalories(today);
                  final waterIntake = userProvider.getDailyWaterIntake(today);

                  final stepGoal = user?.dailyStepGoal ?? 8000;
                  final calorieNeeds = user?.dailyCalorieNeeds ?? 2000;
                  final waterNeeds = 2.0;

                  final previewData = FitnessStatsData(
                    steps: steps,
                    consumedCalories: consumedCalories,
                    burnedCalories: burnedCalories,
                    waterIntake: waterIntake,
                    stepProgress: steps / stepGoal,
                    consumedCalorieProgress: consumedCalories / calorieNeeds,
                    burnedCalorieProgress: burnedCalories / (calorieNeeds * 0.2),
                    waterProgress: waterIntake / waterNeeds,
                  );

                  return FitnessStatsCard(fitnessData: previewData);
                },
              ),
              
              const SizedBox(height: 16),
              
              OutlinedButton.icon(
                icon: Icon(isPrivate ? Icons.people : Icons.public, color: primaryColor),
                label: Text(
                  isPrivate 
                      ? (_selectedAudience.contains('followers_only') ? 'Sadece Takipçiler' : '${_selectedAudience.length} Kişi Görebilir') 
                      : 'Görünürlük: Herkes',
                  style: TextStyle(color: primaryColor),
                ),
                onPressed: _showAudienceSelectionDialog,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor.withOpacity(0.5))
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _shareFitnessStats,
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text('Fitness Verilerini Paylaş', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, {
    required IconData icon, 
    required String title, 
    required VoidCallback onTap
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(title),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // DÜZELTME: dialogContext parametresi eklendi
  Widget _buildTextInputDialog(BuildContext dialogContext, {
    required String title,
    required String hintText,
    required TextEditingController controller,
    required Function(BuildContext) onShare, // dialogContext'i alacak şekilde değiştirildi
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(dialogContext).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(dialogContext).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => onShare(dialogContext), // dialogContext'i geçir
                  child: Text('Paylaş'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DÜZELTME: dialogContext parametresi eklendi
  Widget _buildYoutubeInputDialog(BuildContext dialogContext, {
    required String title,
    required String hintText,
    required TextEditingController controller,
    required Function(BuildContext) onShare, // dialogContext'i alacak şekilde değiştirildi
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(dialogContext).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(dialogContext).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => onShare(dialogContext), // dialogContext'i geçir
                  child: Text('Paylaş'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DÜZELTME: dialogContext parametresi eklendi
  Widget _buildImageInputDialog(BuildContext dialogContext, {
    required String title,
    required Function(BuildContext) onShare, // dialogContext'i alacak şekilde değiştirildi
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(dialogContext).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(dialogContext).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  ScaffoldMessenger.of(dialogContext).showSnackBar( // dialogContext kullanıldı
                    const SnackBar(content: Text('Fotoğraf seçme özelliği yakında eklenecek!'), backgroundColor: Colors.orange),
                  );
                  setState(() {
                    _imagePath = 'https://placehold.co/500x500/png?text=Image';
                  });
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeriden Fotoğraf Seç'),
              ),
              if (_imagePath != null) ...[
                const SizedBox(height: 16),
                Image.network(_imagePath!, height: 150, fit: BoxFit.cover),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Açıklama yazın (isteğe bağlı)...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _imagePath != null ? () => onShare(dialogContext) : null, // dialogContext'i geçir
                  child: Text('Paylaş'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
