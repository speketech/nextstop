import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketService {
  static final String _serverUrl =
      dotenv.env['SOCKET_URL'] ?? 'https://nextstop-api-ua95.onrender.com';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  IO.Socket? socket;

  // ─── 1. Initialize and Connect ───────────────────────────────────────────
  Future<void> connect() async {
    if (socket != null && socket!.connected) return;

    final String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      print('Socket Error: No auth token found. User must be logged in.');
      return;
    }

    socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token}) // Backend middleware validates this
          .build(),
    );

    socket?.connect();

    socket?.onConnect((_) => print('Connected to Real-Time Server'));
    socket?.onDisconnect((_) => print('Disconnected from Real-Time Server'));
    socket?.onConnectError((err) => print('Socket Connection Error: $err'));
  }

  // Legacy method for backward compatibility with AuthBloc
  void initSocket(String jwtToken) {
    if (socket != null && socket!.connected) return;

    socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': jwtToken})
          .build(),
    );
    socket?.connect();
    socket?.onConnect((_) => print('Socket connected (via initSocket)'));
    socket?.onDisconnect((_) => print('Socket disconnected'));
    socket?.onConnectError((err) => print('Socket error: $err'));
  }

  // ─── 2. Join a Specific Ride Room ────────────────────────────────────────
  // Both driver and passenger call this when a ride is accepted.
  void joinRideRoom(String rideId) {
    if (socket != null && socket!.connected) {
      socket!.emit('ride:join_room', {'rideId': rideId});
      print('Joined real-time room for ride: $rideId');
    } else {
      print('Socket not connected — cannot join ride room $rideId');
    }
  }

  // ─── 3. Emit an event ────────────────────────────────────────────────────
  void emit(String event, dynamic data) {
    socket?.emit(event, data);
  }

  // ─── 4. Listen for an event ──────────────────────────────────────────────
  void on(String event, Function(dynamic) handler) {
    socket?.on(event, handler);
  }

  // ─── 5. Remove a listener ────────────────────────────────────────────────
  void off(String event) {
    socket?.off(event);
  }

  // ─── 6. Disconnect (call on logout) ──────────────────────────────────────
  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }

  // Alias for backward compat
  void dispose() => disconnect();
}
