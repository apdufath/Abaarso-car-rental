import '../domain/booking_entity.dart';
import '../domain/review_entity.dart';
import 'booking_remote_datasource.dart';

class BookingRepository {
  final BookingRemoteDataSource _dataSource;

  BookingRepository(this._dataSource);

  Future<List<BookingEntity>> getAllBookings() {
    return _dataSource.getAllBookings();
  }

  Future<List<BookingEntity>> getBookingsByUser(String userId) {
    return _dataSource.getBookingsByUser(userId);
  }

  Future<List<BookingEntity>> getBookingsByCar(String carId) {
    return _dataSource.getBookingsByCar(carId);
  }

  Future<BookingEntity?> getBookingById(String bookingId) {
    return _dataSource.getBookingById(bookingId);
  }

  Future<void> createBooking(BookingEntity booking) {
    return _dataSource.createBooking(booking);
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) {
    return _dataSource.updateBookingStatus(bookingId, status);
  }

  Future<void> updatePaymentStatus(String bookingId, PaymentStatus paymentStatus, String? reference) {
    return _dataSource.updatePaymentStatus(bookingId, paymentStatus, reference);
  }

  Future<void> addReview(ReviewEntity review) {
    return _dataSource.addReview(review);
  }

  Future<List<ReviewEntity>> getReviewsForCar(String carId) {
    return _dataSource.getReviewsForCar(carId);
  }
}
