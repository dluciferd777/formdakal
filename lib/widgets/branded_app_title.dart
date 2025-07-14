// lib/widgets/branded_app_title.dart - FormdaKal Başlığı Widget'ı
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class BrandedAppTitle extends StatelessWidget {
  final double fontSize;
  final FontWeight fontWeight;
  final Color? baseColor;
  final bool useAccentColor;
  final TextAlign textAlign;

  const BrandedAppTitle({
    super.key,
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
    this.baseColor,
    this.useAccentColor = true,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final palette = themeProvider.currentColorPalette;
        final isDarkMode = themeProvider.isDarkMode;
        
        // Temel renk belirleme
        Color textColor = baseColor ?? 
            (isDarkMode ? Colors.white : Colors.black); // Açık temada siyah, koyu temada beyaz
        
        // Vurgu rengi (F ve K harfleri için)
        Color accentColor = useAccentColor 
            ? (isDarkMode ? palette.light : palette.light)
            : textColor;

        return RichText(
          textAlign: textAlign,
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor,
            ),
            children: [
              TextSpan(
                text: 'F',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                  shadows: useAccentColor ? [
                    Shadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ] : null,
                ),
              ),
              const TextSpan(text: 'ormda'),
              TextSpan(
                text: 'K',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                  shadows: useAccentColor ? [
                    Shadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ] : null,
                ),
              ),
              const TextSpan(text: 'al'),
            ],
          ),
        );
      },
    );
  }
}

// Özel kullanımlar için hazır widget'lar

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrandedAppTitle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      baseColor: Colors.white,
      useAccentColor: true,
    );
  }
}

class LargeTitle extends StatelessWidget {
  final Color? textColor;
  
  const LargeTitle({super.key, this.textColor});

  @override
  Widget build(BuildContext context) {
    return BrandedAppTitle(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      baseColor: textColor,
      useAccentColor: true,
    );
  }
}

class MediumTitle extends StatelessWidget {
  final Color? textColor;
  
  const MediumTitle({super.key, this.textColor});

  @override
  Widget build(BuildContext context) {
    return BrandedAppTitle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      baseColor: textColor,
      useAccentColor: true,
    );
  }
}

class SmallTitle extends StatelessWidget {
  final Color? textColor;
  
  const SmallTitle({super.key, this.textColor});

  @override
  Widget build(BuildContext context) {
    return BrandedAppTitle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      baseColor: textColor,
      useAccentColor: true,
    );
  }
}

// Animasyonlu başlık widget'ı
class AnimatedBrandedTitle extends StatefulWidget {
  final double fontSize;
  final Duration animationDuration;
  final Color? textColor;

  const AnimatedBrandedTitle({
    super.key,
    this.fontSize = 28,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.textColor,
  });

  @override
  State<AnimatedBrandedTitle> createState() => _AnimatedBrandedTitleState();
}

class _AnimatedBrandedTitleState extends State<AnimatedBrandedTitle> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: BrandedAppTitle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w900,
              baseColor: widget.textColor,
              useAccentColor: true,
            ),
          ),
        );
      },
    );
  }
}