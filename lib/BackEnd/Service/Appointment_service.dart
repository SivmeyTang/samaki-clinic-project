import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:samaki_clinic/BackEnd/Model/Appointment_model.dart';


class AppointmentService {
  final String baseUrl = 'http://localhost:58691'; // Base URL is cleaner

  Future<List<Appointment>> getAllAppointments() async {
    final response = await http.get(Uri.parse('$baseUrl/api/Clinic/GetAllAppointments'));

    if (response.statusCode == 200) {
      final List<dynamic> appointmentsJson = json.decode(response.body);
      return appointmentsJson.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  /// Posts a new appointment and handles the specific backend response.
  Future<void> postAppointment(Appointment appointment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Clinic/PostAppointment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(appointment.toJson()),
    );

    // --- FIX IS HERE ---
    // Check for a successful status code. If the server sends a plain string
    // on success, we don't need to decode the body as JSON.
    if (response.statusCode != 200) {
      // If there is an error, try to decode the message, otherwise show a generic error.
      try {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final String message = responseBody['message'];
        throw Exception(message);
      } catch (e) {
       throw Exception('Please make sure you have already registered with Clinic!');
      }
    }
    // If statusCode is 200, we assume success and do nothing.
  }

  /// Updates an existing appointment via a PUT request.
  Future<void> updateAppointment(Appointment appointment) async {
    if (appointment.appointmentId == null) {
      throw Exception("Appointment ID is missing, cannot update.");
    }
    
    final response = await http.put(
      Uri.parse('$baseUrl/api/Clinic/UpdateAppointment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(appointment.toJson()),
    );
    
    // --- FIX IS HERE ---
    // Your server is likely sending a plain text success message, not a JSON object.
    // The correct way to check for success is to rely on the HTTP status code.
    if (response.statusCode != 200) {
       // If the server sends an error, it might be a JSON object with a message.
       // We try to parse it, but if it fails, we show a generic error.
      try {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final String message = responseBody['message'];
        throw Exception(message);
      } catch (e) {
         throw Exception('Failed to update appointment. Server returned status ${response.statusCode}');
      }
    }
    // If statusCode is 200, the operation was successful. We don't need to parse the body.
  }
}