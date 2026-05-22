import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../../domain/user_entity.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
      
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final rawRepo = ref.read(authRepositoryProvider);
      
      final currentUser = rawRepo.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please log in again.'), backgroundColor: AppColors.error),
        );
        context.go(AppRoutes.login);
        return;
      }

      authNotifier.register(
        fullName: name,
        phone: currentUser.phoneNumber ?? '',
        role: _selectedRole,
        email: email,
      ).then((_) {
        if (!context.mounted) return;
        final authState = ref.read(authNotifierProvider);
        if (authState.errorMessageEn == null) {
          // Send to KYC Setup
          context.go(AppRoutes.profileSetup);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authState.errorMessageEn!), backgroundColor: AppColors.error),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Registration'),
      ),
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        message: 'Creating your profile...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Let’s Get to Know You',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your personal details to personalize your car leasing experience.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  style: theme.textTheme.titleMedium,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'e.g. Mohamed Ali',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: theme.textTheme.titleMedium,
                  decoration: const InputDecoration(
                    labelText: 'Email Address (Optional)',
                    hintText: 'e.g. mohamed@gmail.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 32),
                Text(
                  'What is your primary goal?',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                // Premium Role Selector Tiles
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        title: 'Rent a Car',
                        subtitle: 'Customer',
                        icon: Icons.directions_car_rounded,
                        isSelected: _selectedRole == UserRole.customer,
                        onTap: () {
                          setState(() {
                            _selectedRole = UserRole.customer;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        title: 'Be a Driver',
                        subtitle: 'Driver Partner',
                        icon: Icons.badge_rounded,
                        isSelected: _selectedRole == UserRole.driver,
                        onTap: () {
                          setState(() {
                            _selectedRole = UserRole.driver;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                CustomButton(
                  text: 'Create Account',
                  onPressed: _register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = isSelected ? AppColors.primary : Colors.grey.shade400;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : (theme.brightness == Brightness.light ? Colors.white : AppColors.surfaceDark),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: baseColor, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected ? AppColors.primary : null,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
