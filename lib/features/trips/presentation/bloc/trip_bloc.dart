import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
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
    on<GetRideDetails>(_onGetRideDetails);
    on<JoinRide>(_onJoinRide);
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
      final message = (e is DioException) ? (e.message ?? e.toString()) : e.toString();
      emit(TripError(message));
    }
  }

  Future<void> _onInitiateTrip(InitiateTrip event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trip = await tripRepository.initiateTrip(event.trip);
      emit(TripSuccess(trip));
    } catch (e) {
      final message = (e is DioException) ? (e.message ?? e.toString()) : e.toString();
      emit(TripError(message));
    }
  }

  Future<void> _onUpdateTripStatus(UpdateTripStatus event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trip = await tripRepository.updateTripStatus(event.tripId, event.status);
      emit(TripSuccess(trip));
    } catch (e) {
      final message = (e is DioException) ? (e.message ?? e.toString()) : e.toString();
      emit(TripError(message));
    }
  }

  Future<void> _onPlaceBid(PlaceBid event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trip = await tripRepository.placeBid(event.tripId, event.driverId, event.bidAmount);
      emit(TripSuccess(trip));
    } catch (e) {
      final message = (e is DioException) ? (e.message ?? e.toString()) : e.toString();
      emit(TripError(message));
    }
  }

  Future<void> _onAcceptBid(AcceptBid event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trip = await tripRepository.acceptBid(event.tripId, event.driverId, event.amount);
      emit(TripSuccess(trip));
    } catch (e) {
      final message = (e is DioException) ? (e.message ?? e.toString()) : e.toString();
      emit(TripError(message));
    }
  }

  Future<void> _onGetRideDetails(GetRideDetails event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trip = await tripRepository.getRideDetails(event.rideId);
      emit(TripSuccess(trip));
    } catch (e) {
      final message = (e is DioException) ? (e.message ?? e.toString()) : e.toString();
      emit(TripError(message));
    }
  }

  Future<void> _onJoinRide(JoinRide event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      await tripRepository.joinRide(event.rideId);
      // Usually, after joining, we might want to refresh ride details
      final trip = await tripRepository.getRideDetails(event.rideId);
      emit(TripSuccess(trip));
    } catch (e) {
      final message = (e is DioException) ? (e.message ?? e.toString()) : e.toString();
      emit(TripError(message));
    }
  }
}
