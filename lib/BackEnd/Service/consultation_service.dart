import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/ConsultationModel.dart';

class ClinicService {
  final String baseUrl = "http://localhost:58691/api/Clinic";

  Future<List<ConsultationModel>> fetchConsultations() async {
    final response = await http.get(Uri.parse('$baseUrl/GetAllConsultations'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['success']) {
        List data = jsonResponse['data'];
        return data.map((item) => ConsultationModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load consultations: ${jsonResponse['message']}");
      }
    } else {
      throw Exception("Failed to fetch consultations");
    }
  }
  Future<Map<String, dynamic>?> saveConsultation(ConsultationModel model) async {
    final url = Uri.parse('$baseUrl/SaveConsultation');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(model.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to save consultation. Status Code: ${response.statusCode}, Body: ${response.body}');
        return {'success': false, 'message': 'Failed to save consultation'};
      }
    } catch (e) {
      print('Error saving consultation: $e');
      return {'success': false, 'message': 'Error saving consultation: $e'};
    }
  }
}
