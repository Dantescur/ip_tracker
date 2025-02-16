import 'package:flutter/material.dart';
import 'package:ip_tracker/map_widget.dart';
import 'ip_data.dart';
import 'ip_service.dart';

class IpTrackerScreen extends StatefulWidget {
  const IpTrackerScreen({super.key});

  @override
  State<IpTrackerScreen> createState() => _IpTrackerScreenState();
}

class _IpTrackerScreenState extends State<IpTrackerScreen> {
  final TextEditingController _ipController = TextEditingController();
  IpData? _ipData;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchIp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ipData = await IpService.fetchIpData(_ipController.text);
      if (mounted) {
        setState(() => _ipData = ipData);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IP Address Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipController,
                    decoration: InputDecoration(
                      hintText: 'Search for any IP address or domain',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchIp,
                  child: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_ipData != null)
              _buildInfoCard()
            else if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow('IP ADDRESS', _ipData!.ip),
              _buildInfoRow('LOCATION', '${_ipData!.city}, ${_ipData!.region}'),
              _buildInfoRow('TIMEZONE', 'UTC${_ipData!.timezone}'),
              _buildInfoRow('ISP', _ipData!.isp),
              _buildInfoRow('POSTAL CODE', _ipData!.postal),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: IpMap(lat: _ipData!.lat, lng: _ipData!.lng),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
