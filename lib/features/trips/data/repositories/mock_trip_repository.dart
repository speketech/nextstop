import '../../domain/repositories/trip_repository.dart';
import '../models/trip_model.dart';

class MockTripRepository implements TripRepository {
  final List<TripModel> _trips = [];

  @override
  Future<List<TripModel>> getAvailableTrips() async {
    await Future.delayed(const Duration(seconds: 1));
    return _trips.where((t) => t.status == RideStatus.pending_driver_match || t.status == RideStatus.negotiating).toList();
  }

  @override
  Future<TripModel> initiateTrip(TripModel trip) async {
    await Future.delayed(const Duration(seconds: 1));
    _trips.add(trip);
    return trip;
  }

  @override
  Future<TripModel> updateTripStatus(String tripId, RideStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      final old = _trips[index];
      final updated = TripModel(
        id: old.id,
        initiatorId: old.initiatorId,
        driverId: old.driverId,
        vehicleId: old.vehicleId,
        pickupLocationName: old.pickupLocationName,
        pickupLat: old.pickupLat,
        pickupLng: old.pickupLng,
        dropoffLocationName: old.dropoffLocationName,
        dropoffLat: old.dropoffLat,
        dropoffLng: old.dropoffLng,
        proposedFare: old.proposedFare,
        rideType: old.rideType,
        maxJoiners: old.maxJoiners,
        womenOnly: old.womenOnly,
        status: status,
      );
      _trips[index] = updated;
      return updated;
    }
    throw Exception('Trip not found');
  }

  @override
  Future<TripModel> placeBid(String tripId, String driverId, double bidAmount) async {
    return updateTripStatus(tripId, RideStatus.negotiating);
  }

  @override
  Future<TripModel> acceptBid(String tripId, String driverId, double amount) async {
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      final old = _trips[index];
      final updated = TripModel(
        id: old.id,
        initiatorId: old.initiatorId,
        driverId: driverId,
        vehicleId: old.vehicleId,
        pickupLocationName: old.pickupLocationName,
        pickupLat: old.pickupLat,
        pickupLng: old.pickupLng,
        dropoffLocationName: old.dropoffLocationName,
        dropoffLat: old.dropoffLat,
        dropoffLng: old.dropoffLng,
        proposedFare: amount,
        rideType: old.rideType,
        maxJoiners: old.maxJoiners,
        womenOnly: old.womenOnly,
        status: RideStatus.driver_assigned,
      );
      _trips[index] = updated;
      return updated;
    }
    throw Exception('Trip not found');
  }
  @override
  Future<void> processRidePayment({
    required String rideId,
    required String payerType,
    required String customerName,
    required String customerEmail,
    required String customerId,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    print('Mock: Payment processed for ride $rideId');
  }

  @override
  Future<TripModel> getRideDetails(String rideId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _trips.firstWhere(
      (t) => t.id == rideId,
      orElse: () => TripModel(
        id: rideId,
        initiatorId: 'mock-initiator',
        pickupLocationName: 'Lekki Phase 1',
        dropoffLocationName: 'Victoria Island',
        proposedFare: 2500,
        rideType: RideType.ride_share,
        maxJoiners: 3,
        currentJoinersCount: 1,
      ),
    );
  }

  @override
  Future<void> joinRide(String rideId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Mock: Join requested for ride $rideId');
  }
}
