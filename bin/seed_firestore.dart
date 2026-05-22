import 'dart:convert';
import 'dart:io';

const String apiKey = 'AIzaSyD-OEsGxV6DoKGM-LWPAP7LCjkVVuxdK60';
const String projectId = 'abaarso-car-rental';

// User credentials
const String customerEmail = 'khadra@gmail.com';
const String customerPassword = 'password123';

const String adminEmail = 'saeed@abaarso.com';
const String adminPassword = 'password123';

Future<Map<String, dynamic>> postRequest(String url, Map<String, dynamic> data, {Map<String, String>? headers}) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse(url);
    final request = await client.postUrl(uri);
    request.headers.set('content-type', 'application/json');
    if (headers != null) {
      headers.forEach((key, val) => request.headers.set(key, val));
    }
    request.add(utf8.encode(json.encode(data)));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 400) {
      throw HttpException('Request failed with status ${response.statusCode}: $body');
    }
    return json.decode(body) as Map<String, dynamic>;
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>> patchRequest(String url, Map<String, dynamic> data, {Map<String, String>? headers}) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse(url);
    final request = await client.patchUrl(uri);
    request.headers.set('content-type', 'application/json');
    if (headers != null) {
      headers.forEach((key, val) => request.headers.set(key, val));
    }
    request.add(utf8.encode(json.encode(data)));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 400) {
      throw HttpException('Request failed with status ${response.statusCode}: $body');
    }
    return json.decode(body) as Map<String, dynamic>;
  } finally {
    client.close();
  }
}

