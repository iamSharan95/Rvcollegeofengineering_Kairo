import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/meeting_assistant_provider.dart';
import '../providers/calendar_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/task_provider.dart';
import '../models/note.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  void _showQuickNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quick Note", style: GoogleFonts.instrumentSerif(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Title", border: InputBorder.none),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: "What's on your mind?", border: InputBorder.none),
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final newNote = Note(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        content: contentController.text,
                        date: DateTime.now(),
                        type: NoteType.personal,
                      );
                      Provider.of<NotesProvider>(context, listen: false).addNote(newNote);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note added to Hub")));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A2E1A), foregroundColor: Colors.white),
                  child: const Text("SAVE"),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showUserProfile(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: auth.user?.photoURL != null ? NetworkImage(auth.user!.photoURL!) : null,
              child: auth.user?.photoURL == null ? const Icon(Icons.person, size: 40) : null,
            ),
            const SizedBox(height: 16),
            Text(auth.user?.displayName ?? "Guest User", style: GoogleFonts.instrumentSerif(fontSize: 24)),
            Text(auth.user?.email ?? "Not signed in", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            if (auth.isAuthenticated)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    auth.signOut();
                    Navigator.pop(context);
                  },
                  child: const Text("SIGN OUT"),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    auth.signInWithGoogle();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  child: const Text("SIGN IN WITH GOOGLE"),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.displayName?.split(' ').first ?? "USER";
    final assistant = Provider.of<MeetingAssistantProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => _showUserProfile(context, authProvider),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: authProvider.user?.photoURL != null 
                  ? NetworkImage(authProvider.user!.photoURL!) 
                  : null,
              child: authProvider.user?.photoURL == null 
                  ? const Icon(Icons.person_outline, size: 20, color: Colors.black54) 
                  : null,
            ),
          ),
        ),
        title: Text("Kairo", style: GoogleFonts.instrumentSerif(
          fontSize: 24, fontStyle: FontStyle.italic, color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings coming soon")));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getGreeting(), style: GoogleFonts.instrumentSerif(
              fontSize: 44, height: 1.0, color: Colors.black)),
            Text("$userName.", style: GoogleFonts.instrumentSerif(
              fontSize: 44, height: 1.1, color: Colors.black)),
            const SizedBox(height: 16),
            Text(
              "Your day is structured for focus. Here is what we have prepared for you.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 32),
            
            // Today Summary Card - Simplified as requested
            _buildTodaySummaryCard(context, taskProvider),
            
            const SizedBox(height: 24),
            
            // Assistant Interface / Knowledge Base
            GestureDetector(
              onTap: () {
                // Navigate to Hub (index 2 in MainNavigationHolder)
                // Since this is a simple app, we can't easily trigger the parent's setState
                // But we can use a workaround or just show a message.
                // Ideally we'd use a provider for navigation state.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening Hub...")));
              },
              child: _buildAssistantInterfaceCard(),
            ),

            const SizedBox(height: 24),
            
            // Next Event / Shadow Section
            _buildMeetingCard(context, assistant, (summary) {
              notesProvider.addNote(summary);
            }),

            const SizedBox(height: 24),

            // Mobility Logic Section
            _buildMobilityLogicCard(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummaryCard(BuildContext context, TaskProvider taskProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TODAY SUMMARY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: Colors.grey)),
              GestureDetector(
                onTap: () => _showQuickNoteDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF1A2E1A), borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text("QUICK NOTE", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetric(taskProvider.activeTasks.length.toString(), "TASKS"),
              const SizedBox(width: 40),
              _buildMetric(taskProvider.priorityTasks.length.toString(), "PRIORITY"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: GoogleFonts.instrumentSerif(fontSize: 32)),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAssistantInterfaceCard() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade400, Colors.grey.shade500],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 20,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("KNOWLEDGE HUB", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                const SizedBox(height: 8),
                Text("KNOWLEDGE BASE", style: GoogleFonts.instrumentSerif(fontSize: 20, color: Colors.white)),
                Text("Insights from your last session.", style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, MeetingAssistantProvider assistant, Function(Note) onSummary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("IN 15 MINS", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.green.shade800)),
              ),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.blue.shade200, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Text("Project Kairo: Quarterly Sync", style: GoogleFonts.instrumentSerif(fontSize: 22, height: 1.1)),
          const SizedBox(height: 4),
          Text("Product Strategy & Design Language", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  final calendar = Provider.of<CalendarProvider>(context, listen: false);
                  final nextEvent = calendar.nextEvent;
                  if (nextEvent != null) {
                    assistant.attendMeeting(nextEvent, onSummary);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2E1A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Join as Non-Attendee", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Transcribe & Report", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Switch.adaptive(value: true, onChanged: (v) {}, activeTrackColor: const Color(0xFF1A2E1A)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Kairo will join as a ghost participant, listen to the conversation, and provide a summary by 2 PM.",
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilityLogicCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E1A),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("MOBILITY LOGIC", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1)),
              Icon(Icons.directions_car_outlined, size: 18, color: Colors.white.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Text("Ride for Executive Dinner", style: GoogleFonts.instrumentSerif(fontSize: 22, color: Colors.white)),
          const SizedBox(height: 4),
          Text("Destination: The Greenhouse, Downtown", style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 24),
          _buildMobilityStep(Icons.access_time, "ETD: 6:30 PM", "Suggested 30m start enabled", true),
          const SizedBox(height: 12),
          _buildMobilityStep(Icons.check_circle_outline, "ETA: 6:45 PM", "Early arrival buffer (15m) confirmed", false),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ride confirmed with Uber/Lyft")));
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A2E1A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Confirm Ride Request", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMobilityStep(IconData icon, String title, String sub, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white54),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              Text(sub, style: const TextStyle(fontSize: 10, color: Colors.white54)),
            ],
          )
        ],
      ),
    );
  }
}
