class BusLocationModel {
  final double lat;
  final double lng;
  final double speed;
  final double heading;
  final DateTime updatedAt;

  BusLocationModel({
    required this.lat,
    required this.lng,
    required this.speed,
    required this.heading,
    required this.updatedAt,
  });

  factory BusLocationModel.fromJson(Map<String, dynamic> json) {
    return BusLocationModel(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class BusStopModel {
  final int id;
  final String name;
  final double? lat;
  final double? lng;
  final String? estimatedTime;

  BusStopModel({
    required this.id,
    required this.name,
    this.lat,
    this.lng,
    this.estimatedTime,
  });

  factory BusStopModel.fromJson(Map<String, dynamic> json) {
    return BusStopModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      estimatedTime: json['estimated_time'],
    );
  }
}

class BusRouteInfoModel {
  final int id;
  final String name;
  final String? vehicleNumber;
  final String? driverName;
  final List<BusStopModel> stops;
  final BusLocationModel? currentLocation;
  final int? pickupStopId;
  final int? dropoffStopId;

  BusRouteInfoModel({
    required this.id,
    required this.name,
    this.vehicleNumber,
    this.driverName,
    required this.stops,
    this.currentLocation,
    this.pickupStopId,
    this.dropoffStopId,
  });

  factory BusRouteInfoModel.fromJson(Map<String, dynamic> json) {
    final routeJson = json['route'] ?? {};
    return BusRouteInfoModel(
      id: routeJson['id'] ?? 0,
      name: routeJson['name'] ?? '',
      vehicleNumber: routeJson['vehicle_number'],
      driverName: routeJson['driver_name'],
      stops: (json['stops'] as List? ?? [])
          .map((e) => BusStopModel.fromJson(e))
          .toList(),
      currentLocation: json['current_location'] != null
          ? BusLocationModel.fromJson(json['current_location'])
          : null,
      pickupStopId: json['pickup_stop_id'],
      dropoffStopId: json['dropoff_stop_id'],
    );
  }
}
