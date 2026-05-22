import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/providers/app_settings_provider.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/domain/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cars/presentation/providers/cars_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    final settings = ref.watch(appSettingsProvider);
    final isSomalLang = settings.locale.languageCode == 'so';

    final favoriteIds = ref.watch(favoriteCarsProvider);
    final carsAsync = ref.watch(carsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: user == null
          ? Scaffold(
              appBar: AppBar(title: Text(isSomalLang ? 'Koontada' : 'Profile Settings')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      isSomalLang ? 'Fadlan gal koontadaada' : 'Please log in to view profile.',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: isSomalLang ? 'Soo Gal' : 'Log In',
                      onPressed: () => context.go(AppRoutes.login),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Forest Green Curved Hero Header with Sandy Yellow ring & User details
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 280,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(36),
                            bottomRight: Radius.circular(36),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 20),
                        child: Column(
                          children: [
                            // Custom top bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                                Text(
                                  isSomalLang ? 'Koontada' : 'My Profile',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings_rounded, color: Colors.white),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Sandy yellow ring surrounding user avatar
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: 46,
                                    backgroundColor: Colors.white,
                                    backgroundImage: user.profileImageUrl != null
                                        ? NetworkImage(user.profileImageUrl!)
                                        : null,
                                    child: user.profileImageUrl == null
                                        ? const Icon(Icons.person, color: AppColors.primary, size: 46)
                                        : null,
                                  ),
                                ),
                                // Edit pencil overlay button
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: AppColors.secondary,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // User Name
                            Text(
                              user.fullName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Role Subtitle / Verification
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.phone,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  user.isVerified ? Icons.verified_rounded : Icons.pending_rounded,
                                  size: 14,
                                  color: user.isVerified ? AppColors.accent : Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.isVerified
                                      ? (isSomalLang ? 'LA HUBIYAY' : 'VERIFIED')
                                      : (isSomalLang ? 'IN PENDING' : 'PENDING'),
                                  style: TextStyle(
                                    color: user.isVerified ? AppColors.accent : Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 2. Floating/Overlapping Stats Card
                      Positioned(
                        bottom: -40,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statCol('12', isSomalLang ? 'Safar' : 'Trips', Icons.directions_car_rounded),
                              _verticalDivider(),
                              _statCol('4.9', isSomalLang ? 'Qiimayn' : 'Rating', Icons.star_rounded),
                              _verticalDivider(),
                              _statCol(favoriteIds.length.toString(), isSomalLang ? 'Lagu Keydiyay' : 'Saved', Icons.favorite_rounded),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // Admin Operations Dashboard Control
                  if (user.role == UserRole.admin) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () {
                          context.push(AppRoutes.adminDashboard);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary, Color(0xFF233A30)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.admin_panel_settings_rounded, color: AppColors.accent, size: 28),
                                  SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Admin Dashboard Control',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Manage fleet, users & booking requests',
                                        style: TextStyle(color: Colors.white70, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white12,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 3. Settings list as a clean stack of modern individual Cards with alternating soft green & soft yellow background leading icons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSomalLang ? 'DOORASHADA KOONTADA' : 'ACCOUNT PREFERENCES',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Stack of clean settings tiles
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            children: [
                              _profileTile(
                                icon: Icons.person_outline_rounded,
                                iconBg: const Color(0xFFE2EBE7), // Light green
                                iconColor: AppColors.primary,
                                title: isSomalLang ? 'Xogta Shakhsiga' : 'Personal Info',
                                subtitle: isSomalLang ? 'Magaca, Lambarka & KYC' : 'Manage your contact details',
                              ),
                              _divider(),
                              _profileTile(
                                icon: Icons.history_rounded,
                                iconBg: const Color(0xFFFBF4DB), // Light yellow
                                iconColor: const Color(0xFF8B7500),
                                title: isSomalLang ? 'Dalabaadkayga' : 'My Bookings',
                                subtitle: isSomalLang ? 'Eeg dhammaan safarada' : 'History of car rentals',
                                onTap: () => context.go(AppRoutes.bookings),
                              ),
                              _divider(),
                              _profileTile(
                                icon: Icons.credit_card_rounded,
                                iconBg: const Color(0xFFE2EBE7), // Light green
                                iconColor: AppColors.primary,
                                title: isSomalLang ? 'Habka Lacag Bixinta' : 'Payment Settings',
                                subtitle: isSomalLang ? 'Maamul EVC/Zaad profiles' : 'Configured push accounts',
                              ),
                              _divider(),
                              _profileTile(
                                icon: Icons.dark_mode_outlined,
                                iconBg: const Color(0xFFFBF4DB), // Light yellow
                                iconColor: const Color(0xFF8B7500),
                                title: isSomalLang ? 'Habka Habeenkii' : 'Dark Mode',
                                subtitle: isSomalLang ? 'Tir/Daar habka habeenkii' : 'Toggle app colors',
                                trailing: Switch(
                                  value: settings.themeMode == ThemeMode.dark,
                                  activeThumbColor: AppColors.primary,
                                  onChanged: (val) {
                                    Helpers.triggerHapticLight();
                                    ref.read(appSettingsProvider.notifier).toggleTheme(val);
                                  },
                                ),
                              ),
                              _divider(),
                              _profileTile(
                                icon: Icons.language_rounded,
                                iconBg: const Color(0xFFE2EBE7), // Light green
                                iconColor: AppColors.primary,
                                title: isSomalLang ? 'Luuqada' : 'App Language',
                                subtitle: isSomalLang ? 'Af-Soomaali ah' : 'Currently English',
                                trailing: DropdownButton<String>(
                                  value: settings.locale.languageCode,
                                  underline: const SizedBox(),
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                                  items: const [
                                    DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                                    DropdownMenuItem(value: 'so', child: Text('Soomaali', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      Helpers.triggerHapticLight();
                                      ref.read(appSettingsProvider.notifier).setLocale(val);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 4. Favorite cars section
                        Text(
                          isSomalLang ? 'MUUQAALADA AAD JECESHAHAY' : 'MY SAVED VEHICLES',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        carsAsync.when(
                          data: (cars) {
                            final favCars = cars.where((c) => favoriteIds.contains(c.carId)).toList();
                            if (favCars.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.favorite_border_rounded, color: Colors.grey.shade300, size: 36),
                                      const SizedBox(height: 10),
                                      Text(
                                        isSomalLang ? 'Ma jiraan baabuur aad keydsatay.' : 'No favorited cars yet.',
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Column(
                                children: favCars.map((car) {
                                  final isLast = favCars.indexOf(car) == favCars.length - 1;
                                  return Column(
                                    children: [
                                      ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: car.images.isNotEmpty
                                              ? Image.network(car.images.first, width: 70, height: 48, fit: BoxFit.cover)
                                              : Container(color: Colors.grey, width: 70, height: 48),
                                        ),
                                        title: Text(
                                          '${car.brand} ${car.model}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.secondary),
                                        ),
                                        subtitle: Text(
                                          '\$${car.pricePerDay.toInt()}/day',
                                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                                          onPressed: () {
                                            Helpers.triggerHapticLight();
                                            ref.read(favoriteCarsProvider.notifier).toggleFavorite(car.carId);
                                          },
                                        ),
                                        onTap: () {
                                          context.push(AppRoutes.getCarDetailRoute(car.carId));
                                        },
                                      ),
                                      if (!isLast) _divider(),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                          },
                          error: (e, st) => const SizedBox(),
                          loading: () => const Center(child: CircularProgressIndicator()),
                        ),
                        const SizedBox(height: 32),

                        // 5. Account operations
                        Text(
                          isSomalLang ? 'QAYBTA KOONTADA' : 'ACCOUNT MANAGEMENT',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            children: [
                              _profileTile(
                                icon: Icons.logout_rounded,
                                iconBg: const Color(0xFFFFEBEE), // Soft red
                                iconColor: AppColors.cancelled,
                                title: isSomalLang ? 'Ka Bax' : 'Sign Out / Log Out',
                                subtitle: isSomalLang ? 'Ka bax koontadaada' : 'Safely exit the app',
                                onTap: () async {
                                  Helpers.triggerHapticLight();
                                  await ref.read(authNotifierProvider.notifier).logout();
                                  if (context.mounted) {
                                    context.go(AppRoutes.login);
                                  }
                                },
                              ),
                              _divider(),
                              _profileTile(
                                icon: Icons.delete_forever_rounded,
                                iconBg: const Color(0xFFF3F3F3), // Soft grey
                                iconColor: Colors.grey.shade700,
                                title: isSomalLang ? 'Tir Akoonka' : 'Delete Account',
                                subtitle: isSomalLang ? 'Tir akoonka waligaa' : 'Irreversibly delete account data',
                                onTap: () {
                                  _showDeleteDialog(context, ref, isSomalLang);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statCol(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1.2,
      height: 36,
      color: Colors.grey.shade200,
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade100,
      indent: 68,
    );
  }

  Widget _profileTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.secondary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 11,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, bool isSomalLang) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(isSomalLang ? 'Ma hubtaa?' : 'Delete Account?'),
        content: Text(isSomalLang
            ? 'Qaladkan dib looma soo celin karo. Akoonkaaga iyo dhammaan xogtaadu waa la tiri doonaa.'
            : 'This operation is irreversible. All of your bookings, records, and KYC uploads will be deleted permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(isSomalLang ? 'Maya' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              Helpers.triggerHapticLight();
              await ref.read(authNotifierProvider.notifier).deleteAccount();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: Text(isSomalLang ? 'Hubaal, Tir' : 'Yes, Delete', style: const TextStyle(color: AppColors.cancelled)),
          ),
        ],
      ),
    );
  }
}
