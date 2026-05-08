import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/explore_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/mobility_provider.dart';
import 'providers/meeting_assistant_provider.dart';
import 'providers/mail_provider.dart';
import 'providers/task_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';

import 'services/google_api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'services/notification_service.dart';

import 'providers/preference_provider.dart';

import 'main_navigation_holder.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await NotificationService().init();
    
    final googleSignIn = GoogleSignIn(
      serverClientId: '389649979218-v4qor7j0nst6cq2ojdojkdlr9uf914bu.apps.googleusercontent.com',
      scopes: [
        'email',
        'profile',
        'https://www.googleapis.com/auth/calendar.readonly',
        'https://www.googleapis.com/auth/gmail.readonly',
        'https://www.googleapis.com/auth/gmail.send',
      ],
    );
    final googleApiService = GoogleApiService(googleSignIn);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(googleSignIn)),
          ChangeNotifierProvider(create: (_) => PreferenceProvider()),
          ChangeNotifierProvider(create: (_) => ExploreProvider()),
          ChangeNotifierProvider(create: (_) => NotesProvider()),
          ChangeNotifierProvider(create: (_) => CalendarProvider(googleApiService)),
          ChangeNotifierProvider(create: (_) => MobilityProvider()),
          ChangeNotifierProvider(create: (_) => MeetingAssistantProvider()),
          ChangeNotifierProvider(create: (_) => MailProvider(googleApiService)),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
        ],
        child: const KairoApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint("CRITICAL STARTUP ERROR: $e");
    debugPrint(stack.toString());
    
    // Display a simple error screen instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text("Kairo failed to start.\n\nError: $e", 
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    ));
  }
}

class KairoApp extends StatelessWidget {
  const KairoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kairo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A2E1A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF9F9F7),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A2E1A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const MainNavigationHolder(), // Go directly to the app
    );
  }
}
