import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_settings_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/custom_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      titleEn: 'Browse the Fleet',
      titleSo: 'Dheeg gawaarida',
      descriptionEn: "Discover Hargeisa's finest cars, from premium VIP SUVs to economical sedans tailored for your local journeys.",
      descriptionSo: "Hel gawaarida ugu fiican Hargeysa, laga bilaabo kuwa VIP-da ah ilaa sedan dhaqaale ahaan kugu habboon.",
      icon: Icons.directions_car_filled_rounded,
      imageAsset: 'assets/images/browse_car.png',
    ),
    OnboardingSlide(
      titleEn: 'Instant Local Bookings',
      titleSo: 'Kireyso si Degdeg ah',
      descriptionEn: 'Enter your dates, select pickup points, and make prompt payments using Telesom Zaad or Hormuud EVC Plus.',
      descriptionSo: 'Geli taariikhda, dooro goobta gaariga laga qaadayo, kuna bixi si sahlan Zaad ama EVC Plus.',
      icon: Icons.flash_on_rounded,
      imageAsset: 'assets/images/book_payment.png',
    ),
    OnboardingSlide(
      titleEn: 'Self-Drive or Professional Drivers',
      titleSo: 'Adigu Kaxeyso ama Wadayaal Codso',
      descriptionEn: 'Enjoy complete freedom behind the wheel or select verified drivers who possess complete knowledge of Hargeisa roads.',
      descriptionSo: 'Ku raaxayso xornimo buuxda adoo kaxaynaya ama dalbo wadayaal khabiiro ah oo yaqaana waddooyinka Hargeysa.',
      icon: Icons.verified_user_rounded,
      imageAsset: 'assets/images/drive_freedom.png',
    ),
  ];

  Future<void> _completeOnboarding() async {
    await ref.read(appSettingsProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Elegant decorative sunrise circle
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.06),
              ),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Elegant Icon Circle
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        slide.icon,
                        color: AppColors.primary,
                        size: 96,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // English and Somali Titles
                    Text(
                      slide.titleEn,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slide.titleSo,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // English and Somali Descriptions
                    Text(
                      slide.descriptionEn,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.brightness == Brightness.light ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      slide.descriptionSo,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.brightness == Brightness.light ? AppColors.textSecondaryLight.withOpacity(0.8) : AppColors.textSecondaryDark.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              );
            },
            ),
            // Skip button in top right
            Positioned(
              top: 50,
              right: 16,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Skip',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Bottom control navigation bar
            Positioned(
              bottom: 40,
              left: 32,
              right: 32,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class OnboardingSlide {
  final String titleEn;
  final String titleSo;
  final String descriptionEn;
  final String descriptionSo;
  final IconData icon;
  final String imageAsset;

  OnboardingSlide({
    required this.titleEn,
    required this.titleSo,
    required this.descriptionEn,
    required this.descriptionSo,
    required this.icon,
    required this.imageAsset,
  });
}
