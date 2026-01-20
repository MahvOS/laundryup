import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://api2.laundryapp.it4you.id';

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String emailOrPhone,
    String password,
    String whatsapp,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email_or_phone': emailOrPhone,
        'password': password,
        'whatsapp': whatsapp,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Registrasi gagal',
      );
    }
  }

  static Future<Map<String, dynamic>> login(
    String emailOrPhone,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email_or_phone': emailOrPhone, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', data['user']['id']);
      await prefs.setString('user_name', data['user']['name'] ?? '');
      await prefs.setString('user_role', data['user']['role'] ?? 'customer');
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login gagal');
    }
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  static Future<Map<String, int>> getOrderCounts() async {
    final response = await http.get(Uri.parse('$baseUrl/staff/order-counts'));
    if (response.statusCode == 200) {
      return Map<String, int>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load order counts');
    }
  }

  static Future<void> updateBookingStatus(
    int bookingId,
    String status,
    String? notes,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/staff/bookings/$bookingId/update-status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'new_status': status,
        'updated_by': 'Staff',
        'notes': notes,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Failed to update status',
      );
    }
  }

  static Future<Map<String, dynamic>> createBookingForCustomer({
    required String customerPhone,
    required int serviceId,
    required String bookingDate,
    required String timeSlot,
    required String deliveryType,
    required double estimatedTotal,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customer_phone': customerPhone,
        'service_id': serviceId,
        'booking_date': bookingDate,
        'time_slot': timeSlot,
        'delivery_type': deliveryType,
        'estimated_total': estimatedTotal,
        'notes': notes,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Booking gagal');
    }
  }

  static Future<List<dynamic>> getServices() async {
    final response = await http.get(Uri.parse('$baseUrl/services'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil layanan');
    }
  }

  static Future<Map<String, dynamic>> createBooking({
    required int serviceId,
    required String bookingDate,
    required String timeSlot,
    required String deliveryType,
    required double estimatedTotal,
    String? notes,
  }) async {
    final userId = await getUserId();
    if (userId == null) throw Exception('User tidak login');

    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'service_id': serviceId,
        'booking_date': bookingDate,
        'time_slot': timeSlot,
        'delivery_type': deliveryType,
        'estimated_total': estimatedTotal,
        'notes': notes,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Booking gagal');
    }
  }

  static Future<List<dynamic>> getUserBookings() async {
    final userId = await getUserId();
    if (userId == null) throw Exception('User tidak login');

    final response = await http.get(
      Uri.parse('$baseUrl/bookings?user_id=$userId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil booking');
    }
  }

  static Future<Map<String, dynamic>> getBookingStatus(int bookingId) async {
    final userId = await getUserId();
    if (userId == null) throw Exception('User tidak login');

    final response = await http.get(
      Uri.parse('$baseUrl/bookings/$bookingId/status?user_id=$userId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Gagal mengambil status',
      );
    }
  }

  static Future<void> deleteBooking(int bookingId) async {
    final userId = await getUserId();
    if (userId == null) throw Exception('User tidak login');

    final response = await http.delete(
      Uri.parse('$baseUrl/bookings/$bookingId?user_id=$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Gagal menghapus booking',
      );
    }
  }

  static Future<void> staffDeleteBooking(int bookingId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/staff/bookings/$bookingId'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Gagal menghapus booking',
      );
    }
  }
}
