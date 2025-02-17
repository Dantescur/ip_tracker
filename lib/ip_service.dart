import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:http/http.dart' as http;
import 'ip_data.dart';

const token = 'c1deffcd1c307f';

class IpService {
  static const Duration requestTimeout = Duration(seconds: 10);

  static Future<IpData> fetchIpData(String ip) async {
    try {
      final response = await http
          .get(Uri.parse('https://ipinfo.io/$ip?token=$token'))
          .timeout(requestTimeout);

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
        throw HttpException(
          'Failed to fetch IP data: Status code ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timed out after $requestTimeout');
    } on FormatException {
      throw const FormatException(
        'Invalid data format received from the server',
      );
    } on http.ClientException catch (e) {
      throw HttpException('HTTP client error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
