import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ip_data.dart';

const token = 'c1deffcd1c307f';

class IpService {
  static Future<IpData> fetchIpData(String ip) async {
    final response = await http.get(
      Uri.parse('https://ipinfo.io/$ip?token=$token'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['loc']?.split(',') ?? ['0', '0'];

      return IpData(
        ip: data['ip'] ?? 'N/A',
        city: data['city'] ?? 'N/A',
        region: data['region'] ?? 'N/A',
        timezone: data['timezone'] ?? 'UTC',
        isp: data['org'] ?? 'N/A',
        postal: data['postal'] ?? 'N/A',
        lat: double.parse(coords[0]),
        lng: double.parse(coords[1]),
      );
    } else {
      throw Exception('Failed to fetch ip data.');
    }
  }
}
