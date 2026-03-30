import 'package:isw_mobile_sdk/isw_mobile_sdk.dart';
import 'package:isw_mobile_sdk/models/isw_mobile_sdk_payment_info.dart';
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
    final Map<String, dynamic> socketData = <String, dynamic>{
      'trip_id': tripId,
      'driver_id': driverId,
      'amount': bidAmount,
    };
    socketService.emit('ride:bid', socketData);
    
    final Map<String, dynamic> postData = <String, dynamic>{
      'driver_id': driverId,
      'amount': bidAmount,
    };
    final response = await apiClient.post('/rides/$tripId/bid', data: postData);
    return TripModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TripModel> acceptBid(String tripId, String driverId, double amount) async {
    final response = await apiClient.post('/rides/$tripId/accept', data: <String, dynamic>{
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
      final initResponse = await apiClient.post('/payments/initiate', data: <String, dynamic>{
        'rideId': rideId,
        'payerType': payerType,
      });

      if (initResponse.data['success'] != true) {
        throw Exception('Failed to initiate payment: ${initResponse.data['message']}');
      }

      final String txRef = initResponse.data['data']['txRef']?.toString() ?? "";
      final double amountNaira = (initResponse.data['data']['amountNaira'] as num?)?.toDouble() ?? 0.0;

      // 2. Trigger Interswitch Native SDK UI
      var iswPaymentInfo = IswPaymentInfo(
        customerId,
        customerName,
        customerEmail,
        "", // customerMobile
        txRef,
        (amountNaira * 100).toInt(),
      );

      var result = await IswMobileSdk.pay(iswPaymentInfo);

      // 3. Verify Payment on Backend
      if (result.hasValue) {
        String iswTransactionRef = result.value?.transactionReference ?? "";
        bool isSuccessful = result.value?.isSuccessful ?? false;

        print('Interswitch Transaction Ref: $iswTransactionRef');

        if (isSuccessful) {
          final verifyResponse = await apiClient.post('/payments/verify', data: <String, dynamic>{
            'txRef': txRef,
            'iswRef': iswTransactionRef,
          });

          if (verifyResponse.data['success'] != true || verifyResponse.data['data']['verified'] != true) {
            throw Exception('Payment verification failed on server.');
          }
        } else {
          throw Exception('Payment failed inside SDK: ${result.value?.responseCode ?? "Unknown Error"}');
        }
      } else {
        throw Exception('Payment cancelled by user.');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TripModel> getRideDetails(String rideId) async {
    final response = await apiClient.get('/rides/$rideId');
    return TripModel.fromJson(response.data);
  }

  @override
  Future<void> joinRide(String rideId) async {
    await apiClient.post('/rides/$rideId/join');
  }
}
