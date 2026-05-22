import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../bookings/domain/booking_entity.dart';
import '../../../bookings/presentation/providers/bookings_provider.dart';

class BookingsManagementScreen extends ConsumerWidget {
  const BookingsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(adminBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings Operations'),
        centerTitle: true,
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings recorded in the system.'));
          }

          // Sort bookings (latest first)
          final sorted = List<BookingEntity>.from(bookings)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final booking = sorted[index];

              Color getStatusColor(BookingStatus status) {
                switch (status) {
                  case BookingStatus.pending:
                    return Colors.orange;
                  case BookingStatus.approved:
                    return Colors.blue;
                  case BookingStatus.active:
                    return AppColors.success;
                  case BookingStatus.completed:
                    return Colors.grey;
                  case BookingStatus.cancelled:
                    return AppColors.cancelled;
                }
              }

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ID: ${booking.bookingId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(booking.status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              booking.status.name.toUpperCase(),
                              style: TextStyle(
                                color: getStatusColor(booking.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      
                      // Lessor/User & Car summaries
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Macmiilka / Customer:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          Text(booking.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Gaariga / Car:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          Text(booking.carBrandModel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Rent Duration:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          Text('${booking.totalDays} Days (\$${booking.totalPrice.toInt()})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Ref:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          Text(booking.paymentReference ?? 'UNPAID PENDING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: booking.paymentStatus == PaymentStatus.paid ? AppColors.success : Colors.orange)),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Status control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 1. Approve button
                          if (booking.status == BookingStatus.pending)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  Helpers.triggerHapticLight();
                                  await ref.read(bookingRepositoryProvider).updateBookingStatus(booking.bookingId, BookingStatus.approved);
                                  ref.invalidate(adminBookingsProvider);
                                },
                              ),
                            ),
                          // 2. Activate button (car takes onto road)
                          if (booking.status == BookingStatus.approved)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: AppColors.success),
                                icon: const Icon(Icons.car_rental, size: 16),
                                label: const Text('Handover / Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  Helpers.triggerHapticLight();
                                  await ref.read(bookingRepositoryProvider).updateBookingStatus(booking.bookingId, BookingStatus.active);
                                  ref.invalidate(adminBookingsProvider);
                                },
                              ),
                            ),
                          // 3. Complete button (rental returned)
                          if (booking.status == BookingStatus.active)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                                icon: const Icon(Icons.done_all_rounded, size: 16),
                                label: const Text('Mark Complete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  Helpers.triggerHapticLight();
                                  await ref.read(bookingRepositoryProvider).updateBookingStatus(booking.bookingId, BookingStatus.completed);
                                  ref.invalidate(adminBookingsProvider);
                                },
                              ),
                            ),
                          // 4. Cancel/Decline button
                          if (booking.status == BookingStatus.pending || booking.status == BookingStatus.approved)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: AppColors.cancelled),
                                icon: const Icon(Icons.cancel_outlined, size: 16),
                                label: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  Helpers.triggerHapticLight();
                                  await ref.read(bookingRepositoryProvider).updateBookingStatus(booking.bookingId, BookingStatus.cancelled);
                                  ref.invalidate(adminBookingsProvider);
                                },
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (e, st) => Center(child: Text('Error loading operations list: ${e.toString()}')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
