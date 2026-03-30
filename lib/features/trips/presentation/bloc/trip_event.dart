import 'package:equatable/equatable.dart';
import '../../data/models/trip_model.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class InitiateTrip extends TripEvent {
  final TripModel trip;
  const InitiateTrip(this.trip);

  @override
  List<Object?> get props => [trip];
}

class UpdateTripStatus extends TripEvent {
  final String tripId;
  final RideStatus status;
  const UpdateTripStatus(this.tripId, this.status);

  @override
  List<Object?> get props => [tripId, status];
}

class PlaceBid extends TripEvent {
  final String tripId;
  final String driverId;
  final double bidAmount;
  const PlaceBid(this.tripId, this.driverId, this.bidAmount);

  @override
  List<Object?> get props => [tripId, driverId, bidAmount];
}

class AcceptBid extends TripEvent {
  final String tripId;
  final String driverId;
  final double amount;
  const AcceptBid(this.tripId, this.driverId, this.amount);

  @override
  List<Object?> get props => [tripId, driverId, amount];
}

class ProcessPayment extends TripEvent {
  final String rideId;
  final String payerType;
  final String customerName;
  final String customerEmail;
  final String customerId;

  const ProcessPayment({
    required this.rideId,
    required this.payerType,
    required this.customerName,
    required this.customerEmail,
    required this.customerId,
  });

  @override
  List<Object?> get props => [rideId, payerType, customerName, customerEmail, customerId];
}

class GetRideDetails extends TripEvent {
  final String rideId;
  const GetRideDetails(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

class JoinRide extends TripEvent {
  final String rideId;
  const JoinRide(this.rideId);

  @override
  List<Object?> get props => [rideId];
}
