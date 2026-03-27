import '../api/socket_service.dart';

/// Tracks a live ride from the passenger's perspective.
/// Joins the ride room and listens for driver location and status updates.
class PassengerRideTracker {
  final SocketService socketService;
  final String activeRideId;

  /// Callback invoked when the driver's coordinates update.
  final void Function(double lat, double lng)? onDriverLocationUpdate;

  /// Callback invoked when the ride status changes (e.g. 'driver_en_route').
  final void Function(String status)? onRideStatusChanged;

  PassengerRideTracker({
    required this.socketService,
    required this.activeRideId,
    this.onDriverLocationUpdate,
    this.onRideStatusChanged,
  }) {
    _setupListeners();
  }

  void _setupListeners() {
    if (socketService.socket == null) {
      print('PassengerRideTracker: socket not connected.');
      return;
    }

    // 1. Join the ride-specific room so the backend routes events to us
    socketService.joinRideRoom(activeRideId);

    // 2. Listen for driver GPS updates
    socketService.socket!.on('driver:location', (data) {
      final double lat = (data['lat'] as num).toDouble();
      final double lng = (data['lng'] as num).toDouble();
      onDriverLocationUpdate?.call(lat, lng);
    });

    // 3. Listen for ride status changes (maps to DB ENUM values)
    socketService.socket!.on('ride:status', (data) {
      final String newStatus = data['status'] as String;
      onRideStatusChanged?.call(newStatus);
    });
  }

  /// Clean up listeners when the screen is disposed.
  void dispose() {
    socketService.off('driver:location');
    socketService.off('ride:status');
  }
}
