import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;

  /// Inisialisasi notifikasi
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Handler ketika notifikasi di-tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to chat page based on payload
  }

  /// Tampilkan notifikasi chat dengan suara
  Future<void> showChatNotification({
    required String senderName,
    required String message,
    required bool isImage,
    String? imageUrl,
    String? roomId,
  }) async {
    await initialize();

    // Play notification sound
    await _playNotificationSound();

    // Tentukan konten notifikasi
    final String contentText = isImage ? '📷 Mengirim gambar' : message;

    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: 'Notifikasi pesan chat dari siswa',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false, // Kita pakai custom sound via audioplayers
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      senderName,
      contentText,
      notificationDetails,
      payload: roomId,
    );
  }

  /// Tampilkan notifikasi chat dengan gambar (Big Picture)
  Future<void> showChatImageNotification({
    required String senderName,
    required String imageUrl,
    String? roomId,
  }) async {
    await initialize();
    await _playNotificationSound();

    // Untuk Android, kita bisa tampilkan big picture
    final androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: 'Notifikasi pesan chat dari siswa',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      enableVibration: true,
      styleInformation: BigPictureStyleInformation(
        FilePathAndroidBitmap(
          imageUrl,
        ), // Ini perlu download dulu jika dari URL
        contentTitle: senderName,
        summaryText: '📷 Mengirim gambar',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: [], // iOS bisa attach image
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      senderName,
      '📷 Mengirim gambar',
      notificationDetails,
      payload: roomId,
    );
  }

  /// Play custom notification sound
  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.stop(); // Stop any previous sound
      await _audioPlayer.play(AssetSource('audio/notif.mp3'));
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
    }
  }

  /// Request permission (untuk iOS)
  Future<bool> requestPermission() async {
    if (_isInitialized) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return false;
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}
