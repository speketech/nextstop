/// Maps to the `rides` table status ENUM exactly
enum RideStatus {
  pending_driver_match,
  driver_assigned,
  driver_en_route,
  arrived_pickup,
  in_progress,
  completed,
  cancelled,
  // Legacy / negotiation state (app-side only, not in DB)
  negotiating,
}

/// Maps to the `rides` table ride_type ENUM exactly
enum RideType { ride_alone, ride_share }

class TripModel {
  final String id;
  final String initiatorId;
  final String? driverId;

  // Schema: pickup_location_name / dropoff_location_name
  final String pickupLocationName;
  final double? pickupLat;
  final double? pickupLng;
  final String dropoffLocationName;
  final double? dropoffLat;
  final double? dropoffLng;

  final RideType rideType;
  final int maxJoiners;
  final int currentJoinersCount;
  final bool womenOnly;

  // Schema: proposed_fare / final_fare
  final double proposedFare;
  final double? finalFare;
  final RideStatus status;

  TripModel({
    required this.id,
    required this.initiatorId,
    this.driverId,
    required this.pickupLocationName,
    this.pickupLat,
    this.pickupLng,
    required this.dropoffLocationName,
    this.dropoffLat,
    this.dropoffLng,
    required this.proposedFare,
    this.finalFare,
    this.rideType = RideType.ride_alone,
    this.maxJoiners = 0,
    this.currentJoinersCount = 0,
    this.womenOnly = false,
    this.status = RideStatus.pending_driver_match,
  });

  /// Convenience getter for backwards-compatibility with UI code
  double get baseFare => proposedFare;
  String get pickupAddress => pickupLocationName;
  String get dropoffAddress => dropoffLocationName;

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['ride_id'] ?? json['id'] ?? '',
      initiatorId: json['initiator_id'] ?? '',
      driverId: json['driver_id'],
      pickupLocationName: json['pickup_location_name'] ?? '',
      pickupLat: (json['pickup_lat'] as num?)?.toDouble(),
      pickupLng: (json['pickup_lng'] as num?)?.toDouble(),
      dropoffLocationName: json['dropoff_location_name'] ?? '',
      dropoffLat: (json['dropoff_lat'] as num?)?.toDouble(),
      dropoffLng: (json['dropoff_lng'] as num?)?.toDouble(),
      proposedFare: (json['proposed_fare'] as num?)?.toDouble() ?? 0.0,
      finalFare: (json['final_fare'] as num?)?.toDouble(),
      // Schema ride_type: 'ride_alone' | 'ride_share'
      rideType: json['ride_type'] == 'ride_share' ? RideType.ride_share : RideType.ride_alone,
      maxJoiners: json['max_joiners'] ?? 0,
      currentJoinersCount: json['current_joiners_count'] ?? 0,
      womenOnly: json['women_only'] ?? false,
      status: RideStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending_driver_match'),
        orElse: () => RideStatus.pending_driver_match,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ride_id': id,
      'initiator_id': initiatorId,
      'driver_id': driverId,
      'pickup_location_name': pickupLocationName,
      'dropoff_location_name': dropoffLocationName,
      'proposed_fare': proposedFare,
      'final_fare': finalFare,
      // Schema stores lowercase with underscore
      'ride_type': rideType.name,
      'max_joiners': maxJoiners,
      'current_joiners_count': currentJoinersCount,
      'women_only': womenOnly,
      'status': status.name,
    };
  }
}
