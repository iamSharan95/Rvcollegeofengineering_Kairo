import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/email.dart';
import '../services/google_api_service.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

class MailProvider with ChangeNotifier {
  final GoogleApiService _apiService;
  List<Email> _emails = [];
  bool _isLoading = false;

  List<Email> get emails => _emails;
  bool get isLoading => _isLoading;

  MailProvider(this._apiService) {
    fetchEmails();
  }

  Future<void> fetchEmails() async {
    _isLoading = true;
    notifyListeners();

    try {
      final api = await _apiService.gmailApi;
      if (api == null) return;

      final messagesResponse = await api.users.messages.list('me', maxResults: 15);
      final messages = messagesResponse.messages ?? [];

      List<Email> loadedEmails = [];
      for (var msg in messages) {
        final fullMsg = await api.users.messages.get('me', msg.id!);
        final headers = fullMsg.payload?.headers ?? [];
        
        String subject = 'No Subject';
        String from = 'Unknown Sender';
        String? dateHeader;

        for (var header in headers) {
          if (header.name == 'Subject') subject = header.value ?? subject;
          if (header.name == 'From') from = header.value ?? from;
          if (header.name == 'Date') dateHeader = header.value;
        }
        
        DateTime date = DateTime.now();
        if (dateHeader != null) {
          try {
            date = DateTime.parse(dateHeader);
          } catch (_) {}
        }

        loadedEmails.add(Email(
          id: msg.id!,
          sender: from,
          subject: subject,
          body: fullMsg.snippet ?? '',
          date: date,
          category: _categorizeEmail(subject, fullMsg.snippet ?? ''),
        ));
      }

      _emails = loadedEmails;
    } catch (e) {
      debugPrint("Gmail Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  EmailCategory _categorizeEmail(String subject, String snippet) {
    final text = "$subject $snippet".toLowerCase();
    if (text.contains('flight') || text.contains('travel') || text.contains('confirmation')) return EmailCategory.travel;
    if (text.contains('meeting') || text.contains('zoom') || text.contains('invite')) return EmailCategory.meeting;
    if (text.contains('github') || text.contains('tech') || text.contains('programming')) return EmailCategory.tech;
    return EmailCategory.general;
  }

  Future<void> sendEmail(String to, String subject, String body) async {
    try {
      final api = await _apiService.gmailApi;
      if (api == null) return;

      final emailContent = 'To: $to\r\n'
          'Subject: $subject\r\n'
          'Content-Type: text/plain; charset="UTF-8"\r\n'
          '\r\n'
          '$body';

      final message = gmail.Message();
      message.raw = base64Url.encode(utf8.encode(emailContent)).replaceAll('=', '');

      await api.users.messages.send(message, 'me');
      debugPrint("Email sent successfully to $to");
      fetchEmails(); // Refresh inbox
    } catch (e) {
      debugPrint("Error sending email: $e");
    }
  }

  void markActioned(String id) {
    final index = _emails.indexWhere((e) => e.id == id);
    if (index != -1) {
      _emails[index].isActioned = true;
      notifyListeners();
    }
  }
}