void main() async {
  print('--- Abaarso Car Rental Native Dart Firestore Seeder ---');
  
  String customerToken;
  String customerUid;
  
  // 1. Authenticate Customer (Khadra Ali)
  try {
    print('Attempting to sign in Khadra Ali...');
    final authUrl = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey';
    final authRes = await postRequest(authUrl, {
      'email': customerEmail,
      'password': customerPassword,
      'returnSecureToken': true,
    });
    customerToken = authRes['idToken'];
    customerUid = authRes['localId'];
    print('Customer signed in successfully! UID: $customerUid');
  } catch (e) {
    print('Customer sign in failed, attempting to sign up...');
    try {
      final authUrl = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey';
      final authRes = await postRequest(authUrl, {
        'email': customerEmail,
        'password': customerPassword,
        'returnSecureToken': true,
      });
      customerToken = authRes['idToken'];
      customerUid = authRes['localId'];
      print('Customer signed up successfully! UID: $customerUid');
    } catch (e2) {
      print('Customer authentication failed completely: $e2');
      exit(1);
    }
  }

  // 2. Authenticate / Setup Admin (Saeed Mohamed)
  String adminToken;
  String adminUid;
  try {
    print('Attempting to sign in Admin Saeed Mohamed...');
    final authUrl = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey';
    final authRes = await postRequest(authUrl, {
      'email': adminEmail,
      'password': adminPassword,
      'returnSecureToken': true,
    });
    adminToken = authRes['idToken'];
    adminUid = authRes['localId'];
    print('Admin signed in successfully! UID: $adminUid');
  } catch (e) {
    print('Admin sign in failed, attempting to sign up...');
    try {
      final authUrl = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey';
      final authRes = await postRequest(authUrl, {
        'email': adminEmail,
        'password': adminPassword,
        'returnSecureToken': true,
      });
      adminToken = authRes['idToken'];
      adminUid = authRes['localId'];
      print('Admin signed up successfully! UID: $adminUid');
    } catch (e2) {
      print('Admin authentication failed completely: $e2');
      exit(1);
    }
  }

  final customerHeaders = {'Authorization': 'Bearer $customerToken'};
  final adminHeaders = {'Authorization': 'Bearer $adminToken'};
  
  final now = DateTime.now().toUtc();
  final nowStr = '${now.toIso8601String().split('.').first}Z';

  // 3. Write User profiles
  try {
    print('Writing customer profile to Firestore...');
    final userUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/$customerUid';
    final userDoc = {
      'fields': {
        'uid': {'stringValue': customerUid},
        'fullName': {'stringValue': 'Khadra Ali'},
        'phone': {'stringValue': '+252635555555'},
        'role': {'stringValue': 'customer'},
        'profileImageUrl': {'stringValue': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80'},
        'isVerified': {'booleanValue': false},
        'createdAt': {'timestampValue': nowStr},
        'updatedAt': {'timestampValue': nowStr}
      }
    };
    await patchRequest(userUrl, userDoc, headers: customerHeaders);
    print('Customer profile written successfully!');
  } catch (e) {
    print('Failed to write customer profile: $e');
  }

  try {
    print('Writing admin profile to Firestore...');
    final userUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/$adminUid';
    final userDoc = {
      'fields': {
        'uid': {'stringValue': adminUid},
        'fullName': {'stringValue': 'Saeed Mohamed'},
        'phone': {'stringValue': '+252634444444'},
        'role': {'stringValue': 'admin'},
        'profileImageUrl': {'stringValue': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80'},
        'isVerified': {'booleanValue': true},
        'createdAt': {'timestampValue': nowStr},
        'updatedAt': {'timestampValue': nowStr}
      }
    };
    // Written using adminHeaders (isOwner match)
    await patchRequest(userUrl, userDoc, headers: adminHeaders);
    print('Admin profile written successfully!');
  } catch (e) {
    print('Failed to write admin profile: $e');
  }

  // 4. Seed Bookings (using Admin or Customer token)
  final bookingsToCreate = [
    {
      'id': 'book_1779451781731_test',
      'carId': 'car_1779451781731',
      'brandModel': 'White Sedan',
      'plateNumber': 'SL 1234 HR',
      'price': 135.0,
      'status': 'confirmed',
      'payStatus': 'paid',
      'reference': 'EVC-998877-TXT',
      'notes': 'Dalab kireysi oo loogu talagalay gaariga cusub (car_1779451781731).'
    },
    {
      'id': 'book_vitz_2_test',
      'carId': 'car_vitz_2',
      'brandModel': 'Toyota Vitz',
      'plateNumber': 'SL 1234 HR',
      'price': 54.0,
      'status': 'completed',
      'payStatus': 'paid',
      'reference': 'ZAAD-872361-TXT',
      'notes': 'Kireysi kooban oo magaalada dhexdeeda ah.'
    },
    {
      'id': 'book_v8_1_test',
      'carId': 'car_v8_1',
      'brandModel': 'Toyota Land Cruiser V8',
      'plateNumber': 'SL 5234 HR',
      'price': 270.0,
      'status': 'confirmed',
      'payStatus': 'paid',
      'reference': 'EVC-991823-REF',
      'notes': 'Macaamiil muhiim ah oo u baahan gaariga in la keeno hudheelka.'
    }
  ];

  for (final booking in bookingsToCreate) {
    try {
      print('Creating booking ${booking['id']} for car ${booking['carId']}...');
      final bookingUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/bookings/${booking['id']}';
      
      final startDate = nowStr;
      final endDate = '${now.add(Duration(days: 3)).toIso8601String().split('.').first}Z';
      
      final bookingDoc = {
        'fields': {
          'bookingId': {'stringValue': booking['id']},
          'userId': {'stringValue': customerUid},
          'carId': {'stringValue': booking['carId']},
          'carBrandModel': {'stringValue': booking['brandModel']},
          'carPlateNumber': {'stringValue': booking['plateNumber']},
          'carImageUrl': {'stringValue': 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?auto=format&fit=crop&w=600&q=80'},
          'userName': {'stringValue': 'Khadra Ali'},
          'userPhone': {'stringValue': '+252635555555'},
          'startDate': {'timestampValue': startDate},
          'endDate': {'timestampValue': endDate},
          'totalDays': {'integerValue': '3'},
          'totalPrice': {'doubleValue': booking['price']},
          'currency': {'stringValue': 'USD'},
          'status': {'stringValue': booking['status']},
          'paymentMethod': {'stringValue': 'evc_plus'},
          'paymentStatus': {'stringValue': booking['payStatus']},
          'paymentReference': {'stringValue': booking['reference']},
          'driverNotes': {'stringValue': booking['notes']},
          'pickupLocationName': {'stringValue': 'Jigjiga Yar, Hargeisa'},
          'pickupLocation': {'geoPointValue': {'latitude': 9.5750, 'longitude': 44.0680}},
          'dropoffLocationName': {'stringValue': 'Jigjiga Yar, Hargeisa'},
          'dropoffLocation': {'geoPointValue': {'latitude': 9.5750, 'longitude': 44.0680}},
          'createdAt': {'timestampValue': nowStr}
        }
      };
      
      // Seed with Admin headers
      await patchRequest(bookingUrl, bookingDoc, headers: adminHeaders);
      print('Booking ${booking['id']} created successfully!');
    } catch (e) {
      print('Failed to create booking ${booking['id']}: $e');
    }
  }

  // 5. Seed Reviews (`/reviews`) - can write because we are authenticated
  final reviewsToCreate = [
    {
      'id': 'rev_1',
      'bookingId': 'book_1779451781731_test',
      'carId': 'car_1779451781731',
      'rating': 5.0,
      'comment': 'Gaariga aad buu u fiicnaa, awoodiisuna waa boqolkiiba boqol. Aad baan ugu qancay adeega!'
    },
    {
      'id': 'rev_2',
      'bookingId': 'book_vitz_2_test',
      'carId': 'car_vitz_2',
      'rating': 4.5,
      'comment': 'Gaarigu wuxuu ahaa mid aad u dhaqaale badan. Wax cillad ah ma lahayn. Nadiif!'
    }
  ];

  for (final review in reviewsToCreate) {
    try {
      print('Creating review ${review['id']} for car ${review['carId']}...');
      final reviewUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/reviews/${review['id']}';
      
      final reviewDoc = {
        'fields': {
          'reviewId': {'stringValue': review['id']},
          'bookingId': {'stringValue': review['bookingId']},
          'userId': {'stringValue': customerUid},
          'userName': {'stringValue': 'Khadra Ali'},
          'userProfileUrl': {'stringValue': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80'},
          'carId': {'stringValue': review['carId']},
          'rating': {'doubleValue': review['rating']},
          'comment': {'stringValue': review['comment']},
          'createdAt': {'timestampValue': nowStr}
        }
      };
      
      // Submit as customer
      await patchRequest(reviewUrl, reviewDoc, headers: customerHeaders);
      print('Review ${review['id']} created successfully!');
    } catch (e) {
      print('Failed to create review ${review['id']}: $e');
    }
  }

  // 6. Seed Notifications (`/notifications`) - Requires Admin Token
  final notificationsToCreate = [
    {
      'id': 'notif_1',
      'targetUserId': customerUid,
      'title': 'Dalabka La Xaqiijiyay / Booking Confirmed!',
      'body': 'Kireysigaaga Toyota Land Cruiser V8 waa la xaqiijiyay. Koodka tixraaca: EVC-991823-REF.',
      'type': 'booking',
      'isRead': false
    },
    {
      'id': 'notif_2',
      'targetUserId': customerUid,
      'title': 'Hubinta KYC / Profile Verification Pending',
      'body': 'Liisankaaga kaxaynta iyo kaarkaaga aqoonsiga ayaa hadda gacanta lagu hayaa.',
      'type': 'system',
      'isRead': true
    },
    {
      'id': 'notif_3',
      'targetUserId': adminUid,
      'title': 'Codsiga Kireysiga / New Booking Request',
      'body': 'Waxaad heshay codsi cusub oo Lexus LX570 VIP ah oo ka yimid Khadra Ali.',
      'type': 'booking',
      'isRead': false
    }
  ];

  for (final notif in notificationsToCreate) {
    try {
      print('Creating notification ${notif['id']} for user ${notif['targetUserId']}...');
      final notifUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/notifications/${notif['id']}';
      
      final notifDoc = {
        'fields': {
          'notificationId': {'stringValue': notif['id']},
          'userId': {'stringValue': notif['targetUserId']},
          'title': {'stringValue': notif['title']},
          'body': {'stringValue': notif['body']},
          'type': {'stringValue': notif['type']},
          'isRead': {'booleanValue': notif['isRead']},
          'createdAt': {'timestampValue': nowStr}
        }
      };
      
      // Submit as Admin
      await patchRequest(notifUrl, notifDoc, headers: adminHeaders);
      print('Notification ${notif['id']} created successfully!');
    } catch (e) {
      print('Failed to create notification ${notif['id']}: $e');
    }
  }

  print('--- Seeding Completed Successfully! ---');
}
