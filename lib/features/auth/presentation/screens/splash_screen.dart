import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../../domain/user_entity.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _carTranslate;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.bounceOut),
      ),
    );

    _carTranslate = Tween<double>(begin: -150.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    // Wait for the animation to finish and retrieve preferences
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool(AppStrings.keyFirstRun) ?? true;

    if (!mounted) return;

    if (isFirstRun) {
      context.go(AppRoutes.onboarding);
      return;
    }

    // Check Auth status
    final authState = ref.read(authNotifierProvider);

    if (authState.user != null) {
      final user = authState.user!;
      if (user.licenseImageUrl == null || user.idCardImageUrl == null) {
        // User logged in but hasn't submitted KYC documents
        context.go(AppRoutes.profileSetup);
      } else if (user.role == UserRole.admin) {
        context.go(AppRoutes.adminDashboard);
      } else {
        context.go(AppRoutes.home);
      }
    } else if (authState.needsRegistration) {
      context.go(AppRoutes.register);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Stack(
        children: [
          // Elegant Somali Sunrise Backdrop Grid/Ornaments
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium Car Logo Silhouette
                ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.directions_car_filled_rounded,
                          color: AppColors.primary,
                          size: 72,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ABAARSO',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            letterSpacing: 6,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                // Car Silhouette Translate Animation
                AnimatedBuilder(
                  animation: _carTranslate,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_carTranslate.value, 0),
                      child: child,
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.horizontal_rule_rounded, color: AppColors.primary, size: 24),
                      Icon(Icons.directions_car_outlined, color: Colors.white, size: 36),
                      Icon(Icons.horizontal_rule_rounded, color: AppColors.primary, size: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Multi-language Subtitles Fade-In
                FadeTransition(
                  opacity: _opacity,
                  child: Column(
                    children: [
                      Text(
                        'Premium Car Rental Hargeisa',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kireynta Gaariga ugu Fiican Hargeysa',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.accent,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withOpacity(0.8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
