import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import 'package:http_parser/http_parser.dart';

class UploadImageService {
  static const String cloudName = "dfxiksj2m";
  static const String uploadPreset = "ml_default";
  static const String apiKey = "658396959917185";
  static const String apiSecret = "AbaWS-pBpAxpSIPFdfrZEdJjCxA";

  Future<String> uploadToCloudinary(
    File file, {
    String folder = "ciloka-app/student-profile",
  }) async {
    try {
      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = uploadPreset
        ..fields["folder"] = folder
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: MediaType.parse(mimeType),
            filename: p.basename(file.path),
          ),
        );

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(resBody);
        final imageUrl = data["secure_url"];
        if (imageUrl == null) {
          throw Exception("URL gambar tidak ditemukan di response Cloudinary.");
        }
        debugPrint("✅ Upload berhasil: $imageUrl");
        return imageUrl;
      } else {
        debugPrint("❌ Upload gagal: ${response.statusCode}, $resBody");
        throw ("Upload gagal ke Cloudinary (${response.statusCode})");
      }
    } on SocketException {
      throw ("Tidak ada koneksi internet.");
    } on http.ClientException {
      throw ("Koneksi ke Cloudinary gagal.");
    } catch (e) {
      debugPrint("⚠️ Error saat upload ke Cloudinary: $e");
      rethrow;
    }
  }

  Future<String> uploadImgMessageToCloudinary(
    File file, {
    String folder = "ciloka-app/chat-messages",
  }) async {
    try {
      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = uploadPreset
        ..fields["folder"] = folder
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: MediaType.parse(mimeType),
            filename: p.basename(file.path),
          ),
        );

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(resBody);
        final imageUrl = data["secure_url"];
        if (imageUrl == null) {
          throw Exception("URL gambar tidak ditemukan di response Cloudinary.");
        }
        debugPrint("✅ Upload berhasil: $imageUrl");
        return imageUrl;
      } else {
        debugPrint("❌ Upload gagal: ${response.statusCode}, $resBody");
        throw ("Upload gagal ke Cloudinary (${response.statusCode})");
      }
    } on SocketException {
      throw ("Tidak ada koneksi internet.");
    } on http.ClientException {
      throw ("Koneksi ke Cloudinary gagal.");
    } catch (e) {
      debugPrint("⚠️ Error saat upload ke Cloudinary: $e");
      rethrow;
    }
  }

  // Ekstrak public_id dari URL Cloudinary
  Future<void> deleteFromCloudinary(String imageUrl) async {
    try {
      final publicId = _extractPublicId(imageUrl);
      if (publicId == null) throw ('public_id tidak ditemukan dari URL');

      final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

      final signatureBase =
          'public_id=$publicId&timestamp=$timestamp$apiSecret';
      final bytes = utf8.encode(signatureBase);
      final signature = _sha1(bytes);

      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/destroy',
      );
      final response = await http.post(
        url,
        body: {
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'public_id': publicId,
          'signature': signature,
        },
      );

      if (response.statusCode != 200) {
        throw ('Gagal menghapus gambar Cloudinary');
      }
    } catch (e) {
      debugPrint('⚠️ Gagal menghapus gambar Cloudinary: $e');
    }
  }

  // untuk signature Cloudinary
  String? _extractPublicId(String imageUrl) {
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      final index = segments.indexOf('upload');
      if (index != -1 && index + 1 < segments.length) {
        final fileName = segments.sublist(index + 1).join('/');
        return fileName.split('.').first;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _sha1(List<int> bytes) {
    final digest = sha1.convert(bytes);
    return digest.toString();
  }
}
