import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewEntity {
  final String reviewId;
  final String userId;
  final String userName;
  final String? userProfileUrl;
  final String carId;
  final String bookingId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewEntity({
    required this.reviewId,
    required this.userId,
    required this.userName,
    this.userProfileUrl,
    required this.carId,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'userName': userName,
      'userProfileUrl': userProfileUrl,
      'carId': carId,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReviewEntity.fromMap(Map<String, dynamic> map) {
    return ReviewEntity(
      reviewId: map['reviewId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String? ?? 'Abaarso Customer',
      userProfileUrl: map['userProfileUrl'] as String?,
      carId: map['carId'] as String,
      bookingId: map['bookingId'] as String? ?? '',
      rating: (map['rating'] as num? ?? 5.0).toDouble(),
      comment: map['comment'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
