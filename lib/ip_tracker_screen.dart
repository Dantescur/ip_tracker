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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
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
      appBar: AppBar(
        title: const Text('IP Address Tracker'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        // Wrap the entire body in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ipController,
                      decoration: InputDecoration(
                        hintText: 'Enter an IP address or domain',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _searchIp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Loading Indicator
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_ipData != null)
                _buildInfoCard()
              else if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Column(
      children: [
        // IP Information Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow('IP ADDRESS', _ipData!.ip),
              const Divider(height: 20, thickness: 1),
              _buildInfoRow('LOCATION', '${_ipData!.city}, ${_ipData!.region}'),
              const Divider(height: 20, thickness: 1),
              _buildInfoRow('TIMEZONE', 'UTC${_ipData!.timezone}'),
              const Divider(height: 20, thickness: 1),
              _buildInfoRow('ISP', _ipData!.isp),
              const Divider(height: 20, thickness: 1),
              _buildInfoRow('POSTAL CODE', _ipData!.postal),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Map Widget
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
