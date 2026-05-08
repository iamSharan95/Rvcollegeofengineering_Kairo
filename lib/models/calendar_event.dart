class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final bool requiresCommute;
  final double? latitude;
  final double? longitude;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    this.requiresCommute = false,
    this.latitude,
    this.longitude,
  });

  bool get isUpcoming => startTime.isAfter(DateTime.now());
}
