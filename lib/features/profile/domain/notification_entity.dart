import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationEntity {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final String type; // e.g. "booking", "promo", "system"
  final bool isRead;
  final DateTime createdAt;

  NotificationEntity({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    bool? isRead,
  }) {
    return NotificationEntity(
      notificationId: notificationId,
      userId: userId,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationEntity.fromMap(Map<String, dynamic> map, String id) {
    return NotificationEntity(
      notificationId: map['notificationId'] as String? ?? id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? 'system',
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
