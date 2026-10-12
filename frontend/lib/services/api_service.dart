import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/music.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  static Map<String, String> authHeaders(String token) {
    final normalized = token.trim();
    if (normalized.isEmpty) {
      return {};
    }

    final bearerToken =
        normalized.startsWith('Bearer ') ? normalized : 'Bearer $normalized';

    return {
      'Authorization': bearerToken,
    };
  }

  static Future<List<Music>> getMusic() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/music'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load music: ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body);

    if (body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to load music',
      );
    }

    final List<dynamic> data = body['data'] ?? [];

    return data
        .map(
          (item) => Music.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static String getFileUrl(String fileUrl) {
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    }

    return '$baseUrl$fileUrl';
  }

  static Future<Map<String, dynamic>> createMusicPayment({
    required int musicId,
    required String method,
    String? phone,
    String? email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/payments/music/$musicId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'method': method,
        'phone': phone,
        'email': email,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 201 || body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to create payment',
      );
    }

    return Map<String, dynamic>.from(body);
  }

  static Future<Map<String, dynamic>> completePayment(
    String reference,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/payments/complete/$reference',
      ),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to complete payment',
      );
    }

    return Map<String, dynamic>.from(body);
  }

  static Future<Map<String, dynamic>> getDownload(
    String downloadKey,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/downloads/$downloadKey',
      ),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to process download',
      );
    }

    return Map<String, dynamic>.from(body);
  }

  static Future<Map<String, dynamic>> createBooking({
    required String name,
    required String email,
    required String phone,
    required String eventDate,
    required String eventType,
    required String location,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/bookings'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'eventDate': eventDate,
        'eventType': eventType,
        'location': location,
        'message': message,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to create booking',
      );
    }

    return Map<String, dynamic>.from(body);
  }

  static Future<Map<String, dynamic>> createDonation({
    required int amount,
    String? name,
    String? email,
    String? phone,
    required String method,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/payments/donation'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'name': name,
        'email': email,
        'phone': phone,
        'method': method,
        'message': message,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to create donation',
      );
    }

    return Map<String, dynamic>.from(body);
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      );

      if (response.statusCode != 200) {
        return false;
      }

      final body = jsonDecode(response.body);

      return body['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getVideos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/videos'),
    );
    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load videos');
    }

    final data = body['data'] as List<dynamic>? ?? const [];
    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  static Future<List<Map<String, dynamic>>> getBookings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bookings'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load bookings: ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body);

    if (body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to load bookings',
      );
    }

    final List<dynamic> data = body['data'] ?? [];

    return data
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  static Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Admin login failed');
    }

    final user = Map<String, dynamic>.from(body['user'] as Map);
    if (user['role'] != 'ADMIN') {
      throw Exception('This account does not have admin access.');
    }

    return {
      'token': body['token'] as String,
      'user': user,
    };
  }

  static Future<Map<String, dynamic>> getAdminDashboard(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/dashboard'),
      headers: authHeaders(token),
    );
    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load dashboard');
    }

    return Map<String, dynamic>.from(body['dashboard'] as Map);
  }

  static Future<List<Map<String, dynamic>>> getAdminMusic(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/music'),
      headers: authHeaders(token),
    );
    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load music');
    }

    return (body['data'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getAdminBookings(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/bookings'),
      headers: authHeaders(token),
    );
    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load bookings');
    }

    return (body['data'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getAdminVideos(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/videos'),
      headers: authHeaders(token),
    );
    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load videos');
    }

    return (body['data'] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getAdminPayments(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/payments'),
      headers: authHeaders(token),
    );
    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load payments');
    }

    return (body['data'] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getAdminDonations(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/donations'),
      headers: authHeaders(token),
    );
    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load donations');
    }

    return (body['data'] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getAdminDownloads(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/downloads'),
      headers: authHeaders(token),
    );
    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load downloads');
    }

    return (body['data'] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<Map<String, dynamic>> getAdminHomepage(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/homepage'),
      headers: authHeaders(token),
    );
    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load homepage content');
    }

    final data = body['data'];
    return {
      'sliders': (data['sliders'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      'socialLinks': (data['socialLinks'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      'siteSettings': (data['siteSettings'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    };
  }

  static Future<List<Map<String, dynamic>>> getAdminSettings(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/settings'),
      headers: authHeaders(token),
    );
    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load settings');
    }

    return (body['data'] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<void> uploadAdminMusic({
    required String token,
    required String title,
    required String artist,
    required int price,
    required String filename,
    required List<int> bytes,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/uploads/music'),
    )
      ..headers.addAll(authHeaders(token))
      ..files.add(
        http.MultipartFile.fromBytes(
          'audio',
          bytes,
          filename: filename,
        ),
      );
    final uploadResponse = await http.Response.fromStream(
      await request.send(),
    );
    final uploadBody = jsonDecode(uploadResponse.body);

    if (uploadResponse.statusCode != 201 || uploadBody['success'] != true) {
      throw Exception(uploadBody['message'] ?? 'Failed to upload audio');
    }

    final uploadData = Map<String, dynamic>.from(uploadBody['data'] as Map);
    final createResponse = await http.post(
      Uri.parse('$baseUrl/api/music'),
      headers: {
        'Content-Type': 'application/json',
        ...authHeaders(token),
      },
      body: jsonEncode({
        'title': title,
        'artist': artist,
        'audioUrl': uploadData['url'],
        'price': price,
        'isPublished': true,
      }),
    );
    final createBody = jsonDecode(createResponse.body);

    if (createResponse.statusCode != 201 || createBody['success'] != true) {
      throw Exception(
        createBody['message'] ??
            'Audio uploaded, but the music record could not be created.',
      );
    }
  }
}
