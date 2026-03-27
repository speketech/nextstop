import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/trip_repository.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository tripRepository;

  TripBloc({required this.tripRepository}) : super(TripInitial()) {
    on<InitiateTrip>(_onInitiateTrip);
    on<UpdateTripStatus>(_onUpdateTripStatus);
    on<PlaceBid>(_onPlaceBid);
    on<AcceptBid>(_onAcceptBid);
    on<ProcessPayment>(_onProcessPayment);
  }

  Future<void> _onProcessPayment(ProcessPayment event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      await tripRepository.processRidePayment(
        rideId: event.rideId,
        payerType: event.payerType,
        customerName: event.customerName,
        customerEmail: event.customerEmail,
        customerId: event.customerId,
      );
      emit(PaymentSuccess());
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onInitiateTrip(InitiateTrip event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trip = await tripRepository.initiateTrip(event.trip);
      emit(TripSuccess(trip));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onUpdateTripStatus(UpdateTripStatus event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trip = await tripRepository.updateTripStatus(event.tripId, event.status);
      emit(TripSuccess(trip));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onPlaceBid(PlaceBid event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trip = await tripRepository.placeBid(event.tripId, event.driverId, event.bidAmount);
      emit(TripSuccess(trip));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onAcceptBid(AcceptBid event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trip = await tripRepository.acceptBid(event.tripId, event.driverId, event.amount);
      emit(TripSuccess(trip));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }
}
