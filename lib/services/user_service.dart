import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String _baseUrl =
      "https://us-central1-event-booking-app.cloudfunctions.net/getAllUsers";

  static Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load users");
    }
  }
}
