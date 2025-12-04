// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:intl/intl.dart'; // Cần thêm package intl vào pubspec.yaml
// import 'package:vhs_mobile_user/firebase_options.dart';
// import 'package:vhs_mobile_user/main.dart';
// import 'package:go_router/go_router.dart';
// import 'package:vhs_mobile_user/routing/routes.dart'; // Import file chứa đường dẫn routes
//
// // Hàm xử lý background giữ nguyên
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print("--- Thông báo chạy nền ---");
// }
//
// class NotificationService {
//   NotificationService._privateConstructor();
//   static final NotificationService instance = NotificationService._privateConstructor();
//
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   Future<void> initialize() async {
//     await _requestPermission();
//
//     // Cấu hình channel cho Android (quan trọng để hiện thông báo heads-up)
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'high_importance_channel',
//       'Tin nhắn đến',
//       description: 'Thông báo khi có tin nhắn mới',
//       importance: Importance.max,
//       playSound: true,
//     );
//
//     await _localNotificationsPlugin
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//
//     await _configureListeners();
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//     _handleInitialMessage();
//   }
//
//   Future<void> _configureListeners() async {
//     const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@drawable/ic_message');
//     const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
//     const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
//
//     await _localNotificationsPlugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (response) {
//         // Xử lý khi nhấn vào thông báo (Foreground/Background active)
//         if (response.payload != null && response.payload!.isNotEmpty) {
//           _navigateToChatDetail(response.payload!);
//         }
//       },
//     );
//
//     // Xử lý khi nhận tin nhắn lúc đang mở app (Foreground)
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("--- Nhận tin nhắn Foreground ---");
//       _showNotification(message);
//     });
//
//     // Xử lý khi nhấn vào thông báo lúc app đang chạy nền (Background)
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('--- Nhấn vào thông báo (Background) ---');
//       final conversationId = message.data['conversationId'];
//       if (conversationId != null) {
//         _navigateToChatDetail(conversationId);
//       }
//     });
//   }
//
//   /// Hàm hiển thị thông báo tùy chỉnh
//   void _showNotification(RemoteMessage message) {
//     // 1. Lấy dữ liệu từ Data Payload (Server cần gửi đúng các key này)
//     final data = message.data;
//
//     // Lấy thông tin, nếu không có trong data thì lấy trong notification block, hoặc để mặc định
//     final String conversationId = data['conversationId'] ?? '';
//     final String senderName = data['senderName'] ?? message.notification?.title ?? 'Tin nhắn mới';
//     final String content = data['content'] ?? message.notification?.body ?? 'Bạn có tin nhắn mới';
//     final String sentTimeRaw = data['sentTime'] ?? DateTime.now().toString();
//
//     // 2. Định dạng thời gian (Giờ : Phút)
//     String formattedTime = "";
//     try {
//       DateTime time = DateTime.parse(sentTimeRaw).toLocal(); // Chuyển về giờ máy
//       formattedTime = DateFormat('HH:mm').format(time);
//     } catch (e) {
//       formattedTime = DateFormat('HH:mm').format(DateTime.now());
//     }
//
//     // 3. Tạo nội dung hiển thị
//     // Title: Tên người gửi
//     // Body: Nội dung tin nhắn
//     // SubText: Thời gian (hoặc cộng vào body)
//
//     _localNotificationsPlugin.show(
//       message.hashCode,
//       senderName, // Dòng 1: Tên người gửi
//       "$content\n($formattedTime)", // Dòng 2: Nội dung + Thời gian
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'high_importance_channel',
//           'Tin nhắn đến',
//           importance: Importance.max,
//           priority: Priority.high,
//           icon: '@drawable/ic_launcher',
//           styleInformation: BigTextStyleInformation(
//             "$content\n($formattedTime)", // Cho phép hiển thị nhiều dòng nếu tin nhắn dài
//             contentTitle: senderName,
//           ),
//         ),
//         iOS: const DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//       payload: conversationId, // Gắn ID để khi click thì biết chuyển đi đâu
//     );
//   }
//
//   void _handleInitialMessage() async {
//     RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
//     if (initialMessage != null) {
//       final conversationId = initialMessage.data['conversationId'];
//       if (conversationId != null) {
//         // Delay nhỏ để Router kịp khởi tạo
//         Future.delayed(const Duration(milliseconds: 1000), () {
//           _navigateToChatDetail(conversationId);
//         });
//       }
//     }
//   }
//
//   void _navigateToChatDetail(String conversationId) {
//     print("Navigating to Chat ID: $conversationId");
//     // Sử dụng GoRouter thông qua Context của NavigatorKey toàn cục
//     final context = navigatorKey.currentState?.context;
//     if (context != null) {
//       // Dùng push để có nút Back, thay vì go
//       context.push(Routes.chatDetailPath(conversationId));
//     } else {
//       print("Lỗi: Context không tồn tại (NavigatorKey chưa được gắn)");
//     }
//   }
//
//   // Trong NotificationService
//   Future<void> printDeviceToken() async {
//     String? token = await _firebaseMessaging.getToken();
//     print("🔥 FIREBASE TOKEN: $token");
//     // TODO: Gọi API gửi token này lên Server để lưu vào bảng User
//   }
//
//   Future<void> _requestPermission() async {
//     if (Platform.isIOS) {
//       await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
//     } else if (Platform.isAndroid) {
//       final androidImplementation = _localNotificationsPlugin
//           .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
//       await androidImplementation?.requestNotificationsPermission();
//     }
//   }
// }

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:vhs_mobile_user/firebase_options.dart';
import 'package:vhs_mobile_user/main.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';

// Hàm xử lý background giữ nguyên
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("--- Thông báo chạy nền (Background Handler) ---");
}

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _requestPermission();

    // --- SỬA 1: Tự động in Token ra để bạn copy ---
    await printDeviceToken();

    // Cấu hình channel cho Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Tin nhắn đến',
      description: 'Thông báo khi có tin nhắn mới',
      importance: Importance.max,
      playSound: true,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _configureListeners();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _handleInitialMessage();
  }

  Future<void> _configureListeners() async {
    // --- SỬA 2: Dùng @mipmap/ic_launcher để chắc chắn không lỗi thiếu icon ---
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          _navigateToChatDetail(response.payload!);
        }
      },
    );

    // Xử lý khi nhận tin nhắn FCM lúc đang mở app (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("--- Nhận tin nhắn FCM Foreground ---");
      // Gọi hàm showLocalNotification đã được public
      final data = message.data;
      showLocalNotification(
        title: data['senderName'] ?? message.notification?.title ?? 'Tin nhắn mới',
        body: data['content'] ?? message.notification?.body ?? 'Bạn có tin nhắn mới',
        payload: data['conversationId'] ?? '',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('--- Nhấn vào thông báo (Background) ---');
      final conversationId = message.data['conversationId'];
      if (conversationId != null) {
        _navigateToChatDetail(conversationId);
      }
    });
  }

  // --- SỬA 3: Đổi thành Public (bỏ dấu _) để SignalR gọi được ---
  void showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) {
    // Định dạng thời gian
    String formattedTime = DateFormat('HH:mm').format(DateTime.now());

    _localNotificationsPlugin.show(
      DateTime.now().millisecond, // ID ngẫu nhiên
      title,
      "$body\n($formattedTime)",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Tin nhắn đến',
          importance: Importance.max,
          priority: Priority.high,
          // --- QUAN TRỌNG: Icon phải đúng đường dẫn ---
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            "$body\n($formattedTime)",
            contentTitle: title,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  void _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      final conversationId = initialMessage.data['conversationId'];
      if (conversationId != null) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _navigateToChatDetail(conversationId);
        });
      }
    }
  }

  void _navigateToChatDetail(String conversationId) {
    print("Navigating to Chat ID: $conversationId");
    final context = navigatorKey.currentState?.context;
    if (context != null) {
      context.push(Routes.chatDetailPath(conversationId));
    } else {
      print("Lỗi: Context không tồn tại");
    }
  }

  Future<void> printDeviceToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("🔥------------------------------------------🔥");
      print("🔥 FIREBASE TOKEN: $token");
      print("🔥------------------------------------------🔥");
    } catch(e) {
      print("🔥 Lỗi lấy Token: $e");
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final androidImplementation = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }
}