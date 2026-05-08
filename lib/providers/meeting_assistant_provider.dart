import 'dart:async';
import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../models/note.dart';
import '../services/ai_summary_service.dart';

enum MeetingAssistantStatus { idle, joining, attending, summarizing, completed }

class MeetingAssistantProvider with ChangeNotifier {
  final AISummaryService _summaryService = AISummaryService();
  MeetingAssistantStatus _status = MeetingAssistantStatus.idle;
  String? _currentMeetingTitle;
  String _liveTranscript = "";
  
  MeetingAssistantStatus get status => _status;
  String? get currentMeeting => _currentMeetingTitle;
  String get liveTranscript => _liveTranscript;

  Future<void> attendMeeting(CalendarEvent event, Function(Note) onSummaryReady) async {
    _status = MeetingAssistantStatus.joining;
    _currentMeetingTitle = event.title;
    _liveTranscript = "Establishing connection...";
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _status = MeetingAssistantStatus.attending;
    
    // Simulate live transcription updates
    final segments = [
      "Speaker 1: Welcome everyone to the product sync.",
      "Speaker 2: We need to discuss the new UI.",
      "Speaker 1: I think we should go for a minimalist look.",
      "Speaker 3: Agreed, simplicity is key.",
    ];

    for (var segment in segments) {
      if (_status != MeetingAssistantStatus.attending) break;
      await Future.delayed(const Duration(seconds: 2));
      _liveTranscript += "\n$segment";
      notifyListeners();
    }

    await Future.delayed(const Duration(seconds: 1));
    _status = MeetingAssistantStatus.summarizing;
    _liveTranscript += "\n\n[Meeting Ended. Generating Summary...]";
    notifyListeners();

    // Generate the AI summary
    const fullTranscript = "Long meeting transcript text...";
    final summaryContent = await _summaryService.summarizeTranscript(fullTranscript);

    final summary = Note(
      id: DateTime.now().toIso8601String(),
      title: "AI Summary: ${event.title}",
      content: summaryContent,
      date: DateTime.now(),
      type: NoteType.transcript,
    );

    onSummaryReady(summary);

    // Automation: Extract tasks from the summary
    // In a real app, this would be passed to the TaskProvider

    _status = MeetingAssistantStatus.completed;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 3));
    _status = MeetingAssistantStatus.idle;
    _currentMeetingTitle = null;
    notifyListeners();
  }
}
