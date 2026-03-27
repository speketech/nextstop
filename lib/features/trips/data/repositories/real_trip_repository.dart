import 'package:isw_mobile_sdk/isw_mobile_sdk.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/socket_service.dart';
import '../../data/models/trip_model.dart';
import '../../domain/repositories/trip_repository.dart';

class RealTripRepository implements TripRepository {
  final ApiClient apiClient;
  final SocketService socketService;

  RealTripRepository({required this.apiClient, required this.socketService});

  @override
  Future<List<TripModel>> getAvailableTrips() async {
    final response = await apiClient.get('/rides/available');
    return (response.data as List).map((e) => TripModel.fromJson(e)).toList();
  }

  @override
  Future<TripModel> initiateTrip(TripModel trip) async {
    final response = await apiClient.post('/rides/request', data: trip.toJson());
    return TripModel.fromJson(response.data);
  }

  @override
  Future<TripModel> updateTripStatus(String tripId, RideStatus status) async {
    final response = await apiClient.post('/rides/$tripId/status', data: {
      'status': status.name.toUpperCase(),
    });
    return TripModel.fromJson(response.data);
  }

  @override
  Future<TripModel> placeBid(String tripId, String driverId, double bidAmount) async {
    socketService.emit('ride:bid', {
      'trip_id': tripId,
      'driver_id': driverId,
      'amount': bidAmount,
    });
    
    final response = await apiClient.post('/rides/$tripId/bid', data: {
      'driver_id': driverId,
      'amount': bidAmount,
    });
    return TripModel.fromJson(response.data);
  }

  @override
  Future<TripModel> acceptBid(String tripId, String driverId, double amount) async {
    final response = await apiClient.post('/rides/$tripId/accept', data: {
      'driver_id': driverId,
      'amount': amount,
    });
    return TripModel.fromJson(response.data);
  }

  @override
  Future<void> processRidePayment({
    required String rideId,
    required String payerType,
    required String customerName,
    required String customerEmail,
    required String customerId,
  }) async {
    try {
      // 1. Ask Backend to initiate payment and generate txRef
      final initResponse = await apiClient.post('/payments/initiate', data: {
        'rideId': rideId,
        'payerType': payerType,
      });

      if (initResponse.data['success'] != true) {
        throw Exception('Failed to initiate payment: ${initResponse.data['message']}');
      }

      final String txRef = initResponse.data['data']['txRef'];
      final double amountNaira = initResponse.data['data']['amountNaira'].toDouble();
      final int amountKobo = (amountNaira * 100).toInt();

      // 2. Trigger Interswitch Native SDK UI
      var iswPaymentInfo = IswPaymentInfo(
        customerId: customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerMobile: "", 
        reference: txRef,
        amount: amountKobo,
        currencyCode: "566",
      );

      var result = await IswMobileSdk.pay(iswPaymentInfo);

      // 3. Verify Payment on Backend
      if (result.hasValue) {
        String iswTransactionRef = result.value!.transactionReference;
        bool isSuccessful = result.value!.isSuccessful;

        if (isSuccessful) {
          final verifyResponse = await apiClient.post('/payments/verify', data: {
            'txRef': txRef,
          });

          if (verifyResponse.data['success'] != true || verifyResponse.data['data']['verified'] != true) {
            throw Exception('Payment verification failed on server.');
          }
        } else {
          throw Exception('Payment failed inside SDK: ${result.value!.responseCode}');
        }
      } else {
        throw Exception('Payment cancelled by user.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
