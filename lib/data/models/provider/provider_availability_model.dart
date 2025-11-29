class ProviderAvailabilityModel {
  final bool isAvailable;
  final String? unavailableReason;
  final String? startTime;
  final String? endTime;
  final bool? hasScheduleForDay;

  ProviderAvailabilityModel({
    required this.isAvailable,
    this.unavailableReason,
    this.startTime,
    this.endTime,
    this.hasScheduleForDay,
  });

  factory ProviderAvailabilityModel.fromJson(Map<String, dynamic> j) {
    return ProviderAvailabilityModel(
      isAvailable: j['isAvailable'] ?? j['IsAvailable'] ?? false,
      unavailableReason: j['unavailableReason'] ?? j['UnavailableReason'],
      startTime: j['startTime'] ?? j['StartTime'],
      endTime: j['endTime'] ?? j['EndTime'],
      hasScheduleForDay: j['hasScheduleForDay'] ?? j['HasScheduleForDay'],
    );
  }
}
