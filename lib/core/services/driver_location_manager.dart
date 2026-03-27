import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'socket_service.dart';

/// Manages GPS streaming and broadcasts the driver's location
/// to the backend via WebSockets.
class DriverLocationManager {
  final SocketService socketService;
  StreamSubscription<Position>? _positionStream;

  DriverLocationManager(this.socketService);

  /// Call when the driver goes online or starts a trip.
  Future<void> startBroadcasting() async {
    // Ensure socket is connected
    await socketService.connect();

    // Check and request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      print('Location permission denied — cannot broadcast.');
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // only update if driver moves 10 metres
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (socketService.socket != null && socketService.socket!.connected) {
        socketService.socket!.emit('driver:location', {
          'lat': position.latitude,
          'lng': position.longitude,
        });
      }
    });
  }

  /// Call when the driver goes offline or the trip ends.
  void stopBroadcasting() {
    _positionStream?.cancel();
    _positionStream = null;
  }
}
