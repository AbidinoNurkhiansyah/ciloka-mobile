# 🔔 Panduan Implementasi Notifikasi Chat

## 📋 Ringkasan
Fitur notifikasi chat dengan suara custom dan detail pesan (teks/gambar).

## 🎯 Fitur yang Diimplementasikan
1. ✅ Notifikasi lokal dengan suara custom (`notif.mp3`)
2. ✅ Tampilkan detail pesan (teks atau "📷 Mengirim gambar")
3. ✅ Vibration saat notifikasi masuk
4. ✅ Support Android & iOS
5. ✅ Big Text style untuk pesan panjang
6. ✅ Tap notifikasi untuk buka chat (TODO)

---

## 📦 Package yang Ditambahkan
- `flutter_local_notifications: ^18.0.1` ✅ Sudah ditambahkan ke pubspec.yaml
- `audioplayers: ^6.5.1` ✅ Sudah ada sebelumnya

---

## 🛠️ Konfigurasi Platform

### **Android (WAJIB)**

#### 1. Update `android/app/src/main/AndroidManifest.xml`

Tambahkan permission dan receiver:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Tambahkan permission ini -->
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <application
        android:label="ciloka_app"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Activity utama -->
        <activity
            android:name=".MainActivity"
            ...>
            ...
        </activity>

        <!-- TAMBAHKAN INI: Receiver untuk notifikasi -->
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

#### 2. Update `android/app/build.gradle`

Pastikan minSdkVersion minimal 21:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Minimal 21
        targetSdkVersion flutter.targetSdkVersion
        ...
    }
}
```

---

### **iOS (Opsional)**

#### Update `ios/Runner/Info.plist`

Tambahkan permission untuk notifikasi:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## 💻 Cara Menggunakan

### **1. Inisialisasi di `main.dart`**

```dart
import 'package:ciloka_app/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Inisialisasi NotificationService
  await NotificationService().initialize();
  
  runApp(const MyApp());
}
```

### **2. Trigger Notifikasi saat Pesan Masuk**

Ada 2 cara:

#### **Cara 1: Di ChatPage (Listener Real-time)**

Tambahkan listener di `ChatPage` untuk mendeteksi pesan baru:

```dart
import 'package:ciloka_app/core/services/notification_service.dart';

class _ChatPageState extends State<ChatPage> {
  String? _lastMessageId;
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: vm.messages,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final latestMessage = snapshot.data!.docs.last;
          final messageId = latestMessage.id;
          final data = latestMessage.data() as Map<String, dynamic>;
          
          // Cek apakah pesan baru dan bukan dari user sendiri
          if (_lastMessageId != messageId) {
            _lastMessageId = messageId;
            
            final senderId = data['senderId'] ?? '';
            final isMe = widget.isTeacherView 
                ? senderId == widget.teacherId 
                : senderId == widget.studentId;
            
            // Jika bukan pesan dari saya, tampilkan notifikasi
            if (!isMe) {
              _showNotification(data);
            }
          }
        }
        
        // ... rest of builder
      },
    );
  }
  
  void _showNotification(Map<String, dynamic> data) {
    final senderName = data['senderName'] ?? 'Pengirim';
    final isImage = data['type'] == 'image';
    final content = data['content'] ?? '';
    final imageUrl = data['imageUrl'];
    
    if (isImage && imageUrl != null) {
      NotificationService().showChatImageNotification(
        senderName: senderName,
        imageUrl: imageUrl,
        roomId: '${widget.teacherId}_${widget.studentId}',
      );
    } else {
      NotificationService().showChatNotification(
        senderName: senderName,
        message: content,
        isImage: false,
        roomId: '${widget.teacherId}_${widget.studentId}',
      );
    }
  }
}
```

#### **Cara 2: Di Background (Cloud Functions - Advanced)**

Untuk notifikasi saat app tertutup, perlu Firebase Cloud Functions:

```javascript
// functions/index.js
exports.sendChatNotification = functions.firestore
  .document('story_rooms/{roomId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const roomId = context.params.roomId;
    
    // Get recipient FCM token
    // Send FCM notification
    // ...
  });
```

---

## 🎨 Customization

### **Ubah Suara Notifikasi**

Ganti file `assets/audio/notif.mp3` dengan file audio Anda.

### **Ubah Style Notifikasi**

Edit di `notification_service.dart`:

```dart
const androidDetails = AndroidNotificationDetails(
  'chat_channel',
  'Chat Notifications',
  channelDescription: 'Notifikasi pesan chat dari siswa',
  importance: Importance.high,
  priority: Priority.high,
  // Tambahkan custom style di sini
  color: Color(0xFF4CAF50), // Warna notifikasi
  ledColor: Color(0xFF4CAF50),
  ledOnMs: 1000,
  ledOffMs: 500,
);
```

---

## 🧪 Testing

### **1. Test Notifikasi Sederhana**

Tambahkan button test di UI:

```dart
ElevatedButton(
  onPressed: () {
    NotificationService().showChatNotification(
      senderName: 'Test User',
      message: 'Ini pesan test!',
      isImage: false,
    );
  },
  child: Text('Test Notifikasi'),
)
```

### **2. Test dengan Chat Asli**

1. Login sebagai Siswa
2. Kirim pesan ke Guru
3. Login sebagai Guru (di device/emulator lain)
4. Buka chat → Notifikasi seharusnya muncul saat pesan masuk

---

## ⚠️ Catatan Penting

1. **Notifikasi hanya muncul jika app di background/foreground**
   - Untuk notifikasi saat app tertutup, perlu Firebase Cloud Messaging (FCM)

2. **Permission di Android 13+**
   - User harus approve permission notifikasi
   - Tambahkan request permission di onboarding

3. **Sound Custom**
   - Pastikan file `notif.mp3` ada di `assets/audio/`
   - Format: MP3, durasi pendek (1-3 detik)

4. **iOS Simulator**
   - Notifikasi tidak muncul di iOS Simulator
   - Test di device fisik

---

## 🚀 Next Steps (Opsional)

1. **Firebase Cloud Messaging (FCM)**
   - Notifikasi saat app tertutup
   - Push notification dari server

2. **Notification Action Buttons**
   - "Balas" langsung dari notifikasi
   - "Tandai sudah dibaca"

3. **Grouped Notifications**
   - Gabungkan multiple notifikasi dari user yang sama

4. **Custom Notification Sound per User**
   - Guru bisa set sound berbeda untuk tiap siswa

---

## 📞 Troubleshooting

### Notifikasi tidak muncul?
1. Cek permission di Settings > Apps > Ciloka > Notifications
2. Pastikan `initialize()` dipanggil di `main.dart`
3. Cek log: `flutter logs`

### Suara tidak keluar?
1. Pastikan file `notif.mp3` ada di `assets/audio/`
2. Cek volume device
3. Test dengan `AudioPlayer` langsung

### Error di build?
1. Run `flutter clean`
2. Run `flutter pub get`
3. Rebuild app

---

**Status Implementasi:**
- ✅ NotificationService created
- ✅ Package added to pubspec.yaml
- ⏳ Android configuration (MANUAL - lihat panduan di atas)
- ⏳ Integration ke ChatPage (MANUAL - lihat contoh di atas)
- ⏳ Testing

**File yang Dibuat:**
- `lib/core/services/notification_service.dart`
