import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/radar_point.dart';
import '../utils/constants.dart';

class UpdateResult {
  final bool success;
  final int count;
  final String? error;
  const UpdateResult({required this.success, required this.count, this.error});
}

class RadarUpdateService {
  Future<UpdateResult> fetchUpdates() async {
    try {
      final response = await http
          .get(Uri.parse(AppConstants.radarApiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['radares'] as List;
        final radares = list
            .map((e) => RadarPoint.fromJson(e as Map<String, dynamic>))
            .toList();
        return UpdateResult(success: true, count: radares.length);
      }
      return UpdateResult(
          success: false, count: 0, error: 'HTTP ${response.statusCode}');
    } catch (e) {
      return UpdateResult(success: false, count: 0, error: e.toString());
    }
  }
}
