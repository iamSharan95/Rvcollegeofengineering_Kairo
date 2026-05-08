import 'dart:async';
import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../services/notification_service.dart';

enum RideStatus { none, searching, confirmed, arriving, inProgress, completed }

class MobilityProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  RideStatus _status = RideStatus.none;
  DateTime? _estimatedDepartureTime;
  DateTime? _estimatedArrivalTime;
  String? _driverName;
  String? _carModel;

  RideStatus get status => _status;
  String? get driverName => _driverName;
  String? get carModel => _carModel;
  DateTime? get etd => _estimatedDepartureTime;
  DateTime? get eta => _estimatedArrivalTime;

  // Mock booking logic
  Future<void> bookRide(CalendarEvent event) async {
    _status = RideStatus.searching;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 3));

    _status = RideStatus.confirmed;
    _driverName = "John Doe";
    _carModel = "Tesla Model 3 - Blue";
    
    // Calculate ETD (30 mins before) and ETA (15 mins before event)
    _estimatedDepartureTime = event.startTime.subtract(const Duration(minutes: 30));
    _estimatedArrivalTime = event.startTime.subtract(const Duration(minutes: 15));
    
    // Schedule the 30-minute ETD notification
    await _notificationService.scheduleETDNotification(
      id: event.id.hashCode,
      title: "Kairo: Time to leave!",
      body: "Your ride to ${event.title} leaves in 30 minutes.",
      scheduledDate: _estimatedDepartureTime!,
    );

    notifyListeners();
  }

  void cancelRide() {
    _status = RideStatus.none;
    _driverName = null;
    _carModel = null;
    notifyListeners();
  }

  // Check if we need to notify user (30 mins before ETD)
  // In a real app, this would be a background task or push notification
  void checkProactiveNotifications(CalendarEvent event) {
    final now = DateTime.now();
    final etd = event.startTime.subtract(const Duration(minutes: 30));
    
    if (now.isAfter(etd.subtract(const Duration(minutes: 1))) && now.isBefore(etd)) {
      // Trigger notification logic here
      debugPrint("NOTIFICATION: Time to prepare for your ride to \${event.location}!");
    }
  }
}
