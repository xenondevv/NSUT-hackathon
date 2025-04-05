
// nearby_service.dart
import 'package:nearby_connections/nearby_connections.dart';

class NearbyService {
  static final NearbyService _instance = NearbyService._internal();
  factory NearbyService() => _instance;

  NearbyService._internal();

  final Strategy strategy = Strategy.P2P_CLUSTER;

  final List<String> discoveredDevices = [];
  final List<String> connectedDevices = [];

  void start() async {
    await startAdvertising();
    await startDiscovery();
  }

  Future<void> startDiscovery() async {
    try {
      await Nearby().startDiscovery(
        'YourDeviceName',
        strategy,
        onEndpointFound: (id, name, serviceId) {
          if (!discoveredDevices.contains(name)) {
            discoveredDevices.add(name);
          }
          Nearby().requestConnection(
            'YourDeviceName',
            id,
            onConnectionInitiated: onConnectionInitiated,
            onConnectionResult: (id, status) {
              print('Connection result: $status');
            },
            onDisconnected: (id) {
              print('Disconnected from: $id');
            },
          );
        },
        onEndpointLost: (id) {
          print('Device lost: $id');
        },
      );
    } catch (e) {
      print('Discovery error: $e');
    }
  }

  Future<void> startAdvertising() async {
    try {
      await Nearby().startAdvertising(
        'YourDeviceName',
        strategy,
        onConnectionInitiated: onConnectionInitiated,
        onConnectionResult: (id, status) {
          print('Connection result: $status');
        },
        onDisconnected: (id) {
          print('Disconnected from: $id');
        },
      );
    } catch (e) {
      print('Advertising error: $e');
    }
  }

  void onConnectionInitiated(String id, ConnectionInfo info) {
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endpointId, payload) {
        print('Payload from $endpointId: ${String.fromCharCodes(payload.bytes!)}');
      },
      onPayloadTransferUpdate: (endpointId, update) {
        print('Transfer update: $update');
      },
    );
    if (!connectedDevices.contains(info.endpointName)) {
      connectedDevices.add(info.endpointName);
    }
  }

  void stopAll() {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
  }
}
