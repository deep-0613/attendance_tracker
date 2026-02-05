import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class WifiScannerScreen extends StatefulWidget {
  const WifiScannerScreen({Key? key}) : super(key: key);

  @override
  _WifiScannerScreenState createState() => _WifiScannerScreenState();
}

class _WifiScannerScreenState extends State<WifiScannerScreen> {
  List<WiFiAccessPoint> accessPoints = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Check and request location permission
      PermissionStatus permission = await Permission.location.status;
      if (!permission.isGranted) {
        permission = await Permission.location.request();
        if (!permission.isGranted) {
          setState(() {
            _errorMessage = 'Location permission is required for WiFi scanning.\n\nPlease enable it in app settings.';
            _isLoading = false;
          });
          return;
        }
      }

      // Check if location services are enabled
      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled.\n\nPlease enable location services to scan for WiFi networks.';
          _isLoading = false;
        });
        // Optionally open location settings
        // await Geolocator.openLocationSettings();
        return;
      }

      // Check if WiFi scanning is supported
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan != CanStartScan.yes) {
        String errorMsg = 'Cannot start WiFi scan: ';
        if (canScan == CanStartScan.noLocationPermissionDenied) {
          errorMsg += 'Location permission denied. Please enable it in app settings.';
        } else if (canScan == CanStartScan.noLocationServiceDisabled) {
          errorMsg += 'Location services are disabled. Please enable them in device settings.';
        } else {
          errorMsg += canScan.toString();
        }
        
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
        return;
      }

      // Start scan and get results
      await WiFiScan.instance.startScan();
      final results = await WiFiScan.instance.getScannedResults();
      
      setState(() {
        accessPoints = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error scanning for WiFi: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Networks'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startScan,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, 
                color: Colors.orange, 
                size: 50,
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('TRY AGAIN'),
                onPressed: _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Geolocator.openLocationSettings();
                },
                child: const Text('Open Location Settings'),
              ),
            ],
          ),
        ),
      );
    }

    if (accessPoints.isEmpty) {
      return const Center(
        child: Text('No WiFi networks found'),
      );
    }

    return ListView.builder(
      itemCount: accessPoints.length,
      itemBuilder: (context, index) {
        final ap = accessPoints[index];
        return ListTile(
          leading: _getSignalIcon(ap.level),
          title: Text(ap.ssid.isNotEmpty ? ap.ssid : 'Hidden Network'),
          subtitle: Text('Signal: ${ap.level} dBm\nBSSID: ${ap.bssid}'),
          trailing: Text('${ap.frequency} MHz'),
        );
      },
    );
  }

  Widget _getSignalIcon(int level) {
    // Convert dBm to a 0-100 range
    final quality = (100 + level) / 100 * 100;
    IconData icon;
    Color color;

    if (quality > 75) {
      icon = Icons.wifi;
      color = Colors.green;
    } else if (quality > 50) {
      icon = Icons.wifi;
      color = Colors.lightGreen;
    } else if (quality > 25) {
      icon = Icons.wifi_2_bar;
      color = Colors.orange;
    } else {
      icon = Icons.wifi_1_bar;
      color = Colors.red;
    }

    return Icon(icon, color: color);
  }
}
