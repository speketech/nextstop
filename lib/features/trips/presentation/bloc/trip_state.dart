import 'package:equatable/equatable.dart';
import '../../data/models/trip_model.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripSuccess extends TripState {
  final TripModel trip;
  const TripSuccess(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripError extends TripState {
  final String message;
  const TripError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentSuccess extends TripState {}

class AvailableTripsLoaded extends TripState {
  final List<TripModel> trips;
  const AvailableTripsLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}
