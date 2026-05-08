import '../models/calendar_event.dart';

class GoogleCalendarService {
  // This will eventually handle OAuth2 and real API calls
  Future<List<CalendarEvent>> fetchEvents() async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate data structure from Google Calendar API
    return [
      CalendarEvent(
        id: 'gc_1',
        title: 'Strategy Meeting (Synced)',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        location: 'Meeting Room A',
        requiresCommute: false,
      ),
      CalendarEvent(
        id: 'gc_2',
        title: 'Client Onboarding',
        startTime: DateTime.now().add(const Duration(hours: 4)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
        location: '123 Business St, Tech City',
        requiresCommute: true,
      ),
    ];
  }
}
