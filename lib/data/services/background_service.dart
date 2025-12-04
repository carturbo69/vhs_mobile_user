import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:signalr_netcore/signalr_client.dart';

// Hàm khởi tạo service
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true, // Tự động chạy khi mở app
      isForegroundMode: true, // Chạy chế độ Foreground (có thông báo dính)
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'VHS Mobile',
      initialNotificationContent: 'Đang duy trì kết nối tin nhắn...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );
}

// Hàm này chạy ngầm kể cả khi tắt UI
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // 1. Cấu hình Local Notification để hiện tin nhắn
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'chat_channel', // id
    'Tin nhắn chat', // title
    importance: Importance.max,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 2. Kết nối SignalR ĐỘC LẬP (Lưu ý: Phải Hardcode Token hoặc lấy từ LocalStorage nếu được)
  // Vì đây là isolate khác, bạn không thể truy cập biến của Provider/Riverpod từ UI chính được.

  final hubConnection = HubConnectionBuilder()
      .withUrl("http://apivhs.cuahangkinhdoanh.com/chathub")
      .withAutomaticReconnect()
      .build();

  // Xử lý khi nhận tin nhắn
  hubConnection.on("message:created", (arguments) {
    try {
      // Parse dữ liệu (Code xử lý JSON của bạn)
      final rawData = arguments![0] as Map;
      final body = rawData['body'] ?? 'Hình ảnh';
      final sender = rawData['sender']['accountName'] ?? 'Người gửi';
      final isMine = rawData['isMine'] ?? false; // Cần server trả về hoặc tự check ID

      if (!isMine) {
        // HIỆN THÔNG BÁO
        flutterLocalNotificationsPlugin.show(
          DateTime.now().millisecond,
          sender,
          body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'chat_channel',
              'Tin nhắn chat',
              icon: '@mipmap/ic_message', // Icon nhỏ
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  });

  await hubConnection.start();

  // Lắng nghe lệnh tắt service từ UI
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}