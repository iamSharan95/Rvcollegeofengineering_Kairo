import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../services/google_api_service.dart';
import '../services/geocoding_service.dart';

class CalendarProvider with ChangeNotifier {
  final GoogleApiService _apiService;
  final GeocodingService _geocodingService = GeocodingService();
  List<CalendarEvent> _events = [];
  bool _isSyncing = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<CalendarEvent> get events => _events;
  bool get isSyncing => _isSyncing;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;

  CalendarProvider(this._apiService) {
    syncWithGoogle();
  }

  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  void changeMonth(int increment) {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + increment, 1);
    syncWithGoogle();
  }

  void addEvent(CalendarEvent event) {
    _events.add(event);
    _events.sort((a, b) => a.startTime.compareTo(b.startTime));
    notifyListeners();
  }

  void removeEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> syncWithGoogle() async {
    _isSyncing = true;
    notifyListeners();
    
    try {
      final api = await _apiService.calendarApi;
      if (api == null) return;

      final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final eventsResult = await api.events.list(
        'primary',
        timeMin: firstDay.toUtc(),
        timeMax: lastDay.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      _events = [];
      for (var e in eventsResult.items ?? []) {
        final start = e.start?.dateTime ?? e.start?.date;
        final end = e.end?.dateTime ?? e.end?.date;
        final location = e.location;
        
        double? lat;
        double? lng;

        if (location != null && location.isNotEmpty) {
          final coords = await _geocodingService.getCoordinates(location);
          if (coords != null) {
            lat = coords.latitude;
            lng = coords.longitude;
          }
        }

        _events.add(CalendarEvent(
          id: e.id ?? '',
          title: e.summary ?? 'No Title',
          startTime: start?.toLocal() ?? DateTime.now(),
          endTime: end?.toLocal() ?? DateTime.now(),
          location: location,
          requiresCommute: location != null && location.isNotEmpty,
          latitude: lat,
          longitude: lng,
        ));
      }

    } catch (e) {
      debugPrint("Calendar Sync Error: \$e");
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  List<CalendarEvent> get eventsForSelectedDay {
    if (_selectedDay == null) return [];
    return _events.where((e) {
      return e.startTime.year == _selectedDay!.year &&
             e.startTime.month == _selectedDay!.month &&
             e.startTime.day == _selectedDay!.day;
    }).toList();
  }

  CalendarEvent? get nextCommuteEvent {
    final upcoming = _events.where((e) => e.isUpcoming && e.requiresCommute).toList();
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  CalendarEvent? get nextEvent {
    final upcoming = _events.where((e) => e.isUpcoming).toList();
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }
}
