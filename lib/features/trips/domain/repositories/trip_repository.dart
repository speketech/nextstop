import '../../data/models/trip_model.dart';

abstract class TripRepository {
  Future<List<TripModel>> getAvailableTrips();
  Future<TripModel> initiateTrip(TripModel trip);
  Future<TripModel> updateTripStatus(String tripId, RideStatus status);
  Future<TripModel> placeBid(String tripId, String driverId, double bidAmount);
  Future<TripModel> acceptBid(String tripId, String driverId, double amount);
  Future<void> processRidePayment({
    required String rideId,
    required String payerType,
    required String customerName,
    required String customerEmail,
    required String customerId,
  });
  Future<TripModel> getRideDetails(String rideId);
  Future<void> joinRide(String rideId);
}
