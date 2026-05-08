import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class GoogleApiService {
  final GoogleSignIn _googleSignIn;

  GoogleApiService(this._googleSignIn);

  Future<http.Client?> get authenticatedClient async {
    final account = await _googleSignIn.signInSilently();
    if (account == null) return null;
    
    final auth = await account.authentication;
    final token = auth.accessToken;
    if (token == null) return null;
    return AuthenticatedClient(token);
  }

  Future<CalendarApi?> get calendarApi async {
    final client = await authenticatedClient;
    if (client == null) return null;
    return CalendarApi(client);
  }

  Future<GmailApi?> get gmailApi async {
    final client = await authenticatedClient;
    if (client == null) return null;
    return GmailApi(client);
  }
}

class AuthenticatedClient extends http.BaseClient {
  final String accessToken;
  final http.Client _client = http.Client();

  AuthenticatedClient(this.accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
    return _client.send(request);
  }
}
