import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/booking_entity.dart';
import '../providers/bookings_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/user_entity.dart';

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bookingsAsync = ref.watch(userBookingsProvider);
    final adminBookingsAsync = ref.watch(adminBookingsProvider);
    final currentUser = ref.watch(authNotifierProvider).user;

    // Determine user role and search all bookings
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt & Details'),
        centerTitle: true,
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          // If customer list doesn't have it, try admin search
          var list = bookings.where((b) => b.bookingId == bookingId).toList();
          if (list.isEmpty) {
            // Fallback to checking admin list if role is admin
            if (currentUser?.role == UserRole.admin) {
              final adminList = adminBookingsAsync.value ?? [];
              list = adminList.where((b) => b.bookingId == bookingId).toList();
            }
          }

          if (list.isEmpty) {
            return const Center(child: Text('Receipt not found / Lama helin macluumaadkaan.'));
          }

          final booking = list.first;

          String formatDate(DateTime date) {
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            return '${months[date.month - 1]} ${date.day}, ${date.year}';
          }

          final now = DateTime.now();
          final showCancelButton = (booking.status == BookingStatus.pending || booking.status == BookingStatus.approved) &&
                                   booking.startDate.isAfter(now);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Success Message if paid
                if (booking.paymentStatus == PaymentStatus.paid)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Payment Confirmed / Lacagta Waa La Helay', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                              const SizedBox(height: 4),
                              Text('Ref ID: ${booking.paymentReference ?? "REF-MOCK"}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // 2. Receipt Card (Styled like high-end visual receipt)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Brand details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ABAARSO CAR RENTAL', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: booking.status == BookingStatus.cancelled
                                  ? AppColors.cancelled.withOpacity(0.1)
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              booking.status.name.toUpperCase(),
                              style: TextStyle(
                                color: booking.status == BookingStatus.cancelled ? AppColors.cancelled : AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Customer information
                      _ReceiptRow(label: 'Customer / Macmiilka', value: booking.userName),
                      _ReceiptRow(label: 'Phone / Telefoonka', value: booking.userPhone),
                      _ReceiptRow(label: 'Car Model / Nooca Gaariga', value: booking.carBrandModel),
                      _ReceiptRow(label: 'Plate Number / Taargada', value: booking.carPlateNumber),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Location information
                      _ReceiptRow(label: 'Pick-up / Goobta Qaadashada', value: booking.pickupLocation),
                      _ReceiptRow(label: 'Drop-off / Goobta Wareejinta', value: booking.dropoffLocation),
                      _ReceiptRow(label: 'Start Date / Bilaabashada', value: formatDate(booking.startDate)),
                      _ReceiptRow(label: 'End Date / Wareejinta', value: formatDate(booking.endDate)),
                      _ReceiptRow(label: 'Total Days / Cisho', value: '${booking.totalDays} Days'),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Payment and Invoice summaries
                      _ReceiptRow(label: 'Method / Bixinta', value: booking.paymentMethod.name.toUpperCase()),
                      _ReceiptRow(label: 'Reference / Lambarka Xaqiijinta', value: booking.paymentReference ?? 'N/A'),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Dual pricing total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Cost (USD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(Formatters.formatUSD(booking.totalPrice), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Cost (SOS)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            Formatters.formatSOS(booking.totalPrice * 600),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Invoice Downloader Action button
                CustomButton(
                  text: 'Download Invoice (PDF) / Soo Dagso',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invoice downloaded successfully / Faktuurka waa la soo degsaday.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 4. Cancel option button
                if (showCancelButton)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cancelled,
                      side: const BorderSide(color: AppColors.cancelled),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      _showCancelDialog(context, ref);
                    },
                    child: const Text('Cancel Rental / Jooji Kireysiga', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          );
        },
        error: (e, st) => Center(child: Text('Error: ${e.toString()}')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel this booking? This action will refund your credit and make the vehicle available again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(bookingRepositoryProvider).updateBookingStatus(bookingId, BookingStatus.cancelled);
              ref.invalidate(userBookingsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking cancelled successfully.'), backgroundColor: AppColors.cancelled),
                );
              }
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.cancelled)),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
